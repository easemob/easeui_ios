//
//  EaseConversationModelUtil.h
//  EaseIMKit
//
//  Created by 娜塔莎 on 2020/11/10.
//

#import "EMNotificationHelper.h"
#import "EaseConversationModel.h"
#import "EaseConversationModelDelegate.h"

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

+ (NSArray<EaseConversationModel *> *)modelsFromEMConversations:(NSArray<EMConversation *> *)aConversations;

+ (EMConversation *)getConversationWithConversationModel:(EaseConversationModel *)conversationModel;

+ (EaseConversationModel *)modelFromContact:(NSString *)aContact;

+ (EaseConversationModel *)modelFromGroup:(EMGroup *)aGroup;

+ (EaseConversationModel *)modelFromChatroom:(EMChatroom *)aChatroom;

//调用该方法，会触发[EMConversationsDelegate didConversationUnreadCountToZero:]
+ (void)markAllAsRead:(EaseConversationModel *)aConversationModel;

//调用该方法，会触发[EMConversationsDelegate didResortConversationsLatestMessage]
+ (void)resortConversationsLatestMessage;

@end


@protocol EaseConversationsDelegate <NSObject>

@optional

- (void)didConversationUnreadCountToZero:(EaseConversationModel *)aConversation;

- (void)didResortConversationsLatestMessage;

@end

NS_ASSUME_NONNULL_END
