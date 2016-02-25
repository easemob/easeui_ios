//
//  RemoveAfterReadManager.m
//  EaseUI
//
//  Created by WYZ on 16/2/24.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "RemoveAfterReadManager.h"

/** @brief 阅后即焚消息处理完成的通知 */
#define KEM_REMOVEAFTERREAD_NOTIFICATION   @"em_removeAfterRead_notification"
/** @brief 阅后即焚消息扩展字段 */
#define KEM_REMOVEAFTERREAD                @"em_readFire"
/** @brief 已读阅后即焚消息在NSUserDefaults保存的key前缀 */
#define KEM_REMOVEAFTERREAD_PREFIX         @"em_removeAfterReadSavePrefix"
/** @brief NSUserDefaults中保存当前已阅读但未发送ack回执的阅后即焚消息信息 */
#define NEED_REMOVE_MESSAGE_DIC            @"em_needRemoveMessages"
/** @brief NSUserDefaults中保存当前阅读的阅后即焚消息信息 */
#define NEED_REMOVE_CURRENT_MESSAGE        @"em_needRemoveCurrnetMessage"
//需要发送ack的阅后即焚消息信息在NSUserDefaults中的存放key
#define UserDefaultKey(username) [[KEM_REMOVEAFTERREAD_PREFIX stringByAppendingString:@"_"] stringByAppendingString:username]

@interface RemoveAfterReadManager () <IChatManagerDelegate>{
    dispatch_queue_t _queue;
}
@property (nonatomic, assign) id<IChatManager> chatManager;
@property (nonatomic, strong) NSDictionary *infoDic;
@property (nonatomic, strong) NSString *account;
@end

@implementation RemoveAfterReadManager

+ (RemoveAfterReadManager *)sharedInstance
{
    static RemoveAfterReadManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[RemoveAfterReadManager alloc] init];
    });
    
    return manager;
}

- (instancetype)init{
    if (self = [super init]) {
        _queue = dispatch_queue_create("com.removeAfterReadManager", DISPATCH_QUEUE_SERIAL);
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
    [self handleReceiveReceipt:resp];
}

#pragma mark - private

/**
 * 为指定消息发送已读回执，并把此消息在NSUserDefaults记录
 *
 * @param aMessage 已读的阅后即焚消息
 *
 */
- (void)sendRemoveMessageAction:(EMMessage *)aMessage
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(_queue, ^{
        if ([weakSelf isConnected]) {
            [weakSelf.chatManager sendReadAckForMessage:aMessage];
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            NSMutableDictionary *dic = [[userDefault objectForKey:UserDefaultKey(self.account)] mutableCopy];
            if (!dic) {
                dic = [[NSMutableDictionary alloc] init];
            }
            [dic removeObjectForKey:NEED_REMOVE_CURRENT_MESSAGE];
            [weakSelf updateInfoDic:dic];
        }else {
            [weakSelf addMessageToNeedRemoveDic:@[aMessage.conversationChatter,aMessage.messageId]];
        }
    });
}

/**
 * 为NSUserDefaults记录的已读阅后即焚消息发送ack回执，并删除该消息
 *
 */
- (void)sendAllNeedRemoveMessage
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(_queue, ^{
        if ([weakSelf isConnected]) {
            for (NSString *chatter in [weakSelf.needRemoveDic allKeys]) {
                EMConversation *conversation = [self.chatManager
                                                conversationForChatter:chatter
                                                conversationType:eConversationTypeChat];
                
                NSArray *msgs = [conversation loadMessagesWithIds:weakSelf.needRemoveDic[chatter]];
                for (EMMessage *msg in msgs) {
                    [weakSelf.chatManager sendReadAckForMessage:msg];
                    [conversation removeMessage:msg];
                }
                if (!conversation.latestMessage)
                {
                    [weakSelf.chatManager removeConversationByChatter:conversation.chatter
                                                   deleteMessages:NO
                                                      append2Chat:YES];
                }
            }
            [weakSelf clearNeedRemoveDic];
        }
    });
}

/**
 * 将指定消息信息加入到待发送ack阅后即焚消息字典中
 *
 * @param messageInfo 指定的消息信息，数组长度为2，第一个元素为消息所在会话的chatter，第二个元素为消息id
 *
 */
- (void)addMessageToNeedRemoveDic:(NSArray *)messageInfo
{
    if (!messageInfo || messageInfo.count != 2)
    {
        return;
    }
    NSMutableDictionary *needRemoveDic = [[self needRemoveDic] mutableCopy];
    if (!needRemoveDic) {
        needRemoveDic = [[NSMutableDictionary alloc] init];
    }
    NSMutableArray *needRemoveAry = [needRemoveDic[messageInfo.firstObject] mutableCopy];
    if (!needRemoveAry) {
        needRemoveAry = [[NSMutableArray alloc] init];
    }
    [needRemoveAry addObject:messageInfo.lastObject];
    needRemoveDic[messageInfo.firstObject] = needRemoveAry;
    NSMutableDictionary *dic = [self.infoDic mutableCopy];
    dic[NEED_REMOVE_MESSAGE_DIC] = needRemoveDic;
    NSArray *currentMessageInfo = [dic[NEED_REMOVE_CURRENT_MESSAGE] mutableCopy];
    if (currentMessageInfo && currentMessageInfo.count == 2)
    {//如果已存储的 当前阅读消息，与传入的相同，则清除(此时 信息已经转存到 待发送ack的消息字典中)
        if ([currentMessageInfo.firstObject isEqualToString:messageInfo.firstObject] &&
            [currentMessageInfo.lastObject isEqualToString:messageInfo.lastObject])
        {
            [dic removeObjectForKey:NEED_REMOVE_CURRENT_MESSAGE];
        }
    }
    [self updateInfoDic:dic];
}

- (NSArray *)currentMsg
{
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
 * 更新self.infoDic属性，并更新userDefaults中当前用户存储的关于阅后即焚数据
 *
 */
- (void)updateInfoDic:(NSDictionary *)dic{
    @synchronized(self) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        if (dic) {
            [userDefaults setObject:dic forKey:UserDefaultKey(self.account)];
        }else {
            [userDefaults removeObjectForKey:UserDefaultKey(self.account)];
        }
        [userDefaults synchronize];
        self.infoDic = dic;
    }
}

/**
 * 处理接收到的阅后即焚消息ACK回执,针对于发送者而言
 *
 * @param resp ACK回执
 *
 */
- (void)handleReceiveReceipt:(EMReceipt *)resp
{
    EMConversation *conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:resp.conversationChatter
                                                                               conversationType:eConversationTypeChat];
    if (!conversation)
    {
        return;
    }
    EMMessage *message = [conversation loadMessageWithId:resp.chatId];
    
    if (![RemoveAfterReadManager isRemoveAfterReadMessage:message])
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
        [[NSNotificationCenter defaultCenter] postNotificationName:KEM_REMOVEAFTERREAD_NOTIFICATION object:messages];
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
                                                 name:KEM_REMOVEAFTERREAD_NOTIFICATION object:nil];
}

/**
 * 释放阅后即焚消息处理完成后UI更新通知
 *
 */
- (void)removeNotification:(id)observer
{
    [[NSNotificationCenter defaultCenter] removeObserver:observer
                                                    name:KEM_REMOVEAFTERREAD_NOTIFICATION object:nil];
}

/**
 * 验证消息是否为阅后即焚消息
 *
 * @param aMessage 待验证消息
 * @return 判断结果, YES代表待验证消息为阅后即焚类型
 */
+ (BOOL)isRemoveAfterReadMessage:(EMMessage *)aMessage{
    return [[aMessage.ext objectForKey:KEM_REMOVEAFTERREAD] boolValue];
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
 * 构造阅后即焚消息的ext
 *
 * @param originalExt 待发消息的ext
 * @return 携带阅后即焚信息的扩展
 */
+ (NSDictionary *)structureRemoveAfterReadMessageExt:(NSDictionary *)originalExt
{
    NSMutableDictionary *ext = [originalExt mutableCopy];
    if (!ext)
    {
        ext = [NSMutableDictionary dictionary];
    }
    [ext setObject:@YES forKey:KEM_REMOVEAFTERREAD];
    return ext;
}

/**
 * 聊天页面,被选中阅后即焚消息处理
 *
 * @param message 待处理消息
 *
 */
- (void)handleRemoveAfterReadMessage:(EMMessage *)message
{
    if (!message) {
        return;
    }
    EMConversation *conversation = [self.chatManager conversationForChatter:message.conversationChatter conversationType:(EMConversationType)message.messageType];
    if (!conversation) {
        return;
    }
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
                [[NSNotificationCenter defaultCenter] postNotificationName:KEM_REMOVEAFTERREAD_NOTIFICATION object:messages];
            }
        }
        else {
            [self addMessageToNeedRemoveDic:@[message.conversationChatter,message.messageId]];
            NSArray *messages = [NSArray arrayWithObjects:message, nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:KEM_REMOVEAFTERREAD_NOTIFICATION object:messages];
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
