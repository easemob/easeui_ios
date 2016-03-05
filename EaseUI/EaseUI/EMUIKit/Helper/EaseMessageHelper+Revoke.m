//
//  EaseMessageHelper+Revoke.m
//  EaseUI
//
//  Created by WYZ on 16/2/17.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EaseMessageHelper+Revoke.h"
#import "EaseMessageHelper+GroupAt.h"

/** @brief 待发送消息撤销的CMD消息action */
#define KEM_REVOKE                  @"em_revoke"
/** @brief 消息回撤cmd扩展字段,对应的value值为待撤销消息id */
#define KEM_REVOKE_MESSAGEID        @"em_revoke_messageId"
/** @brief 撤销消息时间间隔，单位:ms */
#define KEM_REVOKE_TIMEINTERVAL      60 * 2 * 1000

@implementation EaseMessageHelper (Revoke)

#pragma mark - public

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
    if (aMessage.messageBodies.count == 0)
    {
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

/**
 * 验证消息是否符合撤销原则(如2分钟内发送)
 *
 * @param model 待验证消息
 * @return 判断结果, YES代表可以撤销
 */
+ (BOOL)canRevokeMessage:(EMMessage *)message
{
    //接收者不执行撤销
    if ([message.to isEqualToString:[EaseMessageHelper sharedInstance].account]) {
        return NO;
    }
    //长连接断开
    if (![[EaseMessageHelper sharedInstance].chatManager isConnected])
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
 * 获取cmd消息，处理消息撤销
 *
 * @param cmdMessages 接收的cmd消息
 * @return 返回被删除的消息
 */
- (EMMessage *)handleReceiveRevokeCmdMessage:(EMMessage *)cmdMessage
{
    if (![EaseMessageHelper isRevokeCMDMessage:cmdMessage])
    {//不是撤销cmd
        return nil;
    }
    EMConversation *conversation = [self.chatManager conversationForChatter:cmdMessage.conversationChatter conversationType:(EMConversationType)cmdMessage.messageType];
    
    NSString *messageId = [EaseMessageHelper getRevokedMessageIdFromCmdMessageExt:cmdMessage];
    if (!messageId) {
        return nil;
    }
    EMMessage *message = [conversation loadMessageWithId:messageId];
    if (!message)
    {
        //该会话无对应的消息
        return nil;
    }
    BOOL isRemoveSuccess = [conversation removeMessageWithId:message.messageId];
    if (!conversation.latestMessage)
    {
        //先删除会话ext中群组相关的字段
        if ([EaseMessageHelper isConversationHasUnreadGroupAtMessage:conversation])
        {
            [EaseMessageHelper updateConversationToDB:conversation message:nil isUnread:NO];
        }
        [self.chatManager removeConversationByChatter:conversation.chatter
                                       deleteMessages:NO
                                          append2Chat:YES];
    }
    if (isRemoveSuccess)
    {//删除成功
        return message;
    }
    return nil;
}

@end

