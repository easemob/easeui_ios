//
//  ChatViewController.m
//  EaseIMKitDemo
//
//  Created by 娜塔莎 on 2020/11/17.
//  Copyright © 2020 djp. All rights reserved.
//

#import "ChatViewController.h"
#import <Masonry/Masonry.h>
#import <EaseIMKit/EaseIMKit.h>

@interface ChatViewController ()<EaseChatViewControllerDelegate>
@property (nonatomic, strong) EaseChatViewController *chatController;
@property (nonatomic, strong) NSString *firstMesgId;
@end

@implementation ChatViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    EaseChatViewModel *viewModel = [[EaseChatViewModel alloc]init];
    _chatController = [EaseChatViewController initWithConversationId:self.chatter
                                                    conversationType:self.conversationType
                                                       chatViewModel:viewModel];
    _chatController.delegate = self;
    [_chatController setEditingStatusVisible:YES];
    [self addChildViewController:_chatController];
    [self.view addSubview:_chatController.view];
    _chatController.view.frame = self.view.bounds;
    [self loadData:nil];
}

- (void)loadData:(NSArray<EMChatMessage *> *)messageList
{
    __weak typeof(self) weakself = self;
        void (^block)(NSArray *aMessages, EMError *aError) = ^(NSArray *aMessages, EMError *aError) {
            NSMutableArray *msgList = [NSMutableArray arrayWithArray:aMessages];
            if (messageList && [messageList count] && [msgList count]) {
                [msgList addObjectsFromArray:messageList];
            }
            [weakself.chatController refreshTableViewWithData:[msgList copy] isInsertBottom:NO isScrollBottom:YES];
        };
    EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:self.chatter type:self.conversationType createIfNotExist:NO];
    [conversation loadMessagesStartFromId:self.firstMesgId count:50 searchDirection:EMMessageSearchDirectionUp completion:block];
}

- (void)loadMoreMessageData:(NSString *)firstMessageId currentMessageList:(NSArray<EMChatMessage *> *)messageList
{
    self.firstMesgId = firstMessageId;
    [self loadData:messageList];
}

@end
