//
//  ContactsViewController.m
//  EaseIMKitDemo
//
//  Created by 杜洁鹏 on 2020/11/5.
//  Copyright © 2020 djp. All rights reserved.
//

#import "ContactsViewController.h"
#import "ContactModel.h"
#import <EaseIMKit.h>

@interface ContactsViewController () <EaseContactsViewControllerDelegate>

@end

@implementation ContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    EaseContactsViewModel *model = [[EaseContactsViewModel alloc] init];
    model.avatarType = RoundedCorner;
    model.sectionTitleColor = UIColor.redColor;
    model.sectionTitleBgColor = UIColor.clearColor;
    model.sectionTitleFont = [UIFont systemFontOfSize:40];
    model.sectionTitleLabelHeight = 50;
    model.sectionTitleEdgeInsets= UIEdgeInsetsMake(0, 0, 0, 0);
    EaseContactsViewController *contactsVC = [[EaseContactsViewController alloc] initWithViewModel:model];
    contactsVC.customHeaderItems = [self items];
    contactsVC.delegate = self;
    [self.view addSubview:contactsVC.view];
    contactsVC.view.frame = self.view.bounds;
    [self addChildViewController:contactsVC];
}


- (NSArray<EaseContactDelegate> *)items {
    ContactModel *newFriends = [[ContactModel alloc] init];
    newFriends.showName = @"新的好友";
    newFriends.defaultAvatar = [UIImage imageNamed:@"newFriends.png"];
    ContactModel *groups = [[ContactModel alloc] init];
    groups.showName = @"群组";
    groups.defaultAvatar = [UIImage imageNamed:@"groups.png"];
    
    return (NSArray<EaseContactDelegate> *)@[newFriends, groups];
}

@end
