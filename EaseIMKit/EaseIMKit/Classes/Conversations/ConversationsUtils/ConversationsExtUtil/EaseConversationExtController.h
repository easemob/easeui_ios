//
//  EaseConversationExtController.h
//  EaseIMKit
//
//  Created by 娜塔莎 on 2020/11/4.
//

#import <Foundation/Foundation.h>
#import "EMHeaders.h"

NS_ASSUME_NONNULL_BEGIN

@interface EaseConversationExtController : NSObject

//置顶会话
+ (void)stickConversation:(EaseConversationModel*)model;
//取消置顶会话
+ (void)cancelStickConversation:(EaseConversationModel*)model;

//设置群聊@提醒
+ (void)groupChatAtOperate:(EMConversation*)conversation;
//是否有群聊@我
+ (BOOL)isConversationAtMe:(EMConversation*)conversation;

//设置聊天会话草稿
+ (void)chatDraftOperate:(EMConversation*)conversation content:(NSString*)draftContent;
//获取聊天会话草稿
+ (NSString*)getChatDraft:(EMConversation*)conversation;

@end

NS_ASSUME_NONNULL_END
