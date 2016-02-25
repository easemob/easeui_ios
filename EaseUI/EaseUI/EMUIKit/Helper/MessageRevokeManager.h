//
//  MessageRevokeManager.h
//  EaseUI
//
//  Created by WYZ on 16/2/24.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EaseMob.h"

@interface MessageRevokeManager : NSObject

+ (MessageRevokeManager *)sharedInstance;

/**
 * 发送回撤cmd消息
 *
 * @param message 待撤销的消息
 */
+ (void)sendRevokeCMDMessage:(EMMessage *)message;

/**
 * 判断消息是否是消息回撤cmd消息
 *
 * @param message 待验证消息对象
 * @return 返回验证结果，YES代表此消息为消息撤销的cmd消息
 */
+ (BOOL)isRevokeCMDMessage:(EMMessage *)message;

// 从cmd消息ext中得到被回撤的消息id
+ (NSString *)getRevokedMessageIdFromCmdMessageExt:(EMMessage *)cmdMessage;

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
