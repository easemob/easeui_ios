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
#define EMConversationLatestUpdateTime @"EMConversationLatestUpdateTime"

@implementation EMConversation (EaseUI)

- (void)setTop:(BOOL)isTop {
    if (isTop) {
        self.latestUpdateTime = [[NSDate new] timeIntervalSince1970] * 1000;
    }else {
        self.latestUpdateTime = 0;
    }
    NSMutableDictionary *dictionary = [self mutableExt];
    [dictionary setObject:@(isTop) forKey:EMConversationTop];
    [self setExt:dictionary];
}

- (BOOL)isTop {
    return [self.ext[EMConversationTop] boolValue];
}

- (void)setShowName:(NSString *)aShowName {
    NSMutableDictionary *dictionary = [self mutableExt];
    [dictionary setObject:aShowName forKey:EMConversationShowName];
    [self setExt:dictionary];
}

- (NSString *)showName {
    return self.ext[EMConversationShowName] ? self.ext[EMConversationShowName] : self.conversationId;
}

- (void)setDraft:(NSString *)aDraft {
    self.latestUpdateTime = [[NSDate new] timeIntervalSince1970];
    NSMutableDictionary *dictionary = [self mutableExt];
    [dictionary setObject:aDraft forKey:EMConversationDraft];
    [self setExt:dictionary];
}

- (NSString *)draft {
    return self.ext[EMConversationDraft] ? self.ext[EMConversationDraft] : @"";
}

- (BOOL)remindMe {
    //判断会话类型和消息是否包含@我
    if (self.type != EMConversationTypeGroupChat) {
        return NO;
    }
    BOOL ret = NO;
    NSMutableArray *msgIdArray = [self remindMeArray];
    /*
    for (NSString *msgId in msgIds) {
        EMChatMessage *msg = [self loadMessageWithId:msgId error:nil];
        if (!msg.isRead && msg.body.type == EMMessageBodyTypeText) {
            EMTextMessageBody *textBody = (EMTextMessageBody*)msg.body;
            if ([textBody.text containsString:[NSString stringWithFormat:@"@%@",EMClient.sharedClient.currentUsername]]) {
                ret = YES;
                break;
            }
        }
    }*/
    if ([msgIdArray count] > 0) {
        ret = YES;
    }
    
    return ret;
}

- (NSMutableArray *)remindMeArray {
    NSMutableArray *dict = [(NSMutableArray *)self.ext[EMConversationRemindMe] mutableCopy];
    if (!dict) {
        dict = [[NSMutableArray alloc]init];
    }
    
    return dict;
}

- (void)setRemindMe:(NSString *)messageId
{
    NSMutableDictionary *dict = [self mutableExt];
    NSMutableArray *msgIdArray = [self remindMeArray];
    [msgIdArray addObject:messageId];
    [dict setObject:msgIdArray forKey:EMConversationRemindMe];
    [self setExt:dict];
}

- (void)resetRemindMe
{
    NSMutableArray *msgIdArray = [self remindMeArray];
    [msgIdArray removeAllObjects];
    NSMutableDictionary *dict = [self mutableExt];
    [dict setObject:msgIdArray forKey:EMConversationRemindMe];
    [self setExt:dict];
}

- (NSMutableDictionary *)mutableExt {
    NSMutableDictionary *mutableExt = [self.ext mutableCopy];
    if (!mutableExt) {
        mutableExt = [NSMutableDictionary dictionary];
    }
    
    return mutableExt;
}

- (void)setLatestUpdateTime:(long long)latestUpdateTime {
    NSMutableDictionary *dict = [self mutableExt];
    [dict setObject:@(latestUpdateTime) forKey:EMConversationLatestUpdateTime];
    [self setExt:dict];
}

- (long long)latestUpdateTime {
    NSMutableDictionary *dict = [self mutableExt];
    long long latestUpdateTime = [dict[EMConversationLatestUpdateTime] longLongValue];
    return latestUpdateTime > self.latestMessage.timestamp ? latestUpdateTime : self.latestMessage.timestamp;
}

@end
