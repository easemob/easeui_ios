//
//  EaseSystemNotiModel.h
//  EaseIMKit
//
//  Created by 娜塔莎 on 2020/11/10.
//

#import <Foundation/Foundation.h>
#import "EMNotificationHelper.h"
#import "EaseConversationModelDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface EaseSystemNotiModel : NSObject <EaseConversationModelDelegate>

@property (nonatomic, strong) NSString *notificationSender; //通知来源
@property (nonatomic, strong) NSString *latestNotificTime; //通知时间
@property (nonatomic) EMNotificationModelType notificationType; //通知类型

@property (nonatomic) EaseConversationModelType conversationModelType; //会话model类型
@property (nonatomic, strong) NSString *conversationTheme; //会话主题
@property (nonatomic) long long timestamp; //会话最新消息时间戳
@property (nonatomic) BOOL isStick; //会话是否置顶
@property (nonatomic) long stickTime; //会话置顶时间

- (instancetype)initNotificationModel;
//更新系统通知model
- (id<EaseConversationModelDelegate>)renewalModelWithModel:(id<EaseConversationModelDelegate>)model;

@end

NS_ASSUME_NONNULL_END
