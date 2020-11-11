//
//  EaseConversationModel.h
//  EaseIMKit
//
//  Created by 娜塔莎 on 2020/11/10.
//

#import <Foundation/Foundation.h>
#import <Hyphenate/Hyphenate.h>

NS_ASSUME_NONNULL_BEGIN

@interface EaseConversationModel : NSObject

@property (nonatomic, copy, readonly) NSString *conversationId; //会话id
@property (nonatomic, assign, readonly) EMConversationType conversationType; //会话聊天类型
@property (nonatomic, assign) int unreadMessagesCount; //对话中未读取的消息数量
@property (nonatomic, copy) NSDictionary *ext; //会话扩展属性
@property (nonatomic, strong) EMMessage *latestMessage; //会话最新一条消息
@property (nonatomic, strong) UIImage *avatarImg; //会话对象头像
@property (nonatomic, strong) NSString *conversationNickname; //会话对象昵称
@property (nonatomic) long long timestamp; //会话最新消息时间戳
@property (nonatomic) BOOL isStick; //会话是否置顶

- (instancetype)initWithEMConversation:(EMConversation *)conversation;

@end

NS_ASSUME_NONNULL_END
