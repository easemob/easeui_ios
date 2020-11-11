//
//  EaseBaseTableViewController.h
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/11/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EaseBaseTableViewController : UIViewController

@property (nonatomic, strong) UITableView *tableView;

// 主动刷新
- (void)beginRefresh;

// 刷新时执行
- (void)refreshTabView;

// 关闭刷新
- (void)endRefresh;


@end

NS_ASSUME_NONNULL_END
