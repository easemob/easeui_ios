//
//  EaseBaseTableViewController.m
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/11/6.
//

#import "EaseBaseTableViewController.h"
#import "UITableView+Refresh.h"
#import <Masonry/Masonry.h>

@interface EaseBaseTableViewController () <UITableViewDelegate, UITableViewDataSource>
{
    
}
@end

@implementation EaseBaseTableViewController

- (instancetype)initWithModel:(EaseBaseTableViewModel *)aModel {
    if(self = [super init]) {
        self.viewModel = aModel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.top.equalTo(self.view);
        make.size.equalTo(self.view);
    }];
    
    [self resetViewModel:self.viewModel];
}


- (void)resetViewModel:(EaseBaseTableViewModel *)viewModel {
    _viewModel = viewModel;
    [self _setupSubViews];
    if (_viewModel.canRefresh) {
        [self beginRefresh];
    }else {
        [self.tableView disableRefresh];
        [self refreshTabView];
    }
}


- (void)_setupSubViews {
    // 配置基本ui属性
}

#pragma mark - actions
- (void)beginRefresh {
    [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentOffset.y - self.tableView.refreshControl.frame.size.height) animated:NO];
    [self.tableView.refreshControl beginRefreshing];
    [self.tableView.refreshControl sendActionsForControlEvents:UIControlEventValueChanged];
}

-(void)refreshTabView
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        if ([self.tableView.refreshControl isRefreshing]) {
            [self.tableView.refreshControl endRefreshing];
        }
    });
}

- (void)endRefresh {
    [self.tableView reloadData];
    if (self.tableView.isRefreshing) {
        [self.tableView endRefreshing];
    }
}

#pragma mark - table view delegate & datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 15;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.easeTableViewDelegate && [self.easeTableViewDelegate respondsToSelector:@selector(easeTableView:cellforItem:)]) {
        return [self.easeTableViewDelegate easeTableView:tableView cellforItem:self.dataAry[indexPath.row]];
    }
    
    static NSString *cellId = @"baseCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.easeTableViewDelegate && [self.easeTableViewDelegate respondsToSelector:@selector(easeTableView:didSelectRowAtItem:)]) {
        [self.easeTableViewDelegate easeTableView:tableView didSelectRowAtItem:self.dataAry[indexPath.row]];
    }
}

//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (self.easeTableViewDelegate && [self.easeTableViewDelegate respondsToSelector:@selector(easeTableView:canEditRowAtItem:)]) {
//        return [self.easeTableViewDelegate easeTableView:tableView canEditRowAtItem:self.dataAry[indexPath.row]];
//    }
//
//    return _viewModel.cellCanEdit;
//}

//
//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
//}
//
//
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//
//}


- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) API_UNAVAILABLE(tvos)
{
    if (self.easeTableViewDelegate && [self.easeTableViewDelegate respondsToSelector:@selector(tableView:trailingSwipeActionsConfigurationForRowAtItem:)]) {
        return [self.easeTableViewDelegate tableView:tableView trailingSwipeActionsConfigurationForRowAtItem:self.dataAry[indexPath.row]];
    }
    
    return nil;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.easeTableViewDelegate && [self.easeTableViewDelegate respondsToSelector:@selector(easeTableView:heightForItem:)]) {
        return [self.easeTableViewDelegate easeTableView:tableView heightForItem:self.dataAry[indexPath.row]];
    }
    
    return self.viewModel.cellHeight;
}



#pragma mark - getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero];
        _tableView.tableFooterView = [UIView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = 60;
        [_tableView enableRefresh:@"下拉刷新" color:UIColor.redColor];
        [_tableView.refreshControl addTarget:self action:@selector(refreshTabView) forControlEvents:UIControlEventValueChanged];
    }
    
    return _tableView;
}

- (NSMutableArray<EaseItemDelegate> *)dataAry {
    if (!_dataAry) {
        _dataAry = [[NSMutableArray<EaseItemDelegate> alloc] init];;
    }
    
    return _dataAry;;
}

@end
