//
//  ChatViewController.m
//  EaseIMKitDemo
//
//  Created by 娜塔莎 on 2020/11/17.
//  Copyright © 2020 djp. All rights reserved.
//

#import "ChatViewController.h"
#import <EaseIMKit.h>

@interface ChatViewController ()

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    EaseViewModel *viewModel = [[EaseViewModel alloc]init];
    //viewModel.chatBarStyle = EMChatBarStyleLackEmoji;
    EaseChatViewController *chatController = [EaseChatControllerProducter getChatControllerInstance:@"nats" conversationType:EMConversationTypeChat chatViewModel:viewModel];
    [self addChildViewController:chatController];
    //self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:chatController.view];
    [chatController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self.view);
    }];
}


@end
