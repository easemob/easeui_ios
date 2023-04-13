//
//  EaseConversationModel.h
//  EaseIMKit
//
//  Created by 娜塔莎 on 2020/11/10.
//

#import "EaseUserDelegate.h"
#import <UIKit/UIKit.h>
#import "EasePublicHeaders.h"
NS_ASSUME_NONNULL_BEGIN

@interface EaseConversationModel : NSObject

- (instancetype)initWithConversation:(EMConversation *)conversation;

@property (nonatomic) id<EaseUserDelegate> userDelegate;

@property (nonatomic, strong, readonly) NSString *easeId;
@property (nonatomic, strong, readonly) NSString *showName;
@property (nonatomic, strong, readonly) NSString *avatarURL;
@property (nonatomic, strong, readonly) UIImage *defaultAvatar;

@property (nonatomic, readonly) EMConversationType type; //会话聊天类型
@property (nonatomic, readonly) int unreadMessagesCount; //对话中未读取的消息数量
@property (nonatomic, readonly) long long lastestUpdateTime;
@property (nonatomic, readonly) BOOL showBadgeValue;//YES显示数字默 NO显示红点

@property (nonatomic) BOOL isTop;
@property (nonatomic, copy, readonly) NSAttributedString *showInfo;
@property (nonatomic, assign) BOOL hasAtMessage;
//@property (nonatomic, copy) NSString *draft;

@end

NS_ASSUME_NONNULL_END
