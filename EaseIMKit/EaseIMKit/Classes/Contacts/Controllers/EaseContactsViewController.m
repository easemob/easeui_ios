//
//  EaseContactsViewController.m
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/11/5.
//

#import "EaseContactsViewController.h"
#import <Masonry/Masonry.h>

@interface EaseContactsViewController () <UITableViewDelegate, UITableViewDataSource>
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
        make.left.equalTo(self.view);
        make.top.equalTo(self.view);
        make.size.equalTo(self.view);
    }];
}

- (void)refreshViewWithModel:(EaseContactsViewModel *)viewModel {
    _viewModel = viewModel;
    
}

#pragma mark - table view delegate & datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 15;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"ContactCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    return cell;
}

#pragma mark - getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero];
        _tableView.tableFooterView = [UIView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    
    return _tableView;
}

@end
