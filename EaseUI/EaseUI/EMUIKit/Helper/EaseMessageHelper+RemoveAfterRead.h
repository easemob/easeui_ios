//
//  EaseMessageHelper+RemoveAfterRead.h
//  EaseUI
//
//  Created by WYZ on 16/2/17.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EaseMessageHelper.h"

@interface EaseMessageHelper (RemoveAfterRead)

/**
 * 验证消息是否为阅后即焚消息
 *
 * @param aMessage 待验证消息
 * @return 判断结果, YES代表待验证消息为阅后即焚类型
 */
+ (BOOL)isRemoveAfterReadMessage:(EMMessage *)aMessage;

/**
 * 保存正在读取的消息
 *
 * @param aMessage 正在读取的消息
 */
- (void)updateCurrentMsg:(EMMessage *)aMessage;

/**
 * 构造阅后即焚消息的ext
 *
 * @param originalExt 待发消息的ext
 * @return 携带阅后即焚信息的扩展
 */
+ (NSDictionary *)structureRemoveAfterReadMessageExt:(NSDictionary *)originalExt;

/**
 *  以下用于聊天页面的处理
 */

/**
 * 被选中阅后即焚消息处理
 *
 * @param message 待处理消息
 *
 */
- (void)handleRemoveAfterReadMessage:(EMMessage *)message;

@end
