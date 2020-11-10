//
//  EaseConversationStickController.h
//  EaseIMKit
//
//  Created by 娜塔莎 on 2020/11/4.
//

#import <Foundation/Foundation.h>
#import "EMHeaders.h"

NS_ASSUME_NONNULL_BEGIN

@interface EaseConversationStickController : NSObject

//置顶会话
+ (void)stickConversation:(id<EaseConversationModelDelegate>)model;

//取消置顶会话
+ (void)cancelStickConversation:(id<EaseConversationModelDelegate>)model;

//会话是否已置顶
+ (BOOL)isConversationStick:(id<EaseConversationModelDelegate>)model;

@end

NS_ASSUME_NONNULL_END
