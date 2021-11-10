//
//  ContactsViewController.m
//  EaseIMKitDemo
//
//  Created by 杜洁鹏 on 2020/11/5.
//  Copyright © 2020 djp. All rights reserved.
//

#import "ContactsViewController.h"
#import "ChatViewController.h"
#import "ContactModel.h"
#import <Masonry/Masonry.h>
#import <EaseIMKit/EaseIMKit.h>

@interface ContactsViewController () <EaseContactsViewControllerDelegate>
{
    EaseContactsViewController *_contactsVC;
}
@end

@implementation ContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    EaseContactsViewModel *model = [[EaseContactsViewModel alloc] init];
    model.avatarType = Rectangular;
    model.sectionTitleEdgeInsets= UIEdgeInsetsMake(5, 15, 5, 5);
    _contactsVC = [[EaseContactsViewController alloc] initWithModel:model];
    _contactsVC.customHeaderItems = [self items];
    _contactsVC.delegate = self;
    [self.view addSubview:_contactsVC.view];
    
    [_contactsVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    [self addChildViewController:_contactsVC];
    [self updateContactViewTableHeader];
    
}

- (NSArray<EaseUserDelegate> *)items {
    ContactModel *newFriends = [[ContactModel alloc] init];
    newFriends.nickname = @"new friend";
    newFriends.avatar = [UIImage imageNamed:@"newFriends.png"];
    ContactModel *groups = [[ContactModel alloc] init];
    groups.nickname = @"groups";
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

    ChatViewController *chatVC = [[ChatViewController alloc] init];
    chatVC.chatter = contact.easeId;
    chatVC.conversationType = EMConversationTypeChat;
    chatVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatVC animated:YES];
}

- (void)updateContactViewTableHeader {
    _contactsVC.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    _contactsVC.tableView.tableHeaderView.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1];
    UIControl *control = [[UIControl alloc] initWithFrame:CGRectZero];
    control.clipsToBounds = YES;
    control.layer.cornerRadius = 18;
    control.backgroundColor = UIColor.whiteColor;
    
    [_contactsVC.tableView.tableHeaderView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_contactsVC.tableView);
        make.width.equalTo(_contactsVC.tableView);
        make.top.equalTo(_contactsVC.tableView);
        make.height.mas_equalTo(52);
    }];
    
    [_contactsVC.tableView.tableHeaderView addSubview:control];
    [control mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_offset(36);
        make.top.equalTo(_contactsVC.tableView.tableHeaderView).offset(8);
        make.bottom.equalTo(_contactsVC.tableView.tableHeaderView).offset(-8);
        make.left.equalTo(_contactsVC.tableView.tableHeaderView.mas_left).offset(17);
        make.right.equalTo(_contactsVC.tableView.tableHeaderView).offset(-16);
    }];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search"]];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = [UIFont systemFontOfSize:16];
    label.text = @"search";
    label.textColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1];
    [label setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    UIView *subView = [[UIView alloc] init];
    [subView addSubview:imageView];
    [subView addSubview:label];
    [control addSubview:subView];
    
    [imageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(15);
        make.left.equalTo(subView);
        make.top.equalTo(subView);
        make.bottom.equalTo(subView);
    }];
    
    [label mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imageView.mas_right).offset(3);
        make.right.equalTo(subView);
        make.top.equalTo(subView);
        make.bottom.equalTo(subView);
    }];
    
    [subView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(control);
    }];
}

@end
