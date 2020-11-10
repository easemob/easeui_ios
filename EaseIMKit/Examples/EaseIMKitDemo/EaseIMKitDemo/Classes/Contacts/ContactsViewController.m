//
//  ContactsViewController.m
//  EaseIMKitDemo
//
//  Created by 杜洁鹏 on 2020/11/5.
//  Copyright © 2020 djp. All rights reserved.
//

#import "ContactsViewController.h"
#import <EaseIMKit.h>

@interface ContactsViewController () <EaseTableViewDelegaate>

@end

@implementation ContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    EaseContactsViewModel *model = [[EaseContactsViewModel alloc] init];
    EaseContactsViewController *contactsVC = [[EaseContactsViewController alloc] initWithViewModel:model];
    contactsVC.easeDelegate = self;
    [self.view addSubview:contactsVC.view];
    contactsVC.view.frame = self.view.bounds;
    [self addChildViewController:contactsVC];
}

- (void)easeTableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
