//
//  EMChatroomViewController.m
//  EaseIM
//
//  Created by 娜塔莎 on 2020/7/9.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import "EMChatroomViewController.h"

@interface EMChatroomViewController ()

@end

@implementation EMChatroomViewController

- (instancetype)initWithCoversationid:(NSString *)conversationId conversationType:(EMConversationType)conType chatViewModel:(EaseChatViewModel *)viewModel
{
    return [super initWithCoversationid:conversationId conversationType:conType chatViewModel:(EaseChatViewModel *)viewModel];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _joinChatroom];
}

#pragma mark - Private

- (void)_joinChatroom
{
    __weak typeof(self) weakself = self;
    [self showHudInView:self.view hint:@"加入聊天室..."];
    [[EMClient sharedClient].roomManager joinChatroom:self.currentConversation.conversationId completion:^(EMChatroom *aChatroom, EMError *aError) {
        [weakself hideHud];
        if (aError) {
            [EaseAlertController showErrorAlert:@"加入聊天室失败"];
        } else {
            [weakself tableViewDidTriggerHeaderRefresh];
        }
    }];
}

@end
