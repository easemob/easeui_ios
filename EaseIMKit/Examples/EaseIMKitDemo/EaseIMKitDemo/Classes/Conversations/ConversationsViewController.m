//
//  ConversationsViewController.m
//  EaseIMKitDemo
//
//  Created by 杜洁鹏 on 2020/11/5.
//  Copyright © 2020 djp. All rights reserved.
//

#import "ConversationsViewController.h"
#import "ConversationModel.h"
#import <EaseIMKit.h>
#import "EaseChatViewController.h"

@interface ConversationsViewController () <EaseConversationsViewControllerDelegate>
{
    EaseConversationViewModel *_viewMdeol;
}
@end

@implementation ConversationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _viewMdeol = [[EaseConversationViewModel alloc] init];
    _viewMdeol.canRefresh = NO;
    _viewMdeol.avatarType = Circular;
    _viewMdeol.badgeLabelPosition = EMAvatarTopRight;
    
    EaseConversationsViewController *easeConvsVC = [[EaseConversationsViewController alloc] initWithModel:_viewMdeol];
    easeConvsVC.delegate = self;
    [self addChildViewController:easeConvsVC];
    [self.view addSubview:easeConvsVC.view];
    [easeConvsVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
}
   
#pragma mark - EaseConversationVCDelegate

- (void)easeTableView:(UITableView *)tableView didSelectRowAtItem:(id<EaseItemDelegate>)item
{
    EaseChatViewController *chatController = [[EaseChatViewController alloc]init];
    [self.navigationController pushViewController:chatController animated:NO];
}

@end
