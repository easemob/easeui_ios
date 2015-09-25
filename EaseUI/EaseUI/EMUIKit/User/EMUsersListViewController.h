//
//  EMUsersListViewController.h
//  ChatDemo-UI3.0
//
//  Created by dhc on 15/6/24.
//  Copyright (c) 2015年 easemob.com. All rights reserved.
//

#import "EMRefreshTableViewController.h"

#import "EMUserModel.h"
#import "EMUserCell.h"
#import "EMSDKHelper.h"

@class EMUsersListViewController;

@protocol EMUserListViewControllerDelegate <NSObject>

- (void)userListViewController:(EMUsersListViewController *)userListViewController
            didSelectUserModel:(id<IUserModel>)userModel;

@optional

- (void)userListViewController:(EMUsersListViewController *)userListViewController
            didDeleteUserModel:(id<IUserModel>)userModel;

@end

@protocol EMUserListViewControllerDataSource <NSObject>

@optional

- (NSInteger)numberOfRowInUserListViewController:(EMUsersListViewController *)userListViewController;

- (id<IUserModel>)userListViewController:(EMUsersListViewController *)userListViewController
                           modelForBuddy:(EMBuddy *)buddy;

- (id<IUserModel>)userListViewController:(EMUsersListViewController *)userListViewController
                   userModelForIndexPath:(NSIndexPath *)indexPath;

@end

@interface EMUsersListViewController : EMRefreshTableViewController

@property (weak, nonatomic) id<EMUserListViewControllerDelegate> delegate;

@property (weak, nonatomic) id<EMUserListViewControllerDataSource> dataSource;

@property (nonatomic) BOOL showSearchBar;

- (void)tableViewDidTriggerHeaderRefresh;

@end
