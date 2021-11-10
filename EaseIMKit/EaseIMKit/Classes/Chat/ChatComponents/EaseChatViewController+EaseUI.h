//
//  EaseChatViewController+EaseUI.h
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/12/2.
//  Copyright © 2020 djp. All rights reserved.
//

#import "EaseChatViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface EaseChatViewController (EaseUI)
- (instancetype)initChatViewControllerWithCoversationid:(NSString *)conversationId
                                        conversationType:(EMConversationType)conType
                                            chatViewModel:(EaseChatViewModel *)viewModel;
@end

NS_ASSUME_NONNULL_END
