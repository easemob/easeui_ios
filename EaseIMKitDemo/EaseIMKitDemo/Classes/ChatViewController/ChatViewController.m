//
//  ChatViewController.m
//  EaseIMKitDemo
//
//  Created by 娜塔莎 on 2020/11/17.
//  Copyright © 2020 djp. All rights reserved.
//

#import "ChatViewController.h"
#import <Masonry/Masonry.h>
#import <EaseIMKitLite/EaseIMKitLite.h>

@interface ChatViewController ()
@end

@implementation ChatViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    EaseChatViewModel *viewModel = [[EaseChatViewModel alloc]init];
    EaseChatViewController *chatController = [[EaseChatViewController alloc] initWithConversationId:self.chatter
                                                                                   conversationType:self.conversationType
                                                                                      chatViewModel:viewModel];
    [self addChildViewController:chatController];
    [self.view addSubview:chatController.view];
    [chatController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self.view);
    }];
    
}


@end
