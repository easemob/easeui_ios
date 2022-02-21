//
//  EMSingleChatViewController.m
//  EaseIM
//
//  Created by 娜塔莎 on 2020/7/9.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import "EMSingleChatViewController.h"
#import "EMChatBar.h"
#import "EaseMessageModel.h"
#import "EaseChatViewController+EaseUI.h"

#define TypingTimerCountNum 10

@interface EMSingleChatViewController () <EMChatBarDelegate>
{
    long long _previousChangedTimeStamp;
}
@property (nonatomic, strong) NSTimer *receiveTypingTimer;
@property (nonatomic, assign) NSInteger receiveTypingCountDownNum;
@property (nonatomic, strong) dispatch_queue_t msgQueue;
@property (nonatomic, strong) NSDate *currentData;
@property (nonatomic) BOOL editingStatusVisible;
@end

@implementation EMSingleChatViewController

- (instancetype)initSingleChatViewControllerWithCoversationid:(NSString *)conversationId
                                                chatViewModel:(EaseChatViewModel *)viewModel
{
    self = [super initChatViewControllerWithCoversationid:conversationId
                       conversationType:EMConversationTypeChat
                          chatViewModel:(EaseChatViewModel *)viewModel];
    if (self) {
        _receiveTypingCountDownNum = 0;
        _previousChangedTimeStamp = 0;
        _editingStatusVisible = NO;
        _msgQueue = dispatch_queue_create("singlemessage.com", NULL);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)dealloc
{
    [self stopReceiveTypingTimer];
}

- (void)setEditingStatusVisible:(BOOL)editingStatusVisible
{
    _editingStatusVisible = editingStatusVisible;
}

#pragma mark - EMChatManagerDelegate

//　收到已读回执
- (void)messagesDidRead:(NSArray *)aMessages
{
    __weak typeof(self) weakself = self;
    dispatch_async(self.msgQueue, ^{
        NSString *conId = weakself.currentConversation.conversationId;
        __block BOOL isReladView = NO;
        for (EMChatMessage *message in aMessages) {
            if (![conId isEqualToString:message.conversationId]){
                continue;
            }
            
            [weakself.dataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:[EaseMessageModel class]]) {
                    EaseMessageModel *model = (EaseMessageModel *)obj;
                    if ([model.message.messageId isEqualToString:message.messageId]) {
                        model.message.isReadAcked = YES;
                        isReladView = YES;
                        *stop = YES;
                    }
                }
            }];
        }
        
        if (isReladView) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself.tableView reloadData];
            });
        }
    });
}
//收到 CMD 消息
- (void)cmdMessagesDidReceive:(NSArray *)aCmdMessages
{
    NSString *conId = self.currentConversation.conversationId;
    for (EMChatMessage *message in aCmdMessages) {
        if (![conId isEqualToString:message.conversationId]) {
            continue;
        }
        EMCmdMessageBody *body = (EMCmdMessageBody *)message.body;
        if ([body.action isEqualToString:MSG_TYPING_BEGIN]) {
            if (_receiveTypingCountDownNum == 0) {
                [self startReceiveTypingTimer];
            }else {
                _receiveTypingCountDownNum = TypingTimerCountNum;
            }
        }
    }
}

#pragma mark - EMChatBarDelegate

- (void)inputViewDidChange:(EaseTextView *)aInputView
{
    if (self.currentConversation.type == EMConversationTypeChat) {
        long long currentTimestamp = [self getCurrentTimestamp];
        if ((currentTimestamp - _previousChangedTimeStamp) > 5 && _editingStatusVisible) {
            [self _sendBeginTyping];
            _previousChangedTimeStamp = currentTimestamp;
        }
    }
}

- (long long)getCurrentTimestamp
{
    self.currentData = [NSDate new];
    NSTimeInterval timeInterval = [self.currentData timeIntervalSince1970];
    return [[NSNumber numberWithDouble:timeInterval] longLongValue];
}

//正在输入状态
- (void)_sendBeginTyping
{
    NSString *from = [[EMClient sharedClient] currentUsername];
    NSString *to = self.currentConversation.conversationId;
    EMCmdMessageBody *body = [[EMCmdMessageBody alloc] initWithAction:MSG_TYPING_BEGIN];
    body.isDeliverOnlineOnly = YES;
    EMChatMessage *message = [[EMChatMessage alloc] initWithConversationID:to from:from to:to body:body ext:nil];
    message.chatType = EMChatTypeChat;
    [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:nil];
}

#pragma mark - Action

- (void)sendReadReceipt:(EMChatMessage *)msg
{
    if ([self _isNeedSendReadAckForMessage:msg isMarkRead:NO]) {
        [[EMClient sharedClient].chatManager sendMessageReadAck:msg.messageId toUser:msg.conversationId completion:nil];
    }
}

- (BOOL)_isNeedSendReadAckForMessage:(EMChatMessage *)aMessage
                          isMarkRead:(BOOL)aIsMarkRead
{
    if (aMessage.direction == EMMessageDirectionSend || aMessage.isReadAcked || aMessage.chatType != EMChatTypeChat)
        return NO;
    EMMessageBody *body = aMessage.body;
    if (!aIsMarkRead && (body.type == EMMessageBodyTypeFile || body.type == EMMessageBodyTypeVoice || body.type == EMMessageBodyTypeImage))
        return NO;
    if (body.type == EMMessageTypeText && [((EMTextMessageBody *)body).text isEqualToString:EMCOMMUNICATE_CALLED_MISSEDCALL] && aMessage.direction == EMMessageDirectionReceive)
        return NO;
        
    return YES;
}

#pragma - mark Timer

//接收对方正在输入状态计时
- (void)startReceiveCountDown
{
    if (_receiveTypingCountDownNum == 0) {
        [self stopReceiveTypingTimer];
        if (self.delegate && [self.delegate respondsToSelector:@selector(endTyping)]) {
            [self.delegate endTyping];
        }
        return;
    }
    _receiveTypingCountDownNum--;
}

- (void)startReceiveTypingTimer {
    [self stopReceiveTypingTimer];
    _receiveTypingCountDownNum = TypingTimerCountNum;
    _receiveTypingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(startReceiveCountDown) userInfo:nil repeats:YES];
    // TODO: chong.
    [[NSRunLoop currentRunLoop] addTimer:_receiveTypingTimer forMode:UITrackingRunLoopMode];
    [_receiveTypingTimer fire];
    if (self.delegate && [self.delegate respondsToSelector:@selector(beginTyping)]) {
        [self.delegate beginTyping];
    }
    
}
- (void)stopReceiveTypingTimer {
    _receiveTypingCountDownNum = 0;
    if (_receiveTypingTimer) {
        [_receiveTypingTimer invalidate];
        _receiveTypingTimer = nil;
    }
}

@end
