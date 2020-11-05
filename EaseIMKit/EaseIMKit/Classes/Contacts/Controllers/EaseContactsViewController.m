//
//  EaseContactsViewController.m
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/11/5.
//

#import "EaseContactsViewController.h"
#import <Masonry/Masonry.h>

@interface EaseContactsViewController () /* <UITableViewDelegate, UITableViewDataSource> */
{
    EaseContactsViewModel *_viewModel;
}

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation EaseContactsViewController

- (instancetype)initWithViewModel:(EaseContactsViewModel *)model {
    if (self = [super init]) {
        _viewModel = model;

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupSubViews];
}

- (void)_setupSubViews {
    [self.view addSubview:self.tableView];
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view);
        make.size.equalTo(self.view);
    }];
}

- (void)refreshViewWithModel:(EaseContactsViewModel *)viewModel {
    _viewModel = viewModel;
    
}

#pragma mark - getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero];
//        _tableView.delegate = self;
//        _tableView.dataSource = self;
    }
    
    return _tableView;
}

@end
