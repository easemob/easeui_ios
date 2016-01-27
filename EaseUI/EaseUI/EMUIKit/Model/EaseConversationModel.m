//
//  EaseConversationModel.m
//  ChatDemo-UI3.0
//
//  Created by dhc on 15/6/25.
//  Copyright (c) 2015年 easemob.com. All rights reserved.
//

#import "EaseConversationModel.h"

#import "EMConversation.h"

@implementation EaseConversationModel

- (instancetype)initWithConversation:(EMConversation *)conversation
{
    self = [super init];
    if (self) {
        _conversation = conversation;
        _title = _conversation.conversationId;
        if (conversation.type == EMConversationTypeChat) {
            _avatarImage = [UIImage imageNamed:@"EaseUIResource.bundle/user"];
        }
        else{
            _avatarImage = [UIImage imageNamed:@"EaseUIResource.bundle/group"];
        }
    }
    
    return self;
}

@end
