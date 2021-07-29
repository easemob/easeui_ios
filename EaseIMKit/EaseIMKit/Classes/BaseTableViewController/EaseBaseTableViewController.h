//
//  EaseBaseTableViewController.h
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/11/6.
//

#import <UIKit/UIKit.h>
#import "EaseBaseTableViewModel.h"
#import "EaseUserDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@class EaseConversationCell;
@protocol EaseBaseViewControllerDelegate  <NSObject>

@end


@interface EaseBaseTableViewController : UIViewController

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) __kindof EaseBaseTableViewModel *viewModel;

- (instancetype)initWithModel:(__kindof EaseBaseTableViewModel *)aModel;

// 主动刷新UI
- (void)refreshTable;

//刷新数据资源以及UI
-(void)refreshTabView;

// 关闭刷新
- (void)endRefresh;

@end

NS_ASSUME_NONNULL_END
