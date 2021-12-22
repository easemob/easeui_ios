//
//  EaseBaseTableViewController.m
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/11/6.
//

#import "EaseBaseTableViewController.h"
#import "UITableView+Refresh.h"
#import "Easeonry.h"
#import "EaseDefines.h"

@interface EaseBaseTableViewController ()
{
    
}
@end

@implementation EaseBaseTableViewController

- (instancetype)initWithModel:(EaseBaseTableViewModel *)aModel {
    if(self = [super init]) {
        _viewModel = aModel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if( @available (iOS 15.0,*) ){
        [[UITableView appearance] setSectionHeaderTopPadding:0.0f];
    }
    self.view.backgroundColor = UIColor.clearColor;
    self.tableView.backgroundColor = UIColor.clearColor;
    [self.view addSubview:self.tableView];
    
    [self.tableView Ease_remakeConstraints:^(EaseConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.top.equalTo(self.view);
        make.size.equalTo(self.view);
    }];
    
    [self _setupSubViews];
    [self resetViewModel:self.viewModel];
}


- (void)resetViewModel:(EaseBaseTableViewModel *)viewModel {
    _viewModel = viewModel;
    [self _setupSubViews];
    if (_viewModel.canRefresh) {
        [self refreshTable];
    }else {
        [self.tableView disableRefresh];
        [self refreshTabView];
    }
    
    [self.tableView setSeparatorInset:_viewModel.cellSeparatorInset];
    [self.tableView setSeparatorColor:_viewModel.cellSeparatorColor];
}


- (void)_setupSubViews {
    // 配置基本ui属性
    if (_viewModel.bgView) {
        self.tableView.backgroundView = _viewModel.bgView;
    }
}

#pragma mark - actions
- (void)refreshTable {
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

#pragma mark - getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.tableFooterView = [UIView new];
        _tableView.estimatedRowHeight = 44;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        [_tableView enableRefresh:EaseLocalizableString(@"dropRefresh", nil) color:UIColor.systemGrayColor];
        [_tableView.refreshControl addTarget:self action:@selector(refreshTabView) forControlEvents:UIControlEventValueChanged];
    }
    
    return _tableView;
}


@end
