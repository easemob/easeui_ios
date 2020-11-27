//
//  EaseChatControllerProducter.h
//  EaseIM
//
//  Created by 娜塔莎 on 2020/8/6.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EaseChatViewController.h"
#import "EaseChatViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface EaseChatControllerProducter : NSObject

/**
 * 生产传入对应会话类型参数的会话聊天控制器
 *
 * @param   conversationId      会话ID
 *  对于单聊类型，会话ID同时也是对方用户的名称。
 *  对于群聊类型，会话ID同时也是对方群组的ID，并不同于群组的名称。
 *  对于聊天室类型，会话ID同时也是聊天室的ID，并不同于聊天室的名称。
 *  对于HelpDesk类型，会话ID与单聊类型相同，是对方用户的名称。
 *
 * @param   conType                     会话类型
 * @param   viewModel                聊天控制器视图渲染数据模型
 *
 */
+ (EaseChatViewController *)getChatControllerInstance:(NSString *)conversationId conversationType:(EMConversationType)conType chatViewModel:(EaseChatViewModel *)viewModel;

@end

NS_ASSUME_NONNULL_END
