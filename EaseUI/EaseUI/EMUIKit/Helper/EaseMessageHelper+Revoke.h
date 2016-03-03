//
//  EaseMessageHelper+Revoke.h
//  EaseUI
//
//  Created by easemob on 16/2/17.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EaseMessageHelper.h"

@interface EaseMessageHelper (Revoke)

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

/**
 * 验证消息是否符合撤销原则(如2分钟内发送)
 *
 * @param model 待验证消息
 * @return 判断结果, YES代表可以撤销
 */
+ (BOOL)canRevokeMessage:(EMMessage *)message;

/**
 * 获取cmd消息，处理消息撤销
 *
 * @param cmdMessages 接收的cmd消息
 * @return 返回被删除的消息
 */
- (EMMessage *)handleReceiveRevokeCmdMessage:(EMMessage *)cmdMessage;

@end
