//
//  EaseConversationsViewController.h
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/10/29.
//

#import <UIKit/UIKit.h>
#import <Hyphenate/Hyphenate.h>
#import "EaseConversationCellOptions.h"
#import "EaseConversationCellModelDelegate.h"
#import "EMRefreshViewController.h"
#import "EaseConversationCell.h"

@protocol EaseConversationVCDelegate <NSObject>

@optional

/**
 * 会话列表 cell 部分数据源     头像等
 *
 * @param   cellModel  id<EaseConversationModelDelegate> 类型 数据源
 */
- (id<EaseConversationCellModelDelegate>)conversationCellForModel:(id<EaseConversationModelDelegate>)cellModel;

/**
 * 会话列表cell侧滑功能区，可添加一项Action
 *
 * @param   cellModel  id<EaseConversationModelDelegate> 类型 数据源
 */
- (UITableViewRowAction *)sideslipCustomAction:(id<EaseConversationModelDelegate>)cellModel;

/**
 * 会话列表cell 点击 事件
 *
 * @param   tableView  当前点击的 tableview
 * @param   dataArray  id<EaseConversationModelDelegate> 类型 数据源
 * @param   indexPath 当前点击的   indexPath
 */
- (void)tableView:(UITableView *)tableView dataSource:(NSMutableArray *)dataArray didSelectRowAtIndexPath:(NSIndexPath *)indexPath; 

@end

@interface EaseConversationsViewController : EMRefreshViewController

- (instancetype)initWithOptions:(EaseConversationCellOptions *)options; //初始化
- (void)reloadViewWithOption; //根据 option 重新刷新会话列表

@property (nonatomic, assign) id<EaseConversationVCDelegate> conversationVCDelegate;

@end

