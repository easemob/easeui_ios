//
//  EMChatViewController+EMMsgLongPressIncident.m
//  EaseIM
//
//  Created by 娜塔莎 on 2020/7/9.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import "EMChatViewController+EMMsgLongPressIncident.h"
#import "EMMsgTranspondViewController.h"
#import <objc/runtime.h>
#import "EMMsgTextBubbleView.h"

typedef NS_ENUM(NSInteger, EaseLongPressExecute) {
    EaseLongPressExecuteCopy = 0,
    EaseLongPressExecuteForward,
    EaseLongPressExecuteDelete,
    EaseLongPressExecuteRecall,
};

static const void *longPressIndexPathKey = &longPressIndexPathKey;

@implementation EMChatViewController (EMMsgLongPressIncident)

@dynamic longPressIndexPath;

- (void)executeAction:(NSInteger)tag
{
    if (tag == EaseLongPressExecuteCopy)
        [self deleteLongPressAction];
    if (tag == EaseLongPressExecuteForward)
        [self forwardLongPressAction];
    if (tag == EaseLongPressExecuteDelete)
        [self deleteLongPressAction];
    if (tag == EaseLongPressExecuteRecall)
        [self recallLongPressAction];
}

- (void)resetCellLongPressStatus:(EMMessageCell *)aCell
{
    if (aCell.model.type == EMMessageTypeText) {
        EMMsgTextBubbleView *textBubbleView = (EMMsgTextBubbleView*)aCell.bubbleView;
        textBubbleView.textLabel.backgroundColor = [UIColor clearColor];
    }
}

- (void)deleteLongPressAction
{
    if (self.longPressIndexPath == nil || self.longPressIndexPath.row < 0) {
        return;
    }
    
    EMMessageModel *model = [self.dataArray objectAtIndex:self.longPressIndexPath.row];
    [self.currentConversation deleteMessageWithId:model.emModel.messageId error:nil];
    
    NSMutableIndexSet *indexs = [NSMutableIndexSet indexSetWithIndex:self.longPressIndexPath.row];
    NSMutableArray *indexPaths = [NSMutableArray arrayWithObjects:self.longPressIndexPath, nil];
    if (self.longPressIndexPath.row - 1 >= 0) {
        id nextMessage = nil;
        id prevMessage = [self.dataArray objectAtIndex:(self.longPressIndexPath.row - 1)];
        if (self.longPressIndexPath.row + 1 < [self.dataArray count]) {
            nextMessage = [self.dataArray objectAtIndex:(self.longPressIndexPath.row + 1)];
        }
        if ((!nextMessage || [nextMessage isKindOfClass:[NSString class]]) && [prevMessage isKindOfClass:[NSString class]]) {
            [indexs addIndex:self.longPressIndexPath.row - 1];
            [indexPaths addObject:[NSIndexPath indexPathForRow:(self.longPressIndexPath.row - 1) inSection:0]];
        }
    }
    
    [self.dataArray removeObjectsAtIndexes:indexs];
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    
    if ([self.dataArray count] == 0) {
        self.msgTimelTag = -1;
    }
    
    self.longPressIndexPath = nil;
}

- (void)copyLongPressAction
{
    if (self.longPressIndexPath == nil || self.longPressIndexPath.row < 0) {
        return;
    }
    
    EMMessageModel *model = [self.dataArray objectAtIndex:self.longPressIndexPath.row];
    EMTextMessageBody *body = (EMTextMessageBody *)model.emModel.body;
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = body.text;
    
    self.longPressIndexPath = nil;
}

- (void)forwardLongPressAction
{
    if (self.longPressIndexPath == nil || self.longPressIndexPath.row < 0) {
        return;
    }
    
    EMMessageModel *model = [self.dataArray objectAtIndex:self.longPressIndexPath.row];
    EMMsgTranspondViewController *controller = [[EMMsgTranspondViewController alloc] initWithModel:model];
    [self.navigationController pushViewController:controller animated:NO];
    
    __weak typeof(self) weakself = self;
    [controller setDoneCompletion:^(EMMessageModel * _Nonnull aModel, NSString * _Nonnull aUsername) {
        [weakself _transpondMsg:aModel toUser:aUsername];
    }];
    
    self.longPressIndexPath = [[NSIndexPath alloc]initWithIndex:-1];;
}

- (void)recallLongPressAction
{
    if (self.longPressIndexPath == nil || self.longPressIndexPath.row < 0) {
        return;
    }
    
    NSIndexPath *indexPath = self.longPressIndexPath;
    __weak typeof(self) weakself = self;
    EMMessageModel *model = [self.dataArray objectAtIndex:self.longPressIndexPath.row];
    [[EMClient sharedClient].chatManager recallMessageWithMessageId:model.emModel.messageId completion:^(EMError *aError) {
        if (aError) {
            [EMAlertController showErrorAlert:aError.errorDescription];
        } else {
            EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:@"您撤回一条消息"];
            NSString *from = [[EMClient sharedClient] currentUsername];
            NSString *to = self.currentConversation.conversationId;
            EMMessage *message = [[EMMessage alloc] initWithConversationID:to from:from to:to body:body ext:@{MSG_EXT_RECALL:@(YES)}];
            message.chatType = (EMChatType)self.currentConversation.type;
            message.isRead = YES;
            message.timestamp = model.emModel.timestamp;
            message.localTime = model.emModel.localTime;
            [weakself.currentConversation insertMessage:message error:nil];
            
            EMMessageModel *model = [[EMMessageModel alloc] initWithEMMessage:message];
            [weakself.dataArray replaceObjectAtIndex:indexPath.row withObject:model];
            [weakself.tableView reloadData];
        }
    }];
    
    self.longPressIndexPath = nil;
}

#pragma mark - Transpond Message

- (void)_forwardMsgWithBody:(EMMessageBody *)aBody
                         to:(NSString *)aTo
                        ext:(NSDictionary *)aExt
                 completion:(void (^)(EMMessage *message))aCompletionBlock
{
    NSString *from = [[EMClient sharedClient] currentUsername];
    EMMessage *message = [[EMMessage alloc] initWithConversationID:aTo from:from to:aTo body:aBody ext:aExt];
    message.chatType = EMChatTypeChat;
    
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:^(EMMessage *message, EMError *error) {
        if (error) {
            [weakself.currentConversation deleteMessageWithId:message.messageId error:nil];
            [EMAlertController showErrorAlert:@"转发消息失败"];
        } else {
            if (aCompletionBlock) {
                aCompletionBlock(message);
            }
            [EMAlertController showSuccessAlert:@"转发消息成功"];
            if ([aTo isEqualToString:weakself.currentConversation.conversationId]) {
                [weakself returnReadReceipt:message];
                [weakself.currentConversation markMessageAsReadWithId:message.messageId error:nil];
                NSArray *formated = [weakself formatMessages:@[message]];
                [weakself.dataArray addObjectsFromArray:formated];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakself refreshTableView];
                });
            }
        }
    }];
}

- (void)_forwardImageMsg:(EMMessage *)aMsg
                  toUser:(NSString *)aUsername
{
    EMImageMessageBody *newBody = nil;
    EMImageMessageBody *imgBody = (EMImageMessageBody *)aMsg.body;
    // 如果图片是己方发送，直接获取图片文件路径；若是对方发送，则需先查看原图（自动下载原图），再转发。
    if ([aMsg.from isEqualToString:EMClient.sharedClient.currentUsername]) {
        newBody = [[EMImageMessageBody alloc]initWithLocalPath:imgBody.localPath displayName:imgBody.displayName];
    } else {
        if (imgBody.downloadStatus != EMDownloadStatusSuccessed) {
            [EMAlertController showErrorAlert:@"请先下载原图"];
            return;
        }
        
        newBody = [[EMImageMessageBody alloc]initWithLocalPath:imgBody.localPath displayName:imgBody.displayName];
    }
    
    newBody.size = imgBody.size;
    __weak typeof(self) weakself = self;
    [weakself _forwardMsgWithBody:newBody to:aUsername ext:aMsg.ext completion:^(EMMessage *message) {
        
    }];
}

- (void)_forwardVideoMsg:(EMMessage *)aMsg
                  toUser:(NSString *)aUsername
{
    EMVideoMessageBody *oldBody = (EMVideoMessageBody *)aMsg.body;

    __weak typeof(self) weakself = self;
    void (^block)(EMMessage *aMessage) = ^(EMMessage *aMessage) {
        EMVideoMessageBody *newBody = [[EMVideoMessageBody alloc] initWithLocalPath:oldBody.localPath displayName:oldBody.displayName];
        newBody.thumbnailLocalPath = oldBody.thumbnailLocalPath;
        
        [weakself _forwardMsgWithBody:newBody to:aUsername ext:aMsg.ext completion:^(EMMessage *message) {
            [(EMVideoMessageBody *)message.body setLocalPath:[(EMVideoMessageBody *)aMessage.body localPath]];
            [[EMClient sharedClient].chatManager updateMessage:message completion:nil];
        }];
    };
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:oldBody.localPath]) {
        [[EMClient sharedClient].chatManager downloadMessageAttachment:aMsg progress:nil completion:^(EMMessage *message, EMError *error) {
            if (error) {
                [EMAlertController showErrorAlert:@"转发消息失败"];
            } else {
                block(aMsg);
            }
        }];
    } else {
        block(aMsg);
    }
}

- (void)_transpondMsg:(EMMessageModel *)aModel
               toUser:(NSString *)aUsername
{
    EMMessageBodyType type = aModel.emModel.body.type;
    if (type == EMMessageBodyTypeText || type == EMMessageBodyTypeLocation)
        [self _forwardMsgWithBody:aModel.emModel.body to:aUsername ext:aModel.emModel.ext completion:nil];
    if (type == EMMessageBodyTypeImage)
        [self _forwardImageMsg:aModel.emModel toUser:aUsername];
    if (type == EMMessageBodyTypeVideo)
        [self _forwardVideoMsg:aModel.emModel toUser:aUsername];
}

#pragma mark - getter & setter

- (NSIndexPath *)longPressIndexPath
{
    return objc_getAssociatedObject(self, longPressIndexPathKey);
}
- (void)setLongPressIndexPath:(NSIndexPath *)longPressIndexPath
{
    objc_setAssociatedObject(self, longPressIndexPathKey, longPressIndexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
