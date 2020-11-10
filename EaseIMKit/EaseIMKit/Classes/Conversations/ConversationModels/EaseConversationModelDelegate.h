//
//  EaseConversationModelDelegate.h
//  EaseIMKit
//
//  Created by 娜塔莎 on 2020/11/10.
//


NS_ASSUME_NONNULL_BEGIN

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

- (id<EaseConversationModelDelegate>)renewalModelWithModel:(id<EaseConversationModelDelegate>)model;

@end

NS_ASSUME_NONNULL_END
