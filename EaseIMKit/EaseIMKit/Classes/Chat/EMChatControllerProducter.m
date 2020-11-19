//
//  EMChatControllerProducter.m
//  EaseIM
//
//  Created by 娜塔莎 on 2020/8/6.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import "EMChatControllerProducter.h"
#import "EMSingleChatViewController.h"
#import "EMGroupChatViewController.h"
#import "EMChatroomViewController.h"

@implementation EMChatControllerProducter

+ (EMChatViewController *)getChatControllerInstance:(NSString *)conversationId conversationType:(EMConversationType)conType chatViewModel:(EMViewModel *)viewModel
{
    if (conType == EMConversationTypeChat)
        return [[EMSingleChatViewController alloc]initWithCoversationid:conversationId conversationType:conType  chatViewModel:(EMViewModel *)viewModel];
    if (conType == EMConversationTypeGroupChat)
        return [[EMGroupChatViewController alloc]initWithCoversationid:conversationId conversationType:conType  chatViewModel:(EMViewModel *)viewModel];
    if (conType == EMConversationTypeChatRoom)
        return [[EMChatroomViewController alloc]initWithCoversationid:conversationId conversationType:conType  chatViewModel:(EMViewModel *)viewModel];
    
    return [[EMChatViewController alloc]initWithCoversationid:conversationId conversationType:conType  chatViewModel:(EMViewModel *)viewModel];
}

@end
