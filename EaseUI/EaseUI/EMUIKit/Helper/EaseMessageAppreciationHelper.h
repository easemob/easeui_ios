//
//  EaseMessageAppreciationHelper.h
//  EaseUI
//
//  Created by dujiepeng on 16/1/25.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EaseMob.h"

@interface MessageRevokeManager : NSObject

+ (MessageRevokeManager *)sharedInstance;

/**
 * 发送回撤cmd消息
 *
 * @param aChatter 对应会话的chatter
 * @param aMessageId 待撤销消息的id
 */
+ (void)sendRevokeMessageToChatter:(NSString *)aChatter
                         messageId:(NSString *)aMessageId
                  conversationType:(EMConversationType)conversationType;;

/**
 * 判断消息是否是消息回撤cmd消息
 *
 * @param message 待验证消息对象
 * @return 返回验证结果，YES代表此消息为消息撤销的cmd消息
 */
+ (BOOL)isRevokeCMDMessage:(EMMessage *)message;

// 得到要回撤的消息id
+ (NSString *)needRevokeMessageId:(EMMessage *)aMessage;

/**
 * 验证消息是否符合撤销原则(如2分钟内发送)
 *
 * @param model 待验证消息
 * @return 判断结果, YES代表可以撤销
 */
+ (BOOL)canRevokeMessage:(EMMessage *)message;

/**
 * 注册消息回撤完成后UI更新通知
 *
 */
- (void)registerNotification:(id)observer selector:(SEL)action;

/**
 * 释放消息回撤完成后UI更新通知
 *
 */
- (void)removeNotification:(id)observer;

@end

@interface RemoveAfterReadManager : NSObject

// 初始化manager，如果发现有需要焚毁的消息会直接焚毁
+ (RemoveAfterReadManager *)sharedInstance;

/**
 * 注册阅后即焚消息处理完成后UI更新通知
 *
 */
- (void)registerNotification:(id)observer selector:(SEL)action;

/**
 * 释放阅后即焚消息处理完成后UI更新通知
 *
 */
- (void)removeNotification:(id)observer;

/**
 * 验证消息是否为阅后即焚消息
 *
 * @param aMessage 待验证消息
 * @return 判断结果, YES代表待验证消息为阅后即焚类型
 */
+ (BOOL)isReadAfterRemoveMessage:(EMMessage *)aMessage;

/**
 * 保存正在读取的消息
 *
 * @param aMessage 正在读取的消息
 */
- (void)updateCurrentMsg:(EMMessage *)aMessage;

/**
 * 为普通消息添加阅后即焚扩展成为阅后即焚类型消息
 *
 * @param aMessage 待发送的消息
 * @return 携带阅后即焚扩展的待发送消息
 */
- (EMMessage *)setupToNeedRemoveMessage:(EMMessage *)aMessage;

/**
 *  以下用于聊天页面的处理
 */

/**
 * 触发消息焚毁,处理阅读即焚消息
 *
 * @param model 待处理消息
 *
 */
- (void)readFireMessageDeal:(EMMessage *)message;

@end