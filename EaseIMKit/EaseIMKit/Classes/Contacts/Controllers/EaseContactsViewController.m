//
//  EaseContactsViewController.m
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/11/5.
//

#import "EaseContactsViewController.h"
#import "EaseContactCellModel.h"
#import <Hyphenate/Hyphenate.h>
#import <Masonry/Masonry.h>

@interface EaseContactsViewController () <UITableViewDelegate, UITableViewDataSource>
{
    EaseContactsViewModel *_viewModel;
}


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
    [self beginRefresh];
}

- (void)resetViewModel:(EaseContactsViewModel *)viewModel {
    _viewModel = viewModel;
}

- (void)refreshTabView {
    __block typeof(self) weakSelf = self;
    [EMClient.sharedClient.contactManager getContactsFromServerWithCompletion:^(NSArray *aList, EMError *aError) {
        if (!aError) {
            NSMutableArray<EaseContactCellModelDelegate> *contacts = [NSMutableArray<EaseContactCellModelDelegate> array];
            for (NSString *username in aList) {
                EaseContactCellModel *model = [[EaseContactCellModel alloc] initWithShowName:username];
                [contacts addObject:model];
            }
            weakSelf.contacts = contacts;
        }
        [self endRefresh];
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"ContactCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    id<EaseContactCellModelDelegate> easeContactModel = self.contacts[indexPath.row];
    
    cell.textLabel.text = easeContactModel.showName;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contacts.count;
}

@end
