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
    
    EaseConversationsViewController *conversationsController = [[EaseConversationsViewController alloc]initWithOptions:nil];
    [self addChildViewController:conversationsController];
    conversationsController.conversationVCDelegate = self;
    [self.view addSubview:conversationsController.view];
    [conversationsController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(44);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
}

#pragma mark - EaseConversationVCDelegate

- (UITableViewRowAction *)sideslipCustomAction:(id<EaseConversationModelDelegate>)cellModel
{
    UITableViewRowAction *customAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"自定义" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NSLog(@"customAction");
    }];
    customAction.backgroundColor = [UIColor orangeColor];
    return customAction;
}

@end
