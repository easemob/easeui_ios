//
//  MessageRevokeManager.m
//  EaseUI
//
//  Created by WYZ on 16/2/24.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "MessageRevokeManager.h"

/** @brief 消息回撤处理完成的通知 */
#define KEM_REVOKE_NOTIFICATION      @"em_revoke_notification"
/** @brief 待发送消息撤销的CMD消息action */
#define KEM_REVOKE                         @"em_revoke"
/** @brief 消息回撤cmd扩展字段,对应的value值为待撤销消息id */
#define KEM_REVOKE_MESSAGEID        @"em_revoke_messageId"
/** @brief 撤销消息时间间隔，单位:ms */
#define KEM_REVOKE_TIMEINTERVAL      60 * 2 * 1000

@interface MessageRevokeManager()<IChatManagerDelegate>

@property (nonatomic, assign) id<IChatManager> chatManager;

@end

@implementation MessageRevokeManager

+ (MessageRevokeManager *)sharedInstance{
    static MessageRevokeManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[MessageRevokeManager alloc] init];
    });
    
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self.chatManager addDelegate:self delegateQueue:nil];
    }
    return self;
}

#pragma mark - IChatManagerDelegate

- (void)didReceiveCmdMessage:(EMMessage *)cmdMessage
{
    NSArray *removeMessages = [[self handleReceiveCmdMessage:@[cmdMessage]] mutableCopy];
    if (removeMessages.count > 0)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:KEM_REVOKE_NOTIFICATION object:removeMessages];
    }
}

- (void)didReceiveOfflineCmdMessages:(NSArray *)offlineCmdMessages
{
    NSArray *removeMessages = [[self handleReceiveCmdMessage:offlineCmdMessages] mutableCopy];
    if (removeMessages.count > 0)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:KEM_REVOKE_NOTIFICATION object:removeMessages];
    }
}

#pragma mark - public

/**
 * 注册消息回撤完成后UI更新通知
 *
 */
- (void)registerNotification:(id)observer selector:(SEL)action
{
    [[NSNotificationCenter defaultCenter] addObserver:observer
                                             selector:action
                                                 name:KEM_REVOKE_NOTIFICATION object:nil];
}

/**
 * 释放消息回撤完成后UI更新通知
 *
 */
- (void)removeNotification:(id)observer
{
    [[NSNotificationCenter defaultCenter] removeObserver:observer
                                                    name:KEM_REVOKE_NOTIFICATION object:nil];
}

/**
 * 发送回撤cmd消息
 *
 * @param message 待撤销的消息
 */
+ (void)sendRevokeCMDMessage:(EMMessage *)message
{
    EMChatCommand *command = [[EMChatCommand alloc] init];
    command.cmd = KEM_REVOKE;
    EMCommandMessageBody *body = [[EMCommandMessageBody alloc] initWithChatObject:command];
    EMMessage *msg = [[EMMessage alloc] initWithReceiver:message.conversationChatter
                                                  bodies:@[body]];
    msg.messageType = message.messageType;
    msg.ext = @{KEM_REVOKE_MESSAGEID:message.messageId};
    [[EaseMob sharedInstance].chatManager asyncSendMessage:msg
                                                  progress:nil];
}

/**
 * 判断消息是否是消息回撤cmd消息
 *
 * @param message 待验证消息对象
 * @return 返回验证结果，YES代表此消息为消息撤销的cmd消息
 */
+ (BOOL)isRevokeCMDMessage:(EMMessage *)aMessage
{
    if (aMessage.messageBodies.count == 0) {
        return NO;
    }
    if (![aMessage.messageBodies.firstObject isKindOfClass:[EMCommandMessageBody class]])
    {
        return NO;
    }
    EMCommandMessageBody *body = (EMCommandMessageBody *)aMessage.messageBodies.firstObject;
    if (!body)
    {
        return NO;
    }
    return [body.action isEqualToString:KEM_REVOKE];
}

// 从cmd消息ext中得到被回撤的消息id
+ (NSString *)getRevokedMessageIdFromCmdMessageExt:(EMMessage *)cmdMessage
{
    if (cmdMessage.ext)
    {
        return cmdMessage.ext[KEM_REVOKE_MESSAGEID];
    }
    return nil;
}

/**
 * 验证消息是否符合撤销原则(如2分钟内发送)
 *
 * @param model 待验证消息
 * @return 判断结果, YES代表可以撤销
 */
+ (BOOL)canRevokeMessage:(EMMessage *)message
{
    //接收者不执行撤销
    if ([message.to isEqualToString:[MessageRevokeManager sharedInstance].account]) {
        return NO;
    }
    //长连接断开
    if (![[MessageRevokeManager sharedInstance].chatManager isConnected])
    {
        return NO;
    }
    BOOL isCanrevoke = NO;
    //检验是否可以撤销
    long long timestamp = message.timestamp;
    long long nowtimestamp = (long long)[[NSDate date] timeIntervalSince1970] * 1000;
    isCanrevoke = (nowtimestamp - timestamp) <= KEM_REVOKE_TIMEINTERVAL;
    return isCanrevoke;
}

#pragma mark - private

/**
 * 用于didReceiveCmdMessage及didReceiveOfflineCmdMessages回调，通过cmd消息获取会话中被撤销的消息
 *
 * @param cmdMessages 接收的cmd消息
 * @return 返回会话中被删除的消息
 */

- (NSArray *)handleReceiveCmdMessage:(NSArray *)cmdMessages
{
    NSMutableArray *removeMessages = [NSMutableArray array];//被删除的消息，通知返回页面，页面决定是否添加提示语
    for (EMMessage *cmdMessage in cmdMessages)
    {
        if (![MessageRevokeManager isRevokeCMDMessage:cmdMessage])
        {
            //不是含有消息撤销的cmd消息
            continue;
        }
        EMConversation *conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:cmdMessage.conversationChatter conversationType:(EMConversationType)cmdMessage.messageType];
        
        NSString *revokedMessageId = [MessageRevokeManager getRevokedMessageIdFromCmdMessageExt:cmdMessage];
        if (!revokedMessageId)
        {
            return nil;
        }
        EMMessage *message = [conversation loadMessageWithId:revokedMessageId];
        if (!message)
        {
            continue;
        }
        if ([conversation removeMessageWithId:message.messageId])
        {
            [removeMessages addObject:message];
        }
        if (!conversation.latestMessage)
        {
            [self.chatManager removeConversationByChatter:conversation.chatter
                                           deleteMessages:NO
                                              append2Chat:YES];
        }
    }
    return removeMessages;
}

#pragma mark - getter

- (NSString *)account
{
    return [[[EaseMob sharedInstance].chatManager loginInfo] objectForKey:kSDKUsername];
}

- (id<IChatManager>)chatManager
{
    return [EaseMob sharedInstance].chatManager;
}


@end
