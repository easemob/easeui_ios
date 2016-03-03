//
//  EaseMessageHelper+GroupAt.h
//  EaseUI
//
//  Created by WYZ on 16/2/16.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EaseMessageHelper.h"

/** @brief 扩展字段，被选中@的群组成员id */
#define KEM_GROUP_AT_MEMBERS       @"em_group_at_members"

@interface EaseMessageHelper (GroupAt)


/**
 * 构造群组@消息的ext
 *
 * @param originalExt 待发消息的ext
 * @return 携带阅后即焚信息的扩展
 */
+ (NSDictionary *)structureGroupAtMessageExt:(NSDictionary *)originalExt;


/**
 * 验证消息是否含有群组@功能
 *
 * @param model 待验证消息
 * @return 判断结果, YES代表消息含有群组@功能
 */
+ (BOOL)isGroupAtMessage:(EMMessage *)message;

//标记被选中的群组成员id
+ (void)markSelectOccupantId:(NSString *)occupantId;

//获取被选中组员id
+ (NSArray *)fetchSelectOccupantIdList;

+ (void)removeOccupantIdByIndex:(NSUInteger)index;

//未指定的会话更新ext扩展
+ (void)updateConversationToDB:(EMConversation *)conversation message:(EMMessage *)message isUnread:(BOOL)isUnread;

//验证指定会话扩展字典中是否含有的未读群组@状态
+ (BOOL)isConversationHasUnreadGroupAtMessage:(EMConversation *)conversation;

//获取会话中 当前用户最近被群组@消息的发送者username
+ (NSString *)getLatestGroupAtMessageSenderName:(EMConversation *)conversation;

//验证指定消息是否为群组@当前用户
+ (BOOL)isGroupAtCurrentUserByMessage:(EMMessage *)message conversation:(EMConversation *)conversation;

@end
