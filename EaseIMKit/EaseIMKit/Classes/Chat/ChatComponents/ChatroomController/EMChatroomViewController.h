//
//  EMChatroomViewController.h
//  EaseIM
//
//  Created by 娜塔莎 on 2020/7/9.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMChatViewController.h"
#import "EMViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMChatroomViewController : EMChatViewController

- (instancetype)initWithCoversationid:(NSString *)conversationId conversationType:(EMConversationType)conType chatViewModel:(EMViewModel *)viewModel;

@end

NS_ASSUME_NONNULL_END
