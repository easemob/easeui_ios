//
//  EMGroupChatViewController.m
//  EaseIM
//
//  Created by 娜塔莎 on 2020/7/9.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import "EMGroupChatViewController.h"
#import "EMReadReceiptMsgViewController.h"
#import "EaseMessageModel.h"
#import "EMConversation+EaseUI.h"

@interface EMGroupChatViewController () <EMReadReceiptMsgDelegate,EMGroupManagerDelegate>

@property (nonatomic, strong) EMGroup *group;
//阅读回执
@property (nonatomic, strong) EMReadReceiptMsgViewController *readReceiptControl;
//@
@property (nonatomic) BOOL isWillInputAt;

@end

@implementation EMGroupChatViewController

- (instancetype)initWithCoversationid:(NSString *)conversationId conversationType:(EMConversationType)conType chatViewModel:(EaseChatViewModel *)viewModel
{
    return [super initWithCoversationid:conversationId conversationType:conType chatViewModel:(EaseChatViewModel *)viewModel];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[EMClient sharedClient].groupManager addDelegate:self delegateQueue:nil];
}

- (void)dealloc
{
    [[EMClient sharedClient].groupManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - ACtion

- (void)returnReadReceipt:(EMMessage *)msg
{
    if (msg.isNeedGroupAck && !msg.isReadAcked) {
        [[EMClient sharedClient].chatManager sendGroupMessageReadAck:msg.messageId toGroup:msg.conversationId content:@"123" completion:^(EMError *error) {
            if (error) {
                NSLog(@"\n ------ error   %@",error.errorDescription);
            }
        }];
    }
}

#pragma mark - EMMoreFunctionViewDelegate

//群组阅读回执跳转
- (void)groupReadReceiptAction
{
    self.readReceiptControl = [[EMReadReceiptMsgViewController alloc]init];
    self.readReceiptControl.delegate = self;
    self.readReceiptControl.modalPresentationStyle = 0;
    [self presentViewController:self.readReceiptControl animated:NO completion:nil];
}

#pragma mark - EMReadReceiptMsgDelegate

//群组阅读回执发送信息
- (void)sendReadReceiptMsg:(NSString *)msg
{
    NSString *str = msg;
    NSLog(@"\n%@",str);
    if (self.currentConversation.type != EMConversationTypeGroupChat) {
        [self sendTextAction:str ext:nil];
        return;
    }
    [[EMClient sharedClient].groupManager getGroupSpecificationFromServerWithId:self.currentConversation.conversationId completion:^(EMGroup *aGroup, EMError *aError) {
        NSLog(@"\n -------- sendError:   %@",aError);
        if (!aError) {
            self.group = aGroup;
            //是群主才可以发送阅读回执信息
            [self sendTextAction:str ext:@{MSG_EXT_READ_RECEIPT:@"receipt"}];
        } else {
            [EaseAlertController showErrorAlert:@"获取群组失败"];
        }
    }];
}

#pragma mark - EMMessageCellDelegate

//阅读回执详情
- (void)messageReadReceiptDetil:(EMMessageCell *)aCell
{
    BOOL isNeedsDefaultImpl = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(groupMessageReadReceiptDetail:groupId:)]) {
        isNeedsDefaultImpl = [self.delegate groupMessageReadReceiptDetail:aCell.model.message groupId:self.currentConversation.conversationId];
    }
    if (!isNeedsDefaultImpl) {
        return;
    }
    self.readReceiptControl = [[EMReadReceiptMsgViewController alloc] initWithMessageCell:aCell groupId:self.currentConversation.conversationId];
    self.readReceiptControl.modalPresentationStyle = 0;
    [self presentViewController:self.readReceiptControl animated:NO completion:nil];
}

#pragma mark - EMChatBarDelegate

- (BOOL)inputView:(EaseTextView *)aInputView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    self.isWillInputAt = NO;
    if ([text isEqualToString:@"\n"]) {
        [self sendTextAction:aInputView.text ext:nil];
        return NO;
    }
    if ([text isEqualToString:@"@"]) {
        self.isWillInputAt = YES;
    }
    
    return YES;
}

- (void)inputViewDidChange:(EaseTextView *)aInputView
{
    //@群成员
    if (self.isWillInputAt && self.currentConversation.type == EMConversationTypeGroupChat) {
        NSString *text = aInputView.text;
        if ([text hasSuffix:@"@"]) {
            self.isWillInputAt = NO;
        }
    }
}

#pragma mark - EMChatManagerDelegate

//收到群消息已读回执
- (void)groupMessageDidRead:(EMMessage *)aMessage groupAcks:(NSArray *)aGroupAcks
{
    EaseMessageModel *msgModel;
    EMGroupMessageAck *msgAck = aGroupAcks[0];
    for (int i=0; i<[self.dataArray count]; i++) {
        if([self.dataArray[i] isKindOfClass:[EaseMessageModel class]]){
            msgModel = (EaseMessageModel *)self.dataArray[i];
        }else{
            continue;
        }
        if([msgModel.message.messageId isEqualToString:msgAck.messageId]){
            msgModel.message.isReadAcked = YES;
            [[EMClient sharedClient].chatManager sendMessageReadAck:msgModel.message.messageId toUser:msgModel.message.conversationId completion:nil];
            [self.dataArray setObject:msgModel atIndexedSubscript:i];
            __weak typeof(self) weakself = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself refreshTableView];
            });
            break;
        }
    }
}

#pragma mark - EMGroupManagerDelegate

//有用户加入群组
- (void)userDidJoinGroup:(EMGroup *)aGroup
                    user:(NSString *)aUsername
{
    [self tableViewDidTriggerHeaderRefresh];
    [self refreshTableView];
}

@end
