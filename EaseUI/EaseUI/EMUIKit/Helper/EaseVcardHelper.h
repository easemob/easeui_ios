//
//  EaseVcardHelper.h
//  ChatDemo-UI3.0
//
//  Created by WYZ on 16/4/28.
//  Copyright © 2016年 WYZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSDKFull.h"
#import "EaseVcardModel.h"


@interface EaseVcardHelper : NSObject

@property (nonatomic, strong) NSString *account;

+ (EaseVcardHelper *)sharedInstance;

/**
 * 验证消息是否为名片消息
 *
 * @param aMessage 待验证消息
 * @return 判断结果, YES代表待验证消息为名片
 */
+ (BOOL)isVcardMessage:(EMMessage *)aMessage;

/**
 * 设置名片信息
 *
 * @param model 传入的名片信息
 */
+ (void)setValueForVcardModel:(EaseVcardModel *)model;

/**
 * 构造名片消息的ext
 *
 * @return 携带名片信息的扩展
 */
+ (NSDictionary *)structureVcardMessageExt;

#pragma mark - 获取名片信息

/**
 * 获取名片中环信ID
 *
 * @param message 发送/接收的名片消息
 * @return 名片中携带环信ID
 */
+ (NSString *)fetchUsernameFromVcard:(EMMessage *)message;

/**
 * 获取名片中用户昵称
 *
 * @param message 发送/接收的名片消息
 * @return 名片中携带用户昵称
 */
+ (NSString *)fetchNicknameFromVcard:(EMMessage *)message;

/**
 * 获取名片中用户头像
 *
 * @param message 发送/接收的名片消息
 * @return 名片中携带用户头像
 */
+ (NSString *)fetchAvatarURLFromVcard:(EMMessage *)message;


@end
