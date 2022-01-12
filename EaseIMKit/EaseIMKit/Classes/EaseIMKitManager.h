//
//  EaseIMKitManager.h
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/10/29.
//

#import <Foundation/Foundation.h>
#import "EasePublicHeaders.h"

NS_ASSUME_NONNULL_BEGIN

//系统通知接口
@protocol EaseIMKitSystemNotiDelegate <NSObject>
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
@end



@protocol EaseIMKitManagerDelegate <NSObject>
@optional

/**
 * 会话未读总数变化
 *
 * @param   unreadCount     当前会话列表的总未读数
 */
- (void)conversationsUnreadCountUpdate:(NSInteger)unreadCount;

/**
 * 会话未读总数变化
 *
 * @param   unreadTotalCount     当前会话列表的总未读数
 * @param   undisturbCount     当前会话列表免打扰收到的总未读数
 */
- (void)conversationsUnreadCountUpdate:(NSInteger)unreadTotalCount undisturbCount:(NSInteger)undisturbCount;

@end


@interface EaseIMKitManager : NSObject

@property (nonatomic, strong, readonly) NSString *version; //UIKit 版本号
@property (nonatomic) id<EaseIMKitSystemNotiDelegate>systemNotiDelegate; //系统通知回调代理
+ (BOOL)initWithEMOptions:(EMOptions *)options;

/// 根据会话id查询当前会话是否设置了免打扰 时间复杂度O(1)
/// @param conversationId 会话id
- (BOOL)conversationUndisturb:(NSString *)conversationId;

/// Description 更新免打扰会话map
/// @param key key
/// @param value value
/// 
- (void)updateUndisturbMapsKey:(NSString *)key value:(BOOL )value;
+ (EaseIMKitManager *)shared;
+ (NSString *)EaseIMKitVersion;
- (void)addDelegate:(id<EaseIMKitManagerDelegate>)aDelegate;
- (void)removeDelegate:(id<EaseIMKitManagerDelegate>)aDelegate;

- (void)markAllMessagesAsReadWithConversation:(EMConversation *)conversation;

@end

NS_ASSUME_NONNULL_END
