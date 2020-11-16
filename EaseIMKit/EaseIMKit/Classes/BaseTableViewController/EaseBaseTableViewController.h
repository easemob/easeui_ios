//
//  EaseBaseTableViewController.h
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/11/6.
//

#import <UIKit/UIKit.h>
#import "EaseBaseTableViewModel.h"
#import "EaseItemDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@class EaseConversationCell;
@protocol EaseTableViewDelegate  <NSObject>

@optional
- (void)easeTableView:(UITableView *)tableView didSelectItem:(id<EaseItemDelegate>)item;
- (CGFloat)easeTableView:(UITableView *)tableView heightForItem:(id<EaseItemDelegate>)item;
- (EaseConversationCell *)easeTableView:(UITableView *)tableView cellforItem:(id<EaseItemDelegate>)item;
- (UITableViewCell *)easeTableView:(UITableView *)tableView didSelectRowAtItem:(id<EaseItemDelegate>)item;

//- (BOOL)easeTableView:(UITableView *)tableView canEditRowAtItem:(id<EaseItemDelegate>)item;
//- (nullable NSArray<UITableViewRowAction *> *)easeTableView:(UITableView *)tableView editActionsForRowAtItem:(id<EaseItemDelegate>)item;
- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtItem:(id<EaseItemDelegate>)item;
@end


@interface EaseBaseTableViewController : UIViewController

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) EaseBaseTableViewModel *viewModel;
@property (nonatomic, strong) NSMutableArray<EaseItemDelegate> * dataAry;

@property (nonatomic, weak) id<EaseTableViewDelegate> easeTableViewDelegate;

- (instancetype)initWithModel:(EaseBaseTableViewModel *)aModel;

- (void)resetViewModel:(EaseBaseTableViewModel *)viewModel;

// 主动刷新
- (void)beginRefresh;

// 刷新时执行
- (void)refreshTabView;

// 关闭刷新
- (void)endRefresh;


@end

NS_ASSUME_NONNULL_END
