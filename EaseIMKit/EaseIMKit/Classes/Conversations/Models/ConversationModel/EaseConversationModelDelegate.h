//
//  EaseConversationModelDelegate.h
//  EaseIMKit
//
//  Created by 娜塔莎 on 2020/11/10.
//

#import <Hyphenate/Hyphenate.h>
#import <Foundation/Foundation.h>
#import "EaseItemDelegate.h"

NS_ASSUME_NONNULL_BEGIN

//会话列表项model模型
@protocol EaseConversationModelDelegate <EaseItemDelegate>


@property (nonatomic, readonly) EMConversationType type; //会话聊天类型
@property (nonatomic, readonly) int unreadMessagesCount; //对话中未读取的消息数量
@property (nonatomic, readonly) long long lastestUpdateTime;
@property (nonatomic, readonly) BOOL remindMe;
@property (nonatomic) BOOL isTop;
@property (nonatomic, copy, readonly) NSAttributedString *showInfo;
@property (nonatomic, copy) NSString *draft;

@optional
- (void)markAllAsRead;

@end

NS_ASSUME_NONNULL_END
