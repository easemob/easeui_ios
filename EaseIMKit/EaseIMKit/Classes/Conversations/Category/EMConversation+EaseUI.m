//
//  EMConversation+EaseUI.m
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/11/14.
//

#import "EMConversation+EaseUI.h"

#define EMConversationTop @"EMConversation_Top"
#define EMConversationShowName @"EMConversation_ShowName"
#define EMConversationRemindMe @"EMConversation_RemindMe"
#define EMConversationDraft @"EMConversation_Draft"

@implementation EMConversation (EaseUI)

- (void)setTop:(BOOL)isTop {
    [[self mutableExt] setObject:@(isTop) forKey:EMConversationTop];
}

- (BOOL)isTop {
    return [self.ext[EMConversationTop] boolValue];
}

- (void)setShowName:(NSString *)aShowName {
    [[self mutableExt] setObject:aShowName forKey:EMConversationShowName];
}

- (NSString *)showName {
    return self.ext[EMConversationShowName] ?: self.conversationId;
}

- (void)setDraft:(NSString *)aDraft {
    [[self mutableExt] setObject:aDraft forKey:EMConversationDraft];
}

- (NSString *)draft {
    return self.ext[EMConversationDraft];
}

- (BOOL)remindMe {
    BOOL ret = NO;
    NSArray *msgIds = [self remindMeDic].allKeys;
    for (NSString *msgId in msgIds) {
        EMMessage *msg = [self loadMessageWithId:msgId error:nil];
        if (!msg.isRead) {
            ret = YES;
            break;
        }
    }
    
    return ret;
}

- (NSMutableDictionary *)remindMeDic {
    NSMutableDictionary *dict = [(NSMutableDictionary *)self.ext[EMConversationRemindMe] mutableCopy];
    if (!dict) {
        dict = [NSMutableDictionary dictionary];
    }
    
    return dict;
}

- (NSMutableDictionary *)mutableExt {
    NSMutableDictionary *mutableExt = [self.ext mutableCopy];
    if (!mutableExt) {
        mutableExt = [NSMutableDictionary dictionary];
    }
    
    return mutableExt;
}


@end
