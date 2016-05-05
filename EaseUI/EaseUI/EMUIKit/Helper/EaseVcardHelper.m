//
//  EaseVcardHelper.m
//  ChatDemo-UI3.0
//
//  Created by WYZ on 16/4/28.
//  Copyright © 2016年 WYZ. All rights reserved.
//

#import "EaseVcardHelper.h"

/** @brief 名片消息扩展字段 */
#define KEM_VCARD                @"em_vcard"
#define KEM_VCARD_NICKNAME     @"em_vcard_nickname"
#define KEM_VCARD_AVATAR       @"em_vcard_avatar"
#define KEM_VCARD_USERNAME     @"em_vcard_username"


@interface EaseVcardHelper()

@property (nonatomic, strong) UIImage *vcardImage;

@property (nonatomic, strong) EaseVcardModel *vcardModel;

@end

@implementation EaseVcardHelper

+ (EaseVcardHelper *)sharedInstance
{
    static EaseVcardHelper *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[EaseVcardHelper alloc] init];
    });
    
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
    }
    return self;
}

- (void)dealloc
{
}

#pragma mark - getter

- (NSString *)account
{
    return [[EMClient sharedClient] currentUsername];
}

#pragma mark - public

/**
 * 验证消息是否为名片消息
 *
 * @param aMessage 待验证消息
 * @return 判断结果, YES代表待验证消息为名片
 */
+ (BOOL)isVcardMessage:(EMMessage *)aMessage
{
    if (!aMessage) {
        return NO;
    }
    if (aMessage.ext[KEM_VCARD] && [aMessage.ext[KEM_VCARD] boolValue]) {
        return YES;
    }
    return NO;
}


+ (NSDictionary *)structureVcardMessageExt
{
    NSMutableDictionary *ext = [NSMutableDictionary dictionaryWithObjectsAndKeys:@YES, KEM_VCARD, nil];
    EaseVcardModel *model = [EaseVcardHelper sharedInstance].vcardModel;
    if (model.nickname.length > 0) {
        [ext setObject:model.nickname forKey:KEM_VCARD_NICKNAME];
    }
    
    if (model.avatarURL.length > 0) {
        [ext setObject:model.avatarURL forKey:KEM_VCARD_AVATAR];
    }
    
    if (model.username.length > 0) {
        [ext setObject:model.username forKey:KEM_VCARD_USERNAME];
    }
    
    [EaseVcardHelper setValueForVcardModel:nil];
    return ext;
}

/**
 * 设置名片信息
 *
 * @param model 传入的名片信息
 */
+ (void)setValueForVcardModel:(EaseVcardModel *)model
{
    if (!model) {
        [EaseVcardHelper sharedInstance].vcardModel = nil;
        return;
    }
    [EaseVcardHelper sharedInstance].vcardModel = [[EaseVcardModel alloc] initWithInfo:[model toDictionary]];
}


#pragma mark - 获取名片信息
//获取环信ID
+ (NSString *)fetchUsernameFromVcard:(EMMessage *)message
{
    if (![EaseVcardHelper isVcardMessage:message]) {
        return nil;
    }
    NSObject *obj = message.ext[KEM_VCARD_USERNAME];
    if ([obj isKindOfClass:[NSString class]] && obj) {
        return (NSString *)obj;
    }
    return @"";
}

//获取用户昵称
+ (NSString *)fetchNicknameFromVcard:(EMMessage *)message
{
    if (![EaseVcardHelper isVcardMessage:message]) {
        return nil;
    }
    NSObject *obj = message.ext[KEM_VCARD_NICKNAME];
    if ([obj isKindOfClass:[NSString class]] && obj) {
        return (NSString *)obj;
    }
    return @"";
}

//获取用户头像
+ (NSString *)fetchAvatarURLFromVcard:(EMMessage *)message
{
    if (![EaseVcardHelper isVcardMessage:message]) {
        return nil;
    }
    NSObject *obj = message.ext[KEM_VCARD_AVATAR];
    if ([obj isKindOfClass:[NSString class]] && obj) {
        return (NSString *)obj;
    }
    return @"";
}

@end
