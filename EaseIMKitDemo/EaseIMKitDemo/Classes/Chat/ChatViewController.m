//
//  ChatViewController.m
//  EaseIMKitDemo
//
//  Created by 娜塔莎 on 2020/11/17.
//  Copyright © 2020 djp. All rights reserved.
//

#import "ChatViewController.h"
//#import <EaseIMKit.h>
#import "EaseIMKit.h"
//#import <EaseIMKit/EaseIMKit.h>

@interface ChatViewController ()
@property (nonatomic, strong)EaseChatViewController *chatController;
@end

@implementation ChatViewController

- (instancetype)initWithConversationId:(NSString *)conversationId conversationType:(EMConversationType)conType {
    if (self = [super init]) {
        EaseChatViewModel *viewModel = [[EaseChatViewModel alloc]init];
        _chatController = [EaseChatControllerProducter getChatControllerInstance:conversationId conversationType:EMConversationTypeChat chatViewModel:viewModel];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addChildViewController:_chatController];
    [self.view addSubview:_chatController.view];
    [_chatController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self.view);
    }];
    
}


@end
