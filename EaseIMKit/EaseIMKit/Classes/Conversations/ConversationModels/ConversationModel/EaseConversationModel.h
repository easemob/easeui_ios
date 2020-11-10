//
//  EaseConversationModel.h
//  EaseIMKit
//
//  Created by 娜塔莎 on 2020/11/10.
//

#import <Foundation/Foundation.h>
#import <Hyphenate/Hyphenate.h>
#import "EaseConversationModelDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface EaseConversationModel : NSObject <EaseConversationModelDelegate>

@property (nonatomic, copy, readonly) NSString *conversationId; //会话id
@property (nonatomic, assign, readonly) EMConversationType conversationType; //会话聊天类型
@property (nonatomic, assign) int unreadMessagesCount; //对话中未读取的消息数量
@property (nonatomic, copy) NSDictionary *ext; //会话扩展属性
@property (nonatomic, strong) EMMessage *latestMessage; //会话最新一条消息

@property (nonatomic) EaseConversationModelType conversationModelType; //会话model类型
@property (nonatomic, strong) NSString *conversationTheme; //会话主题
@property (nonatomic) long long timestamp; //会话最新消息时间戳
@property (nonatomic) BOOL isStick; //会话是否置顶
@property (nonatomic) long stickTime; //会话置顶时间

- (instancetype)initWithEMConversation:(EMConversation *)conversation;
//更新会话列表model
- (id<EaseConversationModelDelegate>)renewalModelWithModel:(id<EaseConversationModelDelegate>)model;
@end

NS_ASSUME_NONNULL_END
