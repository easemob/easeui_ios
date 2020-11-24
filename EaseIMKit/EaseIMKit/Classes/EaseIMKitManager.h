//
//  EaseIMKitManager.h
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/10/29.
//

#import <Foundation/Foundation.h>
#import "EaseHeaders.h"
#import "EaseEnums.h"

NS_ASSUME_NONNULL_BEGIN

@protocol EaseIMKitManagerDelegate <NSObject>

@optional

/**
 * 是否需要系统通知：好友/群 申请等   默认需要
 */
- (BOOL)isNeedsSystemNotification;

/**
 * 收到请求返回展示信息
 *
 * @param   conversationId   会话ID
 *  对于单聊类型，会话ID同时也是对方用户的名称。
 *  对于群聊类型，会话ID同时也是对方群组的ID，并不同于群组的名称。
 *  对于聊天室类型，会话ID同时也是聊天室的ID，并不同于聊天室的名称。
 *
 * @param   requestUser   请求方
 * @param   reason   请求原因
 */
- (NSString *)requestDidReceiveShowMessage:(NSString *)conversationId requestUser:(NSString *)requestUser reason:(EaseIMKitCallBackReason)reason;

/**
 * 收到请求返回扩展信息
 *
 * @param   conversationId   会话ID
 *  对于单聊类型，会话ID同时也是对方用户的名称。
 *  对于群聊类型，会话ID同时也是对方群组的ID，并不同于群组的名称。
 *  对于聊天室类型，会话ID同时也是聊天室的ID，并不同于聊天室的名称。
 *
 * @param   requestUser   请求方
 * @param   reason   请求原因
 */
- (NSDictionary *)requestDidReceiveConversationExt:(NSString *)conversationId requestUser:(NSString *)requestUser reason:(EaseIMKitCallBackReason)reason;

- (void)conversationsUnreadCountUpdate:(NSInteger)unreadCount;//会话未读总数

@end

@interface EaseIMKitManager : NSObject

+ (instancetype)shareEaseIMKit;
+ (void)destoryShared;

- (void)addDelegate:(id<EaseIMKitManagerDelegate>)aDelegate;
- (void)removeDelegate:(id<EaseIMKitManagerDelegate>)aDelegate;

@end

NS_ASSUME_NONNULL_END
