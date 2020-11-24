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
{
    EaseContactsViewController *_contactsVC;
}
@end

@implementation ContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    EaseContactsViewModel *model = [[EaseContactsViewModel alloc] init];
    model.avatarType = Rectangular;
    model.sectionTitleColor = UIColor.redColor;
    model.sectionTitleBgColor = UIColor.clearColor;
    model.sectionTitleFont = [UIFont systemFontOfSize:40];
    model.sectionTitleLabelHeight = 50;
    model.sectionTitleEdgeInsets= UIEdgeInsetsMake(0, 0, 0, 0);
    _contactsVC = [[EaseContactsViewController alloc] initWithViewModel:model];
    _contactsVC.customHeaderItems = [self items];
    _contactsVC.delegate = self;
    [self.view addSubview:_contactsVC.view];
    _contactsVC.view.frame = self.view.bounds;
    [self addChildViewController:_contactsVC];
}

- (NSArray<EaseUserDelegate> *)items {
    ContactModel *newFriends = [[ContactModel alloc] init];
    newFriends.nickname = @"新的好友";
    newFriends.avatar = [UIImage imageNamed:@"newFriends.png"];
    ContactModel *groups = [[ContactModel alloc] init];
    groups.nickname = @"群组";
    groups.avatar = [UIImage imageNamed:@"groups.png"];
    
    return (NSArray<EaseUserDelegate> *)@[newFriends, groups];
}

- (void)willBeginRefresh {
    [EMClient.sharedClient.contactManager getContactsFromServerWithCompletion:^(NSArray *aList, EMError *aError) {
        if (!aError) {
            NSMutableArray<EaseUserDelegate> *contacts = [NSMutableArray<EaseUserDelegate> array];
            for (NSString *username in aList) {
                ContactModel *model = [[ContactModel alloc] init];
                model.huanXinId = username;
                [contacts addObject:model];
            }
            
            [self->_contactsVC setContacts:contacts];
        }
        [self->_contactsVC endRefresh];
    }];
}

- (void)easeTableView:(UITableView *)tableView didSelectRowAtContactModel:(EaseContactModel *)contact {
    NSLog(@"contact -- %@", contact.easeId);
}

@end
