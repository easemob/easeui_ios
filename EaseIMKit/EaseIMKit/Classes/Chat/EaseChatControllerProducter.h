//
//  EaseChatControllerProducter.h
//  EaseIM
//
//  Created by 娜塔莎 on 2020/8/6.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EaseChatViewController.h"
#import "EaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface EaseChatControllerProducter : NSObject
//注释
//生产传入对应会话类型参数的会话聊天控制器
+ (EaseChatViewController *)getChatControllerInstance:(NSString *)conversationId conversationType:(EMConversationType)conType chatViewModel:(EaseViewModel *)viewModel;

@end

NS_ASSUME_NONNULL_END
