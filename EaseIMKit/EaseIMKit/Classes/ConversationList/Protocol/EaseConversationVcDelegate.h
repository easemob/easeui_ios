//
//  EaseConversationVcDelegate.h
//  EaseIMKit
//
//  Created by 娜塔莎 on 2020/11/14.
//

#import <Foundation/Foundation.h>
#import "EaseConversationItemModelDelegate.h"
#import "EaseConversationCellModelDelegate.h"
#import "EaseConversationCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol EaseConversationVCDelegate <NSObject>

@optional

/**
 * 会话列表 cell 部分数据源     头像等
 *
 * @param   itemModel  id<EaseConversationModelDelegate> 类型 数据源
 */
- (id<EaseConversationCellModelDelegate>)conversationCellForModel:(id<EaseConversationItemModelDelegate>)itemModel;

/**
 * 会话列表cell侧滑自定义功能区，可添加一项Action
 *
 * @param   tableView  当前操作的 tableview
 * @param   dataArray  id<EaseConversationModelDelegate> 类型 数据源
 * @param   indexPath 当前点击的   indexPath
 */
- (UIContextualAction *)sideslipCustomAction:(UITableView *)tableView dataArray:(NSMutableArray *)dataArray trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) API_UNAVAILABLE(tvos);

/**
 * 排序会话列表
 *
 * @param   modelList  会话列表 id<EaseConversationItemModelDelegate> 类型数据源
 */
- (NSArray *)sortConversationsList:(NSArray<id<EaseConversationItemModelDelegate>> *)modelList;

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

NS_ASSUME_NONNULL_END
