//
//  EaseMessageHelper+GroupAt.m
//  EaseUI
//
//  Created by WYZ on 16/2/16.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EaseMessageHelper+GroupAt.h"
#import "EaseConvertToCommonEmoticonsHelper.h"
#import <objc/runtime.h>

static char groupOccupantIdListKey;

#define KEM_GROUP_AT_MESSAGEID                     @"em_group_at_messageId"



@interface EaseMessageHelper()

@property (nonatomic, strong) NSMutableArray *occupantIdList;

@end

@implementation EaseMessageHelper (GroupAt)

#pragma mark - gettter
- (NSMutableArray *)occupantIdList
{
    return objc_getAssociatedObject(self, &groupOccupantIdListKey);
}


#pragma mark - setter
- (void)setOccupantIdList:(NSMutableArray *)occupantIdList
{
    objc_setAssociatedObject(self, &groupOccupantIdListKey, occupantIdList, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - public

/**
 * 构造群组@消息的ext
 *
 * @param originalExt 待发消息的ext
 * @return 携带阅后即焚信息的扩展
 */
+ (NSDictionary *)structureGroupAtMessageExt:(NSDictionary *)originalExt
{
    NSMutableDictionary *ext = [originalExt mutableCopy];
    if (!ext)
    {
        ext = [NSMutableDictionary dictionary];
    }
    NSArray *occupantIdList = [[EaseMessageHelper fetchSelectOccupantIdList] mutableCopy];
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:occupantIdList options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [ext setObject:jsonString forKey:KEM_GROUP_AT_MEMBERS];
    [EaseMessageHelper markSelectOccupantId:nil];
    [[EaseMessageHelper sharedInstance] setEmHelperType:emHelperTypeDefault];
    return ext;
}

/**
 * 验证消息是否待遇群组@功能
 *
 * @param model 待验证消息
 * @return 判断结果, YES代表消息含有群组@功能
 */
+ (BOOL)isGroupAtMessage:(EMMessage *)message
{
    if (message.ext[KEM_GROUP_AT_MEMBERS] &&
        message.chatType != EMChatTypeChat)
    {
        NSString *jsonString = message.ext[KEM_GROUP_AT_MEMBERS];
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSArray *occupantIdList = (NSArray *)[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        if (occupantIdList.count > 0 && !error)
        {
            return YES;
        }
        else {
            return NO;
        }
    }
    return NO;
}

/*
 * 为本类中occupantId赋值，记录被选中的群组成员
 * @param occupantId 被选中的群组成员Id
 *
 */
+ (void)markSelectOccupantId:(NSString *)occupantId
{
    if (!occupantId) {
        [EaseMessageHelper sharedInstance].occupantIdList = nil;
        return;
    }
    if ([EaseMessageHelper sharedInstance].occupantIdList.count == 0) {
        [EaseMessageHelper sharedInstance].occupantIdList = [NSMutableArray array];
    }
    [[EaseMessageHelper sharedInstance].occupantIdList addObject:occupantId];
}

+ (void)removeOccupantIdByIndex:(NSUInteger)index
{
    [[EaseMessageHelper sharedInstance].occupantIdList removeObjectAtIndex:index];
    if ([EaseMessageHelper sharedInstance].occupantIdList.count == 0)
    {
        [EaseMessageHelper sharedInstance].occupantIdList = nil;
        [EaseMessageHelper sharedInstance].emHelperType = emHelperTypeDefault;
    }
}

/*
 * 获取被选中的群组成员id
 *
 * @return 被选中的群组成员Id
 *
 */
+ (NSArray *)fetchSelectOccupantIdList
{
    return [EaseMessageHelper sharedInstance].occupantIdList;
}

/*
 * 为指定的会话更新ext扩展属性
 *
 * @param conversation 指定的扩展
 * @param message 群组@当前用户的消息
 * @param isUnread 是否未读
 * @return 被选中的群组成员Id
 */
+ (void)updateConversationToDB:(EMConversation *)conversation message:(EMMessage *)message isUnread:(BOOL)isUnread
{
    if (conversation.type == EMConversationTypeChat)
    {//单聊不执行群组操作
        return;
    }
    NSMutableDictionary *_ext = [conversation.ext mutableCopy];
    if (!_ext)
    {
        _ext = [NSMutableDictionary dictionary];
    }
    if (isUnread && message && message.ext[KEM_GROUP_AT_MEMBERS])
    {
        [_ext setObject:message.messageId forKey:KEM_GROUP_AT_MESSAGEID];
    }
    else {
        [_ext removeObjectForKey:KEM_GROUP_AT_MESSAGEID];
    }
    conversation.ext = [_ext copy];
    [conversation updateConversationExtToDB];
}

/*
 * 验证指定会话扩展字典中是否含有的未读群组@当前用户的消息
 * @param conversation 待验证会话
 * @return 返回会话是否含有未读的针对当前用户的群组@消息
 */
+ (BOOL)isConversationHasUnreadGroupAtMessage:(EMConversation *)conversation
{
    if (!conversation) {
        return NO;
    }
    if (conversation.type == EMConversationTypeChat) {
        return NO;
    }
    if (conversation.ext[KEM_GROUP_AT_MESSAGEID])
    {
        return YES;
    }
    return NO;
}

/*
 * 获取会话中 当前用户最近被群组@消息的发送者username
 * @param conversation 指定的会话
 * @return 群组@当前用户最近消息的发送者username
 */
+ (NSString *)getLatestGroupAtMessageSenderName:(EMConversation *)conversation
{
    if (!conversation) {
        return nil;
    }
    if (conversation.type == EMConversationTypeChat) {
        return nil;
    }
    NSString *messageId = conversation.ext[KEM_GROUP_AT_MESSAGEID];
    EMMessage *message = [conversation loadMessageWithId:messageId];
    if (!message) {
        return nil;
    }
    return message.from;
}

//验证指定消息是否为群组@当前用户
+ (BOOL)isGroupAtCurrentUserByMessage:(EMMessage *)message
{
    if (![EaseMessageHelper isGroupAtMessage:message])
    {
        return NO;
    }
    if (message.chatType != EMChatTypeChat &&
        message.ext[KEM_GROUP_AT_MEMBERS])
    {
        NSString *jsonString = message.ext[KEM_GROUP_AT_MEMBERS];
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSArray *occupantIdList = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        if (occupantIdList.count > 0 && !error)
        {
            if ([occupantIdList containsObject:[EaseMessageHelper sharedInstance].account])
            {
                return YES;
            }
        }
        return NO;
    }
    return NO;
}

#pragma mark - private

@end
