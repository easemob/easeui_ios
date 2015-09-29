//
//  EMUsersListViewController.m
//  ChatDemo-UI3.0
//
//  Created by dhc on 15/6/24.
//  Copyright (c) 2015年 easemob.com. All rights reserved.
//

#import "EMUsersListViewController.h"

#import "EMSearchDisplayController.h"

@interface EMUsersListViewController ()

@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) EMSearchDisplayController *searchController;

@end

@implementation EMUsersListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - setter

- (void)setShowSearchBar:(BOOL)showSearchBar
{
    if (_showSearchBar != showSearchBar) {
        _showSearchBar = showSearchBar;
        
//        if (_showSearchBar) {
//            <#statements#>
//        }
//        else{
//            
//        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        if ([_dataSource respondsToSelector:@selector(numberOfRowInUserListViewController:)]) {
            return [_dataSource numberOfRowInUserListViewController:self];
        }
        return 0;
    }
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [EMUserCell cellIdentifierWithModel:nil];
    EMUserCell *cell = (EMUserCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[EMUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.section == 0) {
        return nil;
    } else {
        id<IUserModel> model = nil;
        if ([_dataSource respondsToSelector:@selector(userListViewController:userModelForIndexPath:)]) {
            model = [_dataSource userListViewController:self userModelForIndexPath:indexPath];
        }
        else if ([_dataSource respondsToSelector:@selector(user)]){
            model = [self.dataArray objectAtIndex:indexPath.row];
        }
        
        if (model) {
            cell.model = model;
        }
        
        return cell;
    }
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [EMUserCell cellHeightWithModel:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_delegate && [_delegate respondsToSelector:@selector(userListViewController:didSelectUserModel:)]) {
        id<IUserModel> model = nil;
        if ([_dataSource respondsToSelector:@selector(userListViewController:userModelForIndexPath:)]) {
            model = [_dataSource userListViewController:self userModelForIndexPath:indexPath];
        }
        else if ([_dataSource respondsToSelector:@selector(user)]){
            model = [self.dataArray objectAtIndex:indexPath.row];
        }
        
        if (model) {
            [_delegate userListViewController:self didSelectUserModel:model];
        }
    }
}

#pragma mark - data

- (void)tableViewDidTriggerHeaderRefresh
{
    __weak typeof(self) weakSelf = self;
    [[[EaseMob sharedInstance] chatManager] asyncFetchBuddyListWithCompletion:^(NSArray *buddyList, EMError *error) {
        if (!error) {
            [weakSelf.dataArray removeAllObjects];
            NSMutableArray *contactsSource = [NSMutableArray arrayWithArray:buddyList];
            
            //从获取的数据中剔除黑名单中的好友
            NSArray *blockList = [[EaseMob sharedInstance].chatManager blockedList];
            for (NSInteger i = (buddyList.count - 1); i >= 0; i--) {
                EMBuddy *buddy = [buddyList objectAtIndex:i];
                if (![blockList containsObject:buddy.username]) {
                    [contactsSource addObject:buddy];
                    
                    id<IUserModel> model = nil;
                    if (_dataSource && [_dataSource respondsToSelector:@selector(userListViewController:modelForBuddy:)]) {
                        model = [_dataSource userListViewController:self modelForBuddy:buddy];
                    }
                    else{
                        model = [[EMUserModel alloc] initWithBuddy:buddy];
                    }
                    
                    if(model){
                        [weakSelf.dataArray addObject:model];
                    }
                }
            }
        }
        
        [weakSelf tableViewDidFinishTriggerHeader:YES reload:YES];
    } onQueue:nil];
}

@end
