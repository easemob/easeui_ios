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

@interface ContactsViewController () <EaseContactsTableViewDelegate>

@end

@implementation ContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    EaseContactsViewModel *model = [[EaseContactsViewModel alloc] init];
    model.letterIndex = YES;
    model.canRefresh = YES;
    EaseContactsViewController *contactsVC = [[EaseContactsViewController alloc] initWithViewModel:model];
    contactsVC.normalItems = [self titleItem];
    contactsVC.easeTableViewDelegate = self;
    
    [self.view addSubview:contactsVC.view];
    contactsVC.view.frame = self.view.bounds;
    [self addChildViewController:contactsVC];
}

- (NSArray<EaseContactModelDelegate> *)titleItem {
    NSMutableArray<EaseContactModelDelegate> *ret = [NSMutableArray<EaseContactModelDelegate> array];
    NormalItem *item = [[NormalItem alloc] init];
    item.showName = @"test";
    [ret addObject:item];
    [ret addObject:item];
    [ret addObject:item];
    [ret addObject:item];
    return ret;
}

- (void)easeTableView:(nonnull UITableView *)tableView didSelectItem:(nonnull id<EaseContactModelDelegate>)item {
    
}

@end
