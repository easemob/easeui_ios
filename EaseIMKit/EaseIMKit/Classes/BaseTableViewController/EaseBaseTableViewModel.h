//
//  EaseBaseTableViewModel.h
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/11/11.
//

#import <UIKit/UIKit.h>
#import "EaseEnums.h"

NS_ASSUME_NONNULL_BEGIN

@interface EaseBaseTableViewModel : NSObject

// 是否可下拉刷新
@property (nonatomic) BOOL canRefresh;

// tableView 背景图
@property (nonatomic, strong) UIView *bgView;

// UITableViewCell 背景色
@property (nonatomic, strong) UIColor *cellBgColor;

// UITableViewCell 下划线位置
@property (nonatomic) UIEdgeInsets cellSeparatorInset;

// UITableViewCell 下划线颜色
@property (nonatomic, strong) UIColor *cellSeparatorColor;
@end

NS_ASSUME_NONNULL_END
