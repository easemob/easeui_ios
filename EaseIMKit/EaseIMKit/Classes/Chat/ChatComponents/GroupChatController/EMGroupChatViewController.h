//
//  EMGroupChatViewController.h
//  EaseIM
//
//  Created by 娜塔莎 on 2020/7/9.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EaseChatViewController.h"
#import "EaseChatViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMGroupChatViewController : EaseChatViewController

- (instancetype)initWithCoversationid:(NSString *)conversationId conversationType:(EMConversationType)conType chatViewModel:(EaseChatViewModel *)viewModel;
//群组阅读回执
- (void)groupReadReceiptAction;

@end

NS_ASSUME_NONNULL_END
