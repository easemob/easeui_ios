//
//  EaseMessageAppreciationHelper.m
//  EaseUI
//
//  Created by dujiepeng on 16/1/25.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EaseMessageAppreciationHelper.h"

/** @brief 消息回撤处理完成的通知 */
#define KEM_REVOKERELOAD_NOTIFICATION      @"em_revokeReload_notification"
/** @brief 待发送消息撤销的CMD消息action */
#define KEMMESSAGE_REVOKE                  @"em_revoke"
/** @brief 消息回撤cmd扩展字段,对应的value值为待撤销消息id */
#define KEMMESSAGE_REVOKE_MESSAGEID        @"em_revoke_messageId"
/** @brief 撤销消息时间间隔，单位:ms */
#define REVOKE_TIMEINTERVAL      60 * 2 * 1000


/** @brief 阅后即焚消息处理完成的通知 */
#define KEM_AFTERREADRELOAD_NOTIFICATION   @"em_afterReadReload_notification"
/** @brief 阅后即焚消息扩展字段 */
#define KEMMESSAGE_READFIRE                @"em_readFire"
/** @brief 已读阅后即焚消息在NSUserDefaults保存的key前缀 */
#define KEM_READFIRE_PREFIX                @"readFirePrefix"
/** @brief NSUserDefaults中保存当前已阅读但未发送ack回执的阅后即焚消息信息 */
#define NEED_REMOVE_MESSAGE_DIC            @"em_needRemoveMessages"
/** @brief NSUserDefaults中保存当前阅读的阅后即焚消息信息 */
#define NEED_REMOVE_CURRENT_MESSAGE        @"em_needRemoveCurrnetMessage"
//需要发送ack的阅后即焚消息信息在NSUserDefaults中的存放key
#define UserDefaultKey(username) [[KEM_READFIRE_PREFIX stringByAppendingString:@"_"] stringByAppendingString:username]


@interface MessageRevokeManager()<IChatManagerDelegate>

@property (nonatomic, assign) id<IChatManager> chatManager;

@end

@implementation MessageRevokeManager
{
    dispatch_queue_t _queue;
}

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
        _queue = dispatch_queue_create("com.revokeMessage", DISPATCH_QUEUE_SERIAL);
        [self.chatManager addDelegate:self delegateQueue:nil];
    }
    return self;
}

#pragma mark - IChatManagerDelegate

- (void)didReceiveCmdMessage:(EMMessage *)cmdMessage
{
    NSArray *removeMessages = [[self revokeMessages:@[cmdMessage]] mutableCopy];
    [[NSNotificationCenter defaultCenter] postNotificationName:KEM_REVOKERELOAD_NOTIFICATION object:removeMessages];
}

- (void)didReceiveOfflineCmdMessages:(NSArray *)offlineCmdMessages
{
    NSArray *removeMessages = [[self revokeMessages:offlineCmdMessages] mutableCopy];
    [[NSNotificationCenter defaultCenter] postNotificationName:KEM_REVOKERELOAD_NOTIFICATION object:removeMessages];
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
                                                 name:KEM_REVOKERELOAD_NOTIFICATION object:nil];
}

/**
 * 释放消息回撤完成后UI更新通知
 *
 */
- (void)removeNotification:(id)observer
{
    [[NSNotificationCenter defaultCenter] removeObserver:observer
                                                    name:KEM_REVOKERELOAD_NOTIFICATION object:nil];
}

/**
 * 发送回撤cmd消息
 *
 * @param aChatter 对应会话的chatter
 * @param aMessageId 待撤销消息的id
 */
+ (void)sendRevokeMessageToChatter:(NSString *)aChatter
                         messageId:(NSString *)aMessageId
                  conversationType:(EMConversationType)conversationType
{
    EMChatCommand *command = [[EMChatCommand alloc] init];
    command.cmd = KEMMESSAGE_REVOKE;
    EMCommandMessageBody *body = [[EMCommandMessageBody alloc] initWithChatObject:command];
    EMMessage *msg = [[EMMessage alloc] initWithReceiver:aChatter
                                                  bodies:@[body]];
    msg.messageType = [MessageRevokeManager messageType:conversationType];
    msg.ext = @{KEMMESSAGE_REVOKE_MESSAGEID:aMessageId};
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
    EMCommandMessageBody *body = (EMCommandMessageBody *)[aMessage.messageBodies firstObject];
    if (!body)
    {
        return NO;
    }
    return [body.action isEqualToString:KEMMESSAGE_REVOKE];
}

// 得到要回撤的消息id
+ (NSString *)needRevokeMessageId:(EMMessage *)aMessage
{
    NSString *messageId = aMessage.ext[KEMMESSAGE_REVOKE_MESSAGEID];
    return messageId;
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
    isCanrevoke = (nowtimestamp - timestamp) <= REVOKE_TIMEINTERVAL;
    return isCanrevoke;
}

#pragma mark - private

/**
 * 获取消息类型
 *
 * @param conversationType 会话类型
 * @return 对应消息类型
 */
+ (EMMessageType)messageType:(EMConversationType)conversationType
{
    EMMessageType type = eMessageTypeChat;
    switch (conversationType)
    {
        case eConversationTypeChat:
            type = eMessageTypeChat;
            break;
        case eConversationTypeGroupChat:
            type = eMessageTypeGroupChat;
            break;
        case eConversationTypeChatRoom:
            type = eMessageTypeChatRoom;
            break;
        default:
            break;
    }
    return type;
}

/**
 * 获取cmd消息，处理消息撤销
 *
 * @param cmdMessages 接收的cmd消息
 * @return 返回被删除的消息
 */
- (NSArray *)revokeMessages:(NSArray *)cmdMessages
{
    NSMutableArray *removeMessages = [NSMutableArray array];//被删除的消息，通知返回页面，前台决定是否添加提示语
    for (EMMessage *cmdMessage in cmdMessages)
    {
        if (![MessageRevokeManager isRevokeCMDMessage:cmdMessage])
        {
            //不是撤销cmd
            continue;
        }
        EMConversation *conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:cmdMessage.conversationChatter conversationType:(EMConversationType)cmdMessage.messageType];
        
        EMMessage *message = [conversation loadMessageWithId:[MessageRevokeManager needRevokeMessageId:cmdMessage]];
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

@interface RemoveAfterReadManager () <IChatManagerDelegate>{
    dispatch_queue_t _queue;
}
@property (nonatomic, assign) id<IChatManager> chatManager;
@property (nonatomic, strong) NSDictionary *infoDic;
@property (nonatomic, strong) NSString *account;
@end

@implementation RemoveAfterReadManager

+ (RemoveAfterReadManager *)sharedInstance{
    static RemoveAfterReadManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[RemoveAfterReadManager alloc] init];
    });
    
    return manager;
}

- (instancetype)init{
    if (self = [super init]) {
        _queue = dispatch_queue_create("com.removeafterread", DISPATCH_QUEUE_SERIAL);
        [self.chatManager addDelegate:self delegateQueue:nil];
        [self addMessageToNeedRemoveDic:[self currentMsg]];
        [self sendAllNeedRemoveMessage];
    }
    
    return self;
}

#pragma mark - IChatManagerDelegate

- (void)didAutoReconnectFinishedWithError:(NSError *)error{
    if (!error) {
        [self sendAllNeedRemoveMessage];
    }
}

- (void)didAutoLoginWithInfo:(NSDictionary *)loginInfo
                       error:(EMError *)error{
    if (!error) {
        [self sendAllNeedRemoveMessage];
    }
}

-(void)didLogoffWithError:(EMError *)error{
    if (!error) {
        self.infoDic = nil;
        self.account = nil;
    }
}

- (void)didReceiveHasReadResponse:(EMReceipt *)resp
{
    [self fireMessagesFromData:resp];
}

#pragma mark - private

/**
 * 为指定消息发送已读回执，并把此消息在NSUserDefaults记录
 *
 * @param aMessage 已读的阅后即焚消息
 *
 */
- (void)sendRemoveMessageAction:(EMMessage *)aMessage{
    dispatch_sync(_queue, ^{
        if ([self isConnected]) {
            [self.chatManager sendReadAckForMessage:aMessage];
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            NSMutableDictionary *dic = [[userDefault objectForKey:UserDefaultKey(self.account)] mutableCopy];
            if (!dic) {
                dic = [[NSMutableDictionary alloc] init];
            }
            [dic removeObjectForKey:NEED_REMOVE_CURRENT_MESSAGE];
            [userDefault setObject:dic forKey:UserDefaultKey(self.account)];
            [self clearCurrentMsg];
        }else {
            [self addMessageToNeedRemoveDic:@[aMessage.conversationChatter,aMessage.messageId]];
        }
    });
}

/**
 * 为NSUserDefaults记录的已读阅后即焚消息发送ack回执，并删除该消息
 *
 */
- (void)sendAllNeedRemoveMessage{
    dispatch_sync(_queue, ^{
        if ([self isConnected]) {
            for (NSString *chatter in [self.needRemoveDic allKeys]) {
                EMConversation *conversation = [self.chatManager
                                                conversationForChatter:chatter
                                                conversationType:eConversationTypeChat];
                
                NSArray *msgs = [conversation loadMessagesWithIds:self.needRemoveDic[chatter]];
                for (EMMessage *msg in msgs) {
                    [self.chatManager sendReadAckForMessage:msg];
                    [conversation removeMessage:msg];
                }
                if (!conversation.latestMessage)
                {
                    [self.chatManager removeConversationByChatter:conversation.chatter
                                                   deleteMessages:NO
                                                      append2Chat:YES];
                }
            }
            [self clearNeedRemoveDic];
        }
    });
}

/**
 * 将指定消息信息加入到待发送ack阅后即焚消息字典中
 *
 * @param msg 指定的消息信息，数组长度为2，第一个元素为消息所在会话的chatter，第二个元素为消息id
 *
 */
- (void)addMessageToNeedRemoveDic:(NSArray *)msg
{
    if (!msg)
    {
        return;
    }
    NSMutableDictionary *needRemoveDic = [[self needRemoveDic] mutableCopy];
    if (!needRemoveDic) {
        needRemoveDic = [[NSMutableDictionary alloc] init];
    }
    NSMutableArray *needRemoveAry = [needRemoveDic[msg.firstObject] mutableCopy];
    if (!needRemoveAry) {
        needRemoveAry = [[NSMutableArray alloc] init];
    }
    [needRemoveAry addObject:msg.lastObject];
    needRemoveDic[msg.firstObject] = needRemoveAry;
    NSMutableDictionary *dic = [self.infoDic mutableCopy];
    dic[NEED_REMOVE_MESSAGE_DIC] = needRemoveDic;
    [dic removeObjectForKey:NEED_REMOVE_CURRENT_MESSAGE];
    [self updateInfoDic:dic];
}

- (NSArray *)currentMsg{
    return self.infoDic[NEED_REMOVE_CURRENT_MESSAGE];
}

/**
 * 清除需要发送ack消息的记录
 *
 */
- (void)clearNeedRemoveDic{
    NSMutableDictionary *dic = [self.infoDic mutableCopy];
    [dic removeObjectForKey:NEED_REMOVE_MESSAGE_DIC];
    [self updateInfoDic:dic];
}

/**
 * 清除当前正在阅读的消息记录
 *
 */
- (void)clearCurrentMsg{
    NSMutableDictionary *dic = [self.infoDic mutableCopy];
    [dic removeObjectForKey:NEED_REMOVE_CURRENT_MESSAGE];
    [self updateInfoDic:dic];
}

- (void)updateInfoDic:(NSDictionary *)dic{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (dic) {
        [userDefaults setObject:dic forKey:UserDefaultKey(self.account)];
    }else {
        [userDefaults removeObjectForKey:UserDefaultKey(self.account)];
    }
    self.infoDic = dic;
}

/**
 * 会话列表页面，处理接收到的阅后即焚消息ACK回执,针对于发送者而言
 *
 * @param resp ACK回执
 *
 */
- (void)fireMessagesFromData:(EMReceipt *)resp
{
    EMConversation *conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:resp.conversationChatter
                                                                               conversationType:eConversationTypeChat];
    if (!conversation)
    {
        return;
    }
    EMMessage *message = [conversation loadMessageWithId:resp.chatId];
    
    if (![RemoveAfterReadManager isReadAfterRemoveMessage:message])
    {
        return;
    }
    if ([conversation removeMessage:message])
    {
        if (!conversation.latestMessage) {
            [self.chatManager removeConversationByChatter:resp.conversationChatter
                                           deleteMessages:NO
                                              append2Chat:YES];
        }
        NSArray *messages = [NSArray arrayWithObjects:message, nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:KEM_AFTERREADRELOAD_NOTIFICATION object:messages];
    }
}


#pragma mark - public

/**
 * 注册阅后即焚消息处理完成后UI更新通知
 *
 */
- (void)registerNotification:(id)observer selector:(SEL)action
{
    [[NSNotificationCenter defaultCenter] addObserver:observer
                                             selector:action
                                                 name:KEM_AFTERREADRELOAD_NOTIFICATION object:nil];
}

/**
 * 释放阅后即焚消息处理完成后UI更新通知
 *
 */
- (void)removeNotification:(id)observer
{
    [[NSNotificationCenter defaultCenter] removeObserver:observer
                                                    name:KEM_AFTERREADRELOAD_NOTIFICATION object:nil];
}

/**
 * 验证消息是否为阅后即焚消息
 *
 * @param aMessage 待验证消息
 * @return 判断结果, YES代表待验证消息为阅后即焚类型
 */
+ (BOOL)isReadAfterRemoveMessage:(EMMessage *)aMessage{
    return [[aMessage.ext objectForKey:KEMMESSAGE_READFIRE] boolValue];
}

/**
 * 保存正在读取的消息
 *
 * @param aMessage 正在读取的消息
 */
- (void)updateCurrentMsg:(EMMessage *)aMessage{
    NSMutableDictionary *dic = [self.infoDic mutableCopy];
    if (!dic) {
        dic = [[NSMutableDictionary alloc] init];
    }
    dic[NEED_REMOVE_CURRENT_MESSAGE] = @[aMessage.conversationChatter,aMessage.messageId];
    [self updateInfoDic:dic];
}

/**
 * 为普通消息添加阅后即焚扩展成为阅后即焚类型消息
 *
 * @param aMessage 待发送的消息
 * @return 携带阅后即焚扩展的待发送消息
 */
- (EMMessage *)setupToNeedRemoveMessage:(EMMessage *)aMessage{
    NSMutableDictionary *dic = [aMessage.ext mutableCopy];
    if (!dic) {
        dic = [[NSMutableDictionary alloc] init];
    }
    [dic setObject:@YES forKey:KEMMESSAGE_READFIRE];
    aMessage.ext = [dic copy];
    return aMessage;
}

/**
 * 聊天页面,触发消息焚毁,处理阅读即焚消息
 *
 * @param model 待处理消息
 *
 */
- (void)readFireMessageDeal:(EMMessage *)message
{
    if (!message) {
        return;
    }
    EMConversation *conversation = [self.chatManager conversationForChatter:message.conversationChatter conversationType:(EMConversationType)message.messageType];
    if (![message.from isEqualToString:self.account])
    {
        //如果是消息接收者，要发送ack，消息发送者只需要接收到ack删除消息
        if ([self isConnected])
        {
            if ([conversation removeMessageWithId:message.messageId])
            {
                [conversation markMessageWithId:message.messageId asRead:YES];
                [self sendRemoveMessageAction:message];
                NSArray *messages = [NSArray arrayWithObjects:message, nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:KEM_AFTERREADRELOAD_NOTIFICATION object:messages];
            }
        }
        else {
            [self addMessageToNeedRemoveDic:@[message.conversationChatter,message.messageId]];
            NSArray *messages = [NSArray arrayWithObjects:message, nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:KEM_AFTERREADRELOAD_NOTIFICATION object:messages];
        }
    }
}

#pragma mark - getter

- (BOOL)isConnected{
    return [self.chatManager isConnected];
}

- (NSString *)account{
    return [[self.chatManager loginInfo] objectForKey:kSDKUsername];
}

- (NSDictionary *)infoDic{
    if (!_infoDic) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        _infoDic = [userDefaults objectForKey:UserDefaultKey(self.account)];
    }
    
    return _infoDic;
}

- (id<IChatManager>)chatManager{
    return [EaseMob sharedInstance].chatManager;
}

- (NSDictionary *)needRemoveDic{
    return [self.infoDic objectForKey:NEED_REMOVE_MESSAGE_DIC];
}



@end
