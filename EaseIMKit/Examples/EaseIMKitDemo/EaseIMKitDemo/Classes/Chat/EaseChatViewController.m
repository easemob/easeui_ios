//
//  EaseChatViewController.m
//  EaseIMKitDemo
//
//  Created by 娜塔莎 on 2020/11/17.
//  Copyright © 2020 djp. All rights reserved.
//

#import "EaseChatViewController.h"
#import <EaseIMKit.h>

@interface EaseChatViewController ()

@end

@implementation EaseChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    EMViewModel *viewModel = [[EMViewModel alloc]init];
    //viewModel.chatBarStyle = EMChatBarStyleLackEmoji;
    EMChatViewController *chatController = [EMChatControllerProducter getChatControllerInstance:self.chatter
                                                                               conversationType:EMConversationTypeChat chatViewModel:viewModel];
    [self addChildViewController:chatController];
    [self.view addSubview:chatController.view];
    [chatController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self.view);
    }];
}


@end
