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

- (id<EaseConversationCellModelDelegate>)conversationCellForModel:(id<EaseConversationModelDelegate>)model; //头像数据等

/**
 *
 * 会话列表cell '点击' 事件
 *
 * @param   tableView  当前点击的 tableview
 * @param   dataSource  id<EaseConversationModelDelegate> 类型 数据源
 * @param   didSelectRowAtIndexPath 当前点击的   indexPath
 */
- (void)tableView:(UITableView *)tableView dataSource:(NSMutableArray *)dataArray didSelectRowAtIndexPath:(NSIndexPath *)indexPath; 

- (void)conversationCellDidLongPress:(EaseConversationCell *)aCell; //会话列表cell'长按'事件

@end

@interface EaseConversationsViewController : EMRefreshViewController

@property (nonatomic) BOOL isNeedsSearchModule; //是否需要搜索组件

- (instancetype)initWithOptions:(EaseConversationCellOptions *)options; //初始化
- (void)reloadViewWithOption; //根据 option 重新刷新会话列表

@property (nonatomic, assign) id<EaseConversationVCDelegate> delegate;

@end

