//
//  EMConversationHelper.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/14.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMNotificationHelper.h"

NS_ASSUME_NONNULL_BEGIN
static NSString *kConversation_IsRead = @"kHaveAtMessage";//群聊@功能
static NSString *kConversation_AtYou = @"1";
static NSString *kConversation_AtAll = @"2";
static NSString *kConversation_Draft = @"kDraft";//草稿

//会话model类型
typedef enum {
    EaseConversation = 0, //会话聊天类型
    EaseSystemNotification,   //系统通知类型
} EaseConversationModelType;

//会话列表项model模型
@protocol EaseConversationModelDelegate <NSObject>

@property (nonatomic) EaseConversationModelType conversationModelType; //会话model类型
@property (nonatomic, strong) NSString *conversationTheme; //会话主题
@property (nonatomic) long long timestamp; //会话最新消息时间戳
@property (nonatomic) BOOL isStick; //会话是否置顶
@property (nonatomic) long stickTime; //会话置顶时间

@end

//会话聊天model
@interface EMConversationModel : NSObject <EaseConversationModelDelegate>

@property (nonatomic, copy, readonly) NSString *conversationId; //会话id
@property (nonatomic, assign, readonly) EMConversationType conversationType; //会话聊天类型
@property (nonatomic, assign, readonly) int unreadMessagesCount; //对话中未读取的消息数量
@property (nonatomic, copy) NSDictionary *ext; //会话扩展属性
@property (nonatomic, strong) EMMessage *latestMessage; //会话最新一条消息

@property (nonatomic) EaseConversationModelType conversationModelType; //会话model类型
@property (nonatomic, strong) NSString *conversationTheme; //会话主题
@property (nonatomic) long long timestamp; //会话最新消息时间戳
@property (nonatomic) BOOL isStick; //会话是否置顶
@property (nonatomic) long stickTime; //会话置顶时间

- (instancetype)initWithEMConversation:(EMConversation *)conversation;
@end

//系统通知model
@interface EMSystemNotificationModel : NSObject <EaseConversationModelDelegate>

@property (nonatomic, strong) NSString *notificationSender; //通知来源
@property (nonatomic, strong) NSString *latestNotificTime; //通知时间
@property (nonatomic) EMNotificationModelType notificationType; //通知类型

@property (nonatomic) EaseConversationModelType conversationModelType; //会话model类型
@property (nonatomic, strong) NSString *conversationTheme; //会话主题
@property (nonatomic) long long timestamp; //会话最新消息时间戳
@property (nonatomic) BOOL isStick; //会话是否置顶
@property (nonatomic) long stickTime; //会话置顶时间

- (instancetype)initNotificationModel;

@end

@protocol EMConversationsDelegate;
@interface EMConversationHelper : NSObject

- (void)addDelegate:(id<EMConversationsDelegate>)aDelegate;

- (void)removeDelegate:(id<EMConversationsDelegate>)aDelegate;

+ (instancetype)shared;

+ (NSArray<EMConversationModel *> *)modelsFromEMConversations:(NSArray<EMConversation *> *)aConversations;

+ (EMConversation *)getConversationWithConversationModel:(EMConversationModel *)conversationModel;

+ (EMConversationModel *)modelFromContact:(NSString *)aContact;

+ (EMConversationModel *)modelFromGroup:(EMGroup *)aGroup;

+ (EMConversationModel *)modelFromChatroom:(EMChatroom *)aChatroom;

//调用该方法，会触发[EMConversationsDelegate didConversationUnreadCountToZero:]
+ (void)markAllAsRead:(EMConversationModel *)aConversationModel;

//调用该方法，会触发[EMConversationsDelegate didResortConversationsLatestMessage]
+ (void)resortConversationsLatestMessage;

@end


@protocol EMConversationsDelegate <NSObject>

@optional

- (void)didConversationUnreadCountToZero:(EMConversationModel *)aConversation;

- (void)didResortConversationsLatestMessage;

@end

NS_ASSUME_NONNULL_END
