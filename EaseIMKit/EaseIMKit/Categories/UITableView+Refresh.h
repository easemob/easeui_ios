//
//  UITableView+Refresh.h
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/11/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface UITableView (Refresh)
- (void)enableRefresh:(NSString *)title color:(UIColor *)tintColor;
- (void)disableRefresh;

- (BOOL)isRefreshing;
- (void)endRefreshing;
@end

NS_ASSUME_NONNULL_END
