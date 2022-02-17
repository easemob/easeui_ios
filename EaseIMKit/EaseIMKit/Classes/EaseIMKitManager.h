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

/// Description 根据会话 ID 查询当前会话是否设置了免打扰。（ 时间复杂度O(1)：将原来 undisturbList 改造为 undisturbMap 降低查询时间复杂度）
/// @param conversationId 会话 ID /// @result return - `YES`：是； - （默认） `NO` ：否。 不在undisturbMap中查询结果为NO
- (BOOL)conversationUndisturb:(NSString *)conversationId;

/// Description 是否将会话设置为免打扰模式。
/// @param key key 为 conversationId，会话 ID。
/// @param value 是否设置为免打扰。- `YES`：是； `NO` ：否。
- (void)updateUndisturbMapsKey:(NSString *)key value:(BOOL )value;

/// Description 清空内存中所存储的免打扰会话的键值对Map 用于后续重新根据会话id获取当前会话免打扰状态的更新，此方法尽在开启多设备登录后收到多设备代理EMMultiDevicesDelegate中收到multiDevicesUndisturbEventDidReceive的通知，其它端对某个会话设置免打扰状态后在其它设备上同步后重新从服务器获取pushConfig后才可用此方法清空后，再刷新需要更新会话的免打扰状态
- (void)cleanMemoryUndisturbMaps;
+ (EaseIMKitManager *)shared;
+ (NSString *)EaseIMKitVersion;
- (void)addDelegate:(id<EaseIMKitManagerDelegate>)aDelegate;
- (void)removeDelegate:(id<EaseIMKitManagerDelegate>)aDelegate;

- (void)markAllMessagesAsReadWithConversation:(EMConversation *)conversation;

@end

NS_ASSUME_NONNULL_END
