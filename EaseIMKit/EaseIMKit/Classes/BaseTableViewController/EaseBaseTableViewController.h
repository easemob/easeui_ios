//
//  EaseBaseTableViewController.h
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/11/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EaseBaseTableViewController : UIViewController
// 开始刷新
- (void)refreshTabView;

// 关闭刷新
- (void)endRefresh;


@end

NS_ASSUME_NONNULL_END
