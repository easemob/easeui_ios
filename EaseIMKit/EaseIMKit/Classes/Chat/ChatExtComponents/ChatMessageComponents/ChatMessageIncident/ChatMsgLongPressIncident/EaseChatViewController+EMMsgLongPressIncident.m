//
//  EaseChatViewController+EMMsgLongPressIncident.m
//  EaseIM
//
//  Created by 娜塔莎 on 2020/7/9.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import "EaseChatViewController+EMMsgLongPressIncident.h"
#import <objc/runtime.h>
#import "EMMsgTextBubbleView.h"
#import "EaseDateHelper.h"

typedef NS_ENUM(NSInteger, EaseLongPressExecute) {
    EaseLongPressExecuteCopy = 0,
    EaseLongPressExecuteForward,
    EaseLongPressExecuteDelete,
    EaseLongPressExecuteRecall,
};

static const void *longPressIndexPathKey = &longPressIndexPathKey;
static const void *recallViewKey = &recallViewKey;
@implementation EaseChatViewController (EMMsgLongPressIncident)

@dynamic longPressIndexPath;

- (void)resetCellLongPressStatus:(EaseMessageCell *)aCell
{
    if (aCell.model.type == EMMessageTypeText) {
        EMMsgTextBubbleView *textBubbleView = (EMMsgTextBubbleView*)aCell.bubbleView;
        textBubbleView.textLabel.backgroundColor = [UIColor clearColor];
    }
}

- (void)deleteLongPressAction:(void (^)(EMChatMessage *deleteMsg))aCompletionBlock
{
    if (self.longPressIndexPath == nil || self.longPressIndexPath.row < 0) {
        return;
    }
    __weak typeof(self) weakself = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:EaseLocalizableString(@"confirmDelete", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *clearAction = [UIAlertAction actionWithTitle:EaseLocalizableString(@"delete", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        EaseMessageModel *model = [weakself.dataArray objectAtIndex:weakself.longPressIndexPath.row];
        [weakself.currentConversation deleteMessageWithId:model.message.messageId error:nil];
        NSMutableIndexSet *indexs = [NSMutableIndexSet indexSetWithIndex:weakself.longPressIndexPath.row];
        NSMutableArray *indexPaths = [NSMutableArray arrayWithObjects:weakself.longPressIndexPath, nil];
        if (self.longPressIndexPath.row - 1 >= 0) {
            id nextMessage = nil;
            id prevMessage = [weakself.dataArray objectAtIndex:(weakself.longPressIndexPath.row - 1)];
            if (weakself.longPressIndexPath.row + 1 < [weakself.dataArray count]) {
                nextMessage = [weakself.dataArray objectAtIndex:(weakself.longPressIndexPath.row + 1)];
            }
            if ((!nextMessage || [nextMessage isKindOfClass:[NSString class]]) && [prevMessage isKindOfClass:[NSString class]]) {
                [indexs addIndex:weakself.longPressIndexPath.row - 1];
                [indexPaths addObject:[NSIndexPath indexPathForRow:(weakself.longPressIndexPath.row - 1) inSection:0]];
            }
        }
        [weakself.dataArray removeObjectsAtIndexes:indexs];
        [weakself.tableView beginUpdates];
        [weakself.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        [weakself.tableView endUpdates];
        if ([weakself.dataArray count] == 0) {
            weakself.msgTimelTag = -1;
        }
        weakself.longPressIndexPath = nil;
        if (aCompletionBlock) {
            aCompletionBlock(model.message);
        }
    }];
    [clearAction setValue:[UIColor colorWithRed:245/255.0 green:52/255.0 blue:41/255.0 alpha:1.0] forKey:@"_titleTextColor"];
    [alertController addAction:clearAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:EaseLocalizableString(@"cancel", nil) style: UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (aCompletionBlock) {
            aCompletionBlock(nil);
        }
    }];
    [cancelAction  setValue:[UIColor blackColor] forKey:@"_titleTextColor"];
    [alertController addAction:cancelAction];
    alertController.modalPresentationStyle = 0;
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)copyLongPressAction
{
    if (self.longPressIndexPath == nil || self.longPressIndexPath.row < 0) {
        return;
    }
    
    EaseMessageModel *model = [self.dataArray objectAtIndex:self.longPressIndexPath.row];
    EMTextMessageBody *body = (EMTextMessageBody *)model.message.body;
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = body.text;
    
    self.longPressIndexPath = nil;
    [self showHint:EaseLocalizableString(@"copied", nil)];
}

- (void)recallLongPressAction
{
    if (self.longPressIndexPath == nil || self.longPressIndexPath.row < 0) {
        return;
    }
    [self showHudInView:self.view hint:EaseLocalizableString(@"recalingMsg", nil)];
    NSIndexPath *indexPath = self.longPressIndexPath;
    __weak typeof(self) weakself = self;
    EaseMessageModel *model = [self.dataArray objectAtIndex:self.longPressIndexPath.row];
    [[EMClient sharedClient].chatManager recallMessageWithMessageId:model.message.messageId completion:^(EMError *aError) {
        [weakself hideHud];
        if (aError) {
            [EaseAlertController showErrorAlert:aError.errorDescription];
        } else {
            EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:EaseLocalizableString(@"meRecall", nil)];
            NSString *to = model.message.to;
            NSString *from = model.message.from;
            EMChatMessage *message = [[EMChatMessage alloc] initWithConversationID:to from:from to:to body:body ext:@{MSG_EXT_RECALL:@(YES), MSG_EXT_RECALLBY:[[EMClient sharedClient] currentUsername]}];
            message.chatType = (EMChatType)self.currentConversation.type;
            message.isRead = YES;
            message.timestamp = model.message.timestamp;
            message.localTime = model.message.localTime;
            [weakself.currentConversation insertMessage:message error:nil];
            
            EaseMessageModel *model = [[EaseMessageModel alloc] initWithEMMessage:message];
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
                 completion:(void (^)(EMChatMessage *message))aCompletionBlock
{
    NSString *from = [[EMClient sharedClient] currentUsername];
    EMChatMessage *message = [[EMChatMessage alloc] initWithConversationID:aTo from:from to:aTo body:aBody ext:aExt];
    message.chatType = EMChatTypeChat;
    
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:^(EMChatMessage *message, EMError *error) {
        if (error) {
            [weakself.currentConversation deleteMessageWithId:message.messageId error:nil];
            [EaseAlertController showErrorAlert:EaseLocalizableString(@"transferMsgFail", nil)];
        } else {
            if (aCompletionBlock) {
                aCompletionBlock(message);
            }
            [EaseAlertController showSuccessAlert:EaseLocalizableString(@"transferMsgSuccess", nil)];
            if ([aTo isEqualToString:weakself.currentConversation.conversationId]) {
                [weakself sendReadReceipt:message];
                [weakself.currentConversation markMessageAsReadWithId:message.messageId error:nil];
                NSArray *formated = [weakself formatMsgs:@[message]];
                [weakself.dataArray addObjectsFromArray:formated];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakself refreshTableView:YES];
                });
            }
        }
    }];
}

#pragma mark - Data

- (NSArray *)formatMsgs:(NSArray<EMChatMessage *> *)aMessages
{
    NSMutableArray *formated = [[NSMutableArray alloc] init];

    for (int i = 0; i < [aMessages count]; i++) {
        EMChatMessage *msg = aMessages[i];
        if (msg.chatType == EMChatTypeChat && msg.isReadAcked && (msg.body.type == EMMessageBodyTypeText || msg.body.type == EMMessageBodyTypeLocation)) {
            [[EMClient sharedClient].chatManager sendMessageReadAck:msg.messageId toUser:msg.conversationId completion:nil];
        }
        
        CGFloat interval = (self.msgTimelTag - msg.timestamp) / 1000;
        if (self.msgTimelTag < 0 || interval > 60 || interval < -60) {
            NSString *timeStr = [EaseDateHelper formattedTimeFromTimeInterval:msg.timestamp];
            [formated addObject:timeStr];
            self.msgTimelTag = msg.timestamp;
        }
        EaseMessageModel *model = nil;
        model = [[EaseMessageModel alloc] initWithEMMessage:msg];
        if (!model) {
            model = [[EaseMessageModel alloc]init];
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(userData:)]) {
            id<EaseUserDelegate> userData = [self.delegate userData:msg.from];
            model.userDataDelegate = userData;
        }

        [formated addObject:model];
    }
    
    return formated;
}

- (void)_forwardImageMsg:(EMChatMessage *)aMsg
                  toUser:(NSString *)aUsername
{
    EMImageMessageBody *newBody = nil;
    EMImageMessageBody *imgBody = (EMImageMessageBody *)aMsg.body;
    // 如果图片是己方发送，直接获取图片文件路径；若是对方发送，则需先查看原图（自动下载原图），再转发。
    if ([aMsg.from isEqualToString:EMClient.sharedClient.currentUsername]) {
        newBody = [[EMImageMessageBody alloc]initWithLocalPath:imgBody.localPath displayName:imgBody.displayName];
    } else {
        if (imgBody.downloadStatus != EMDownloadStatusSuccessed) {
            [EaseAlertController showErrorAlert:EaseLocalizableString(@"downloadImageFirst", nil)];
            return;
        }
        
        newBody = [[EMImageMessageBody alloc]initWithLocalPath:imgBody.localPath displayName:imgBody.displayName];
    }
    
    newBody.size = imgBody.size;
    __weak typeof(self) weakself = self;
    [weakself _forwardMsgWithBody:newBody to:aUsername ext:aMsg.ext completion:^(EMChatMessage *message) {
        
    }];
}

- (void)_forwardVideoMsg:(EMChatMessage *)aMsg
                  toUser:(NSString *)aUsername
{
    EMVideoMessageBody *oldBody = (EMVideoMessageBody *)aMsg.body;

    __weak typeof(self) weakself = self;
    void (^block)(EMChatMessage *aMessage) = ^(EMChatMessage *aMessage) {
        EMVideoMessageBody *newBody = [[EMVideoMessageBody alloc] initWithLocalPath:oldBody.localPath displayName:oldBody.displayName];
        newBody.thumbnailLocalPath = oldBody.thumbnailLocalPath;
        
        [weakself _forwardMsgWithBody:newBody to:aUsername ext:aMsg.ext completion:^(EMChatMessage *message) {
            [(EMVideoMessageBody *)message.body setLocalPath:[(EMVideoMessageBody *)aMessage.body localPath]];
            [[EMClient sharedClient].chatManager updateMessage:message completion:nil];
        }];
    };
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:oldBody.localPath]) {
        [[EMClient sharedClient].chatManager downloadMessageAttachment:aMsg progress:nil completion:^(EMChatMessage *message, EMError *error) {
            if (error) {
                [EaseAlertController showErrorAlert:EaseLocalizableString(@"transferMsgFail", nil)];
            } else {
                block(aMsg);
            }
        }];
    } else {
        block(aMsg);
    }
}

- (void)_transpondMsg:(EaseMessageModel *)aModel
               toUser:(NSString *)aUsername
{
    EMMessageBodyType type = aModel.message.body.type;
    if (type == EMMessageBodyTypeText || type == EMMessageBodyTypeLocation)
        [self _forwardMsgWithBody:aModel.message.body to:aUsername ext:aModel.message.ext completion:nil];
    if (type == EMMessageBodyTypeImage)
        [self _forwardImageMsg:aModel.message toUser:aUsername];
    if (type == EMMessageBodyTypeVideo)
        [self _forwardVideoMsg:aModel.message toUser:aUsername];
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
