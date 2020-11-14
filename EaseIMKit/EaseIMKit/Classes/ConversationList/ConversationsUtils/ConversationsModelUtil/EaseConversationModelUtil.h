//
//  EaseConversationModelUtil.h
//  EaseIMKit
//
//  Created by 娜塔莎 on 2020/11/10.
//

#import "EMNotificationHelper.h"
#import "EaseConversationItemModelDelegate.h"

NS_ASSUME_NONNULL_BEGIN
static NSString *kConversation_IsRead = @"kHaveAtMessage";//群聊@功能
static NSString *kConversation_AtYou = @"1";
static NSString *kConversation_AtAll = @"2";
static NSString *kConversation_Draft = @"kDraft";//草稿

@protocol EaseConversationsDelegate;
@interface EaseConversationModelUtil : NSObject

- (void)addDelegate:(id<EaseConversationsDelegate>)aDelegate;

- (void)removeDelegate:(id<EaseConversationsDelegate>)aDelegate;

+ (instancetype)shared;

+ (NSArray<id<EaseConversationItemModelDelegate>> *)modelsFromEMConversations:(NSArray<EMConversation *> *)aConversations;

+ (EMConversation *)getConversationWithConversationModel:(id<EaseConversationItemModelDelegate>)conversationItemModel;

+ (id<EaseConversationItemModelDelegate>)modelFromContact:(NSString *)aContact;

+ (id<EaseConversationItemModelDelegate>)modelFromGroup:(EMGroup *)aGroup;

+ (id<EaseConversationItemModelDelegate>)modelFromChatroom:(EMChatroom *)aChatroom;

//调用该方法，会触发[EMConversationsDelegate didConversationUnreadCountToZero:]
+ (void)markAllAsRead:(id<EaseConversationItemModelDelegate>)conversationItemModel;

//调用该方法，会触发[EMConversationsDelegate didResortConversationsLatestMessage]
+ (void)resortConversationsLatestMessage;

@end


@protocol EaseConversationsDelegate <NSObject>

@optional

- (void)didConversationUnreadCountToZero:(id<EaseConversationItemModelDelegate>)conversationItemModel;

- (void)didResortConversationsLatestMessage;

@end

NS_ASSUME_NONNULL_END
