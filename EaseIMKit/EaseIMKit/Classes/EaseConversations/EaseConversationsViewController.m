//
//  EaseConversationsViewController.m
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/10/29.
//

#import "EaseConversationsViewController.h"
#import <Hyphenate/Hyphenate.h>

@interface EaseConversationsViewController ()<EMChatManagerDelegate>
{
    EaseConversationVCOptions *_options;
}
@end

@implementation EaseConversationsViewController

- (instancetype)initWithOptions:(EaseConversationVCOptions *)options {
 if (self = [super init]) {
     _options = options;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [EMClient.sharedClient.chatManager addDelegate:self delegateQueue:nil];
    [self reloadViewWithModel];
}

- (void)reloadViewWithModel {
    
}

#pragma mark - EMChatManagerDelegate
- (void)messagesDidReceive:(NSArray *)aMessages {
    
}

@end
