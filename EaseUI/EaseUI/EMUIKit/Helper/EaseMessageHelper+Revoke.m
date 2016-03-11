//
//  EaseMessageHelper+Revoke.m
//  EaseUI
//
//  Created by WYZ on 16/2/17.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EaseMessageHelper+Revoke.h"
#import <objc/runtime.h>

/** @brief 待发送消息撤销的CMD消息action */
#define KEM_REVOKE                  @"em_revoke"
/** @brief 消息回撤cmd扩展字段,对应的value值为待撤销消息id */
#define KEM_REVOKE_MESSAGEID        @"em_revoke_messageId"
/** @brief 撤销消息时间间隔，单位:ms */
#define KEM_REVOKE_TIMEINTERVAL      60 * 2 * 1000

static char revokePromptValidKey;

@interface EaseMessageHelper()

@property (nonatomic, strong) NSNumber *revokePromptIsValid;  //对应为BOOL

@end

@implementation EaseMessageHelper (Revoke)

#pragma mark - getter
- (NSNumber *)revokePromptIsValid
{
    return objc_getAssociatedObject(self, &revokePromptValidKey);
}

#pragma mark - setter

- (void)setRevokePromptIsValid:(NSNumber *)revokePromptIsValid
{
    objc_setAssociatedObject(self, &revokePromptValidKey, revokePromptIsValid, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - public

/**
 * 开启消息回撤后的文字提示功能
 *
 */
+ (void)openRevokePrompt
{
    [EaseMessageHelper sharedInstance].revokePromptIsValid = [NSNumber numberWithBool:YES];
}

/**
 * 关闭消息回撤后的文字提示功能
 *
 */
+ (void)closeRevokePrompt
{
    [EaseMessageHelper sharedInstance].revokePromptIsValid = [NSNumber numberWithBool:NO];
}

/**
 * 消息回撤后文字提示功能是否可用
 *
 * @return 判断结果, YES代表消息回撤后文字提示功能可用
 */
+ (BOOL)revokePromptIsValid
{
    BOOL isvalid = [[EaseMessageHelper sharedInstance].revokePromptIsValid boolValue];
    return isvalid;
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

+ (EMMessage *)insertRevokePromptMessageToDB:(EMMessage *)message
{
    NSString *prompt = [EaseMessageHelper prompt:message];//提示语
    EMMessage *newMessage = [EaseMessageHelper promptMessage:prompt oldMessage:message];
    if ([[EaseMob sharedInstance].chatManager insertMessageToDB:newMessage append2Chat:YES])
    {
        return newMessage;
    }
    return nil;
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
- (EMMessage *)handleReceivedRevokeCmdMessage:(EMMessage *)cmdMessage
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
    if (!conversation.latestMessage && ![EaseMessageHelper revokePromptIsValid])
    {
        //会话没有消息 且 用户为设置消息撤销提示，则删除空的会话
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

//撤销的提示语
+ (NSString *)prompt:(EMMessage *)message
{
    NSString *prompt = @"撤消了一条消息";
    NSString *account = [[[EaseMob sharedInstance].chatManager loginInfo] objectForKey:kSDKUsername];
    if ([message.from isEqualToString:account])
    {
        prompt = [@"您" stringByAppendingString:prompt];
    }
    else if (message.messageType == eMessageTypeChat)
    {
        prompt = [message.from stringByAppendingString:prompt];
    }
    else {
        prompt = [message.groupSenderName stringByAppendingString:prompt];
    }
    return prompt;
}

+ (EMMessage *)promptMessage:(NSString *)prompt
                  oldMessage:(EMMessage *)oldMessage
{
    EMChatText *textChat = [[EMChatText alloc] init];
    textChat.text = prompt;
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithChatObject:textChat];
    EMMessage *message = [[EMMessage alloc] initWithReceiver:oldMessage.conversationChatter bodies:@[body]];
    message.timestamp = oldMessage.timestamp;
    message.messageType = oldMessage.messageType;
    message.requireEncryption = NO;
    message.isRead = YES;
    message.isReadAcked = YES;
    message.isDeliveredAcked = YES;
    message.deliveryState = eMessageDeliveryState_Delivered;
    message.ext = [NSDictionary dictionaryWithObjectsAndKeys:@YES, @"em_revoke_extKey_revokePrompt", nil];
    return message;
}

@end

