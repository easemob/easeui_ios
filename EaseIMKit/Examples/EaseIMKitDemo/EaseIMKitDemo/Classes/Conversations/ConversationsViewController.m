//
//  ConversationsViewController.m
//  EaseIMKitDemo
//
//  Created by 杜洁鹏 on 2020/11/5.
//  Copyright © 2020 djp. All rights reserved.
//

#import "ConversationsViewController.h"
#import <EaseIMKit.h>
#import "EaseChatViewController.h"
#import "DemoUserModel.h"

@interface ConversationsViewController () <EaseConversationsViewControllerDelegate>
{
    EaseConversationsViewController *_easeConvsVC;
}
@end

@implementation ConversationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    EaseConversationViewModel *viewMdeol = [[EaseConversationViewModel alloc] init];
    viewMdeol.canRefresh = NO;
    viewMdeol.avatarType = Circular;
    viewMdeol.badgeLabelPosition = EMAvatarTopRight;
    
    _easeConvsVC = [[EaseConversationsViewController alloc] initWithModel:viewMdeol];
    _easeConvsVC.delegate = self;
    [self addChildViewController:_easeConvsVC];
    [self.view addSubview:_easeConvsVC.view];
    [_easeConvsVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
}
   
#pragma mark - EaseConversationsViewControllerDelegate

- (void)easeTableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EaseChatViewController *chatController = [[EaseChatViewController alloc]init];
    chatController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatController animated:YES];
}


- (id<EaseUserDelegate>)easeUserDelegateAtConversationId:(NSString *)conversationId
                                        conversationType:(EMConversationType)type
{
    
    DemoUserModel *model = [[DemoUserModel alloc] initWithEaseId:conversationId];
//    model.nickName =  @"我是昵称";
    return model;
}

@end
