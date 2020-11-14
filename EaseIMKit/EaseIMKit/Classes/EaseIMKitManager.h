//
//  EaseIMKitManager.h
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/10/29.
//

#import <Foundation/Foundation.h>
#import "EaseHeaders.h"
#import "IEaseConversationVcDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface EaseIMKitManager : NSObject

+ (instancetype)shareEaseIMKit;

//会话列表视图控制器代理
@property (nonatomic, strong, readonly)id<IEaseConversationVcDelegate>conversationListController;

@end

NS_ASSUME_NONNULL_END
