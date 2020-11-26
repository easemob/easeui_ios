//
//  EaseChatControllerProducter.m
//  EaseIM
//
//  Created by 娜塔莎 on 2020/8/6.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import "EaseChatControllerProducter.h"
#import "EMSingleChatViewController.h"
#import "EMGroupChatViewController.h"
#import "EMChatroomViewController.h"

@implementation EaseChatControllerProducter

+ (EaseChatViewController *)getChatControllerInstance:(NSString *)conversationId conversationType:(EMConversationType)conType chatViewModel:(EaseViewModel *)viewModel
{
    if (conType == EMConversationTypeChat)
        return [[EMSingleChatViewController alloc]initWithCoversationid:conversationId conversationType:conType  chatViewModel:(EaseViewModel *)viewModel];
    if (conType == EMConversationTypeGroupChat)
        return [[EMGroupChatViewController alloc]initWithCoversationid:conversationId conversationType:conType  chatViewModel:(EaseViewModel *)viewModel];
    if (conType == EMConversationTypeChatRoom)
        return [[EMChatroomViewController alloc]initWithCoversationid:conversationId conversationType:conType  chatViewModel:(EaseViewModel *)viewModel];
    
    return [[EaseChatViewController alloc]initWithCoversationid:conversationId conversationType:conType  chatViewModel:(EaseViewModel *)viewModel];
}

@end
