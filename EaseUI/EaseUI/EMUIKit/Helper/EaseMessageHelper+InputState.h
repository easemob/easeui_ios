//
//  EaseMessageHelper+InputState.h
//  EaseUI
//
//  Created by WYZ on 16/2/16.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EaseMessageHelper.h"

@interface EaseMessageHelper (InputState)

/**
 * 开启输入状态提示功能
 *
 */
+ (void)openInputState;

/**
 * 关闭输入状态提示功能
 *
 */
+ (void)closeInputState;

/**
 * 输入状态提示功能是否可用
 *
 * @return 判断结果, YES代表输入状态提示功能可用
 */
+ (BOOL)inputStateIsValid;

/**
 * 验证cmd消息是否含有输入状态提示功能
 *
 * @param model 待验证消息
 * @return 判断结果, YES代表消息含有输入状态提示功能
 */
+ (BOOL)isInputCMDMessage:(EMMessage *)message;

/**
 * 重置输入状态cmd消息的发送时间(前提会话为单聊)
 *
 * @param conversationType 会话类型
 */
+ (void)resetInputStateCmdMessageSendTime:(EMConversationType)conversationType;

/**
 * 验证消息发送方，输入状态cmd是否符合发送规律，符合则发送输入状态cmd消息，不符合跳出
 *
 * @param chatter 聊天会话chatter
 * @param isInput 当前是否为输入状态
 */
+ (void)canSendInputCmdMsgToChatter:(NSString *)chatter status:(BOOL)isInput;

/**
 * 处理接收的输入状态cmd消息
 *
 * @param cmdMessage 待处理cmd消息
 */
- (NSString *)handleReceiveInputStateCmdMessage:(EMMessage *)cmdMessage;

/**
 * 接收方开启计时，以防无限制显示输入状态
 *
 */
- (void)startRunLoopByReceiver;

@end
