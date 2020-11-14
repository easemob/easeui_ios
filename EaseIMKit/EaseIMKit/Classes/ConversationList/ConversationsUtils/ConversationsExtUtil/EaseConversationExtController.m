//
//  EaseConversationExtController.m
//  EaseIMKit
//
//  Created by 娜塔莎 on 2020/11/4.
//

#import "EaseConversationExtController.h"

static NSDateFormatter *_dateFormatter = nil;
@implementation EaseConversationExtController

//置顶会话
+ (void)stickConversation:(id<EaseConversationItemModelDelegate>)model
{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [EaseConversationExtController getDataFormatter];
    NSDate *time = [formatter dateFromString:[formatter stringFromDate:date]];
    NSTimeInterval stickTimeInterval = [time timeIntervalSince1970];
    NSNumber *stickTime = [NSNumber numberWithLong:stickTimeInterval];
    
    NSMutableDictionary *ext = [[NSMutableDictionary alloc]initWithDictionary:model.ext];
    [ext setObject:stickTime forKey:CONVERSATION_STICK];
    //重置会话
    EMConversation *conversation = [EaseConversationModelUtil getConversationWithConversationModel:model];
    [conversation setExt:ext];
}

//取消置顶会话
+ (void)cancelStickConversation:(id<EaseConversationItemModelDelegate>)model
{
    NSMutableDictionary *ext = [[NSMutableDictionary alloc]initWithDictionary:model.ext];
    [ext setObject:[NSNumber numberWithLong:0] forKey:CONVERSATION_STICK];
    //重置会话
    EMConversation *conversation = [EaseConversationModelUtil getConversationWithConversationModel:model];
    [conversation setExt:ext];
}

//设置群聊@提醒
+ (void)groupChatAtOperate:(EMConversation*)conversation
{
    //群聊@“我”提醒
    NSMutableDictionary *dic;
    if (conversation.ext) {
        dic = [[NSMutableDictionary alloc]initWithDictionary:conversation.ext];
    } else {
        dic = [[NSMutableDictionary alloc]init];
    }
    [dic setObject:kConversation_AtYou forKey:kConversation_IsRead];
    [conversation setExt:dic];
}

//是否有群聊@我
+ (BOOL)isConversationAtMe:(EMConversation*)conversation
{
    if (conversation.ext && [conversation.ext[kConversation_IsRead] isEqualToString:kConversation_AtYou]) {
        return YES;
    }
    return NO;
}

//设置聊天会话草稿
+ (void)chatDraftOperate:(EMConversation*)conversation content:(NSString*)draftContent
{
    NSMutableDictionary *ext = [[NSMutableDictionary alloc]initWithDictionary:conversation.ext];
    [ext setObject:draftContent forKey:kConversation_Draft];
    [conversation setExt:ext];
}

//获取聊天会话草稿
+ (NSString*)getChatDraft:(EMConversation*)conversation
{
    NSString *draftStr = nil;
    if (conversation.ext && [conversation.ext objectForKey:kConversation_Draft]) {
        draftStr = [conversation.ext objectForKey:kConversation_Draft];
    }
    return draftStr;
}

#pragma mark - getter

+ (NSDateFormatter *)getDataFormatter
{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc]init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    return _dateFormatter;
}

@end
