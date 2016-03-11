//
//  EaseMessageHelper+Revoke.h
//  EaseUI
//
//  Created by easemob on 16/2/17.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EaseMessageHelper.h"

/** @brief 用于消息撤销后，插入的提示消息ext的字段，对应值为BOOL类型*/
#define KEM_REVOKE_EXTKEY_REVOKEPROMPT       @"em_revoke_extKey_revokePrompt"

@interface EaseMessageHelper (Revoke)

/**
 * 开启消息回撤后的文字提示功能
 *
 */
+ (void)openRevokePrompt;

/**
 * 关闭消息回撤后的文字提示功能
 *
 */
+ (void)closeRevokePrompt;

/**
 * 消息回撤后文字提示功能是否可用
 *
 * @return 判断结果, YES代表消息回撤后文字提示功能可用
 */
+ (BOOL)revokePromptIsValid;

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
- (EMMessage *)handleReceivedRevokeCmdMessage:(EMMessage *)cmdMessage;


/**
 * 向数据库插入回撤后的文本提示消息,并返回该提示消息
 *
 * @param message 被撤销的消息（需要此消息的timestamp、messageType）
 * @return 插入的文本提示消息
 */
+ (EMMessage *)insertRevokePromptMessageToDB:(EMMessage *)message;


@end
