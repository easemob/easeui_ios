//
//  ContactsViewController.m
//  EaseIMKitDemo
//
//  Created by 杜洁鹏 on 2020/11/5.
//  Copyright © 2020 djp. All rights reserved.
//

#import "ContactsViewController.h"
#import <EaseIMKit.h>
#import "NormalItem.h"

@interface ContactsViewController () <EaseContactsViewControllerDelegate>

@end

@implementation ContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    EaseContactsViewModel *model = [[EaseContactsViewModel alloc] init];
    model.canRefresh = YES;
    EaseContactsViewController *contactsVC = [[EaseContactsViewController alloc] initWithViewModel:model];
    contactsVC.customHeaderItems = [self titleItem];
//    contactsVC.dele = self;
    
    [self.view addSubview:contactsVC.view];
//    contactsVC.view.frame = CGRectMake(50, 200, 300, 400);
    contactsVC.view.frame = self.view.bounds;
    [self addChildViewController:contactsVC];
}


- (NSArray<EaseContactDelegate> *)titleItem {
    NSMutableArray<EaseContactDelegate> *ret = [NSMutableArray<EaseContactDelegate> array];
    NormalItem *item1 = [[NormalItem alloc] init];
    item1.showName = @"群组管理";
    
    NormalItem *item2 = [[NormalItem alloc] init];
    item2.showName = @"聊天室管理";
    
    NormalItem *item3 = [[NormalItem alloc] init];
    item3.showName = @"好友管理";
    
    NormalItem *item4 = [[NormalItem alloc] init];
    item4.showName = @"通知管理";
    
    [ret addObject:item1];
    [ret addObject:item2];
    [ret addObject:item3];
    [ret addObject:item4];
    return ret;
}

- (void)easeTableView:(nonnull UITableView *)tableView didSelectItem:(nonnull id<EaseContactDelegate>)item {

}

@end
