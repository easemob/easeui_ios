//
//  EMChatroomViewController.m
//  EaseIM
//
//  Created by 娜塔莎 on 2020/7/9.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import "EMChatroomViewController.h"
#import "EaseAlertController.h"
#import "EaseAlertView.h"
#import "UIViewController+HUD.h"
#import "EaseChatViewController+EaseUI.h"

@interface EMChatroomViewController ()

@end

@implementation EMChatroomViewController

- (instancetype)initChatRoomViewControllerWithCoversationid:(NSString *)conversationId
                                              chatViewModel:(EaseChatViewModel *)viewModel
{
    return [super initChatViewControllerWithCoversationid:conversationId
                       conversationType:EMConversationTypeChatRoom
                          chatViewModel:(EaseChatViewModel *)viewModel];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _joinChatroom];
}

#pragma mark - Private

- (void)_joinChatroom
{
    __weak typeof(self) weakself = self;
    [self showHudInView:self.view hint:EaseLocalizableString(@"joinChatroom...", nil)];
    [[EMClient sharedClient].roomManager joinChatroom:self.currentConversation.conversationId completion:^(EMChatroom *aChatroom, EMError *aError) {
        [weakself hideHud];
        if (aError) {
            [EaseAlertController showErrorAlert:EaseLocalizableString(@"joinChatroomFail", nil)];
        }
    }];
}

@end
