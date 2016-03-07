//
//  EaseMessageHelper.h
//  EaseUI
//
//  Created by WYZ on 16/2/16.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EaseMessageMulticastBase.h"

typedef NS_ENUM(NSUInteger, EMHelperType)
{
    emHelperTypeDefault,               //默认普通消息类型
    emHelperTypeRevoke,                //消息回撤类型
    emHelperTypeRemoveAfterRead,       //阅后即焚类型
    emHelperTypeGroupAt,               //群组@类型
    emHelperTypeInputState             //输入状态类型
};

@interface EaseMessageHelper : EaseMessageMulticastBase<EMChatManagerDelegate, EMClientDelegate>
{
    dispatch_queue_t _queue;
}

@property (nonatomic, copy) id<IEMChatManager> chatManager;

@property (nonatomic, strong) NSString *account;

@property (nonatomic, assign) EMHelperType emHelperType;

+ (EaseMessageHelper *)sharedInstance;

/**
 * 修改扩展属性 用于普通消息、阅后即焚、群组@ (非cmd消息)
 *
 * @param ext 待发消息的扩展属性
 * @param bodyType 消息体类型
 */
+ (NSDictionary *)structureEaseMessageHelperExt:(NSDictionary *)ext
                                       bodyType:(EMMessageBodyType)bodyType;

/**
 * 注册EaseMessageHelpProtocal
 *
 */
- (void)addDelegate:(id<EaseMessageHelperProtocal>)delegate;

/**
 * 释放EaseMessageHelpProtocal
 *
 */
- (void)removeDelegate:(id<EaseMessageHelperProtocal>)delegate;

//通过消息判断属于何种类型
+ (EMHelperType)checkMessage:(EMMessage *)message;

@end
