//
//  ConversationsViewController.m
//  EaseIMKitDemo
//
//  Created by 杜洁鹏 on 2020/11/5.
//  Copyright © 2020 djp. All rights reserved.
//

#import "ConversationsViewController.h"
#import <EaseIMKit.h>

@interface ConversationsViewController ()<EaseConversationVCDelegate>

@end

@implementation ConversationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [EaseIMKitManager.shareEaseIMKit.conversationListController addDelegate:self];
    EaseConversationsViewController *conversationsController = (EaseConversationsViewController *)EaseIMKitManager.shareEaseIMKit.conversationListController;
    [self addChildViewController:conversationsController];
    [self.view addSubview:conversationsController.view];
    [conversationsController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(44);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
}
   
#pragma mark - EaseConversationVCDelegate

- (NSString *)requestDidReceiveShowMessage:(NSString *)conversationId requestUser:(NSString *)requestUser reason:(EaseIMKitCallBackReason)reason
{
    if (reason == ContanctsRequestDidReceive) {
        return @"空洞洞";
    }
    return nil;
}

- (UIContextualAction *)sideslipCustomAction:(UITableView *)tableView dataArray:(NSMutableArray *)dataArray trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIContextualAction *customAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"自定义" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        NSLog(@"customAction");
    }];
    customAction.backgroundColor = [UIColor orangeColor];
    return customAction;
}

@end
