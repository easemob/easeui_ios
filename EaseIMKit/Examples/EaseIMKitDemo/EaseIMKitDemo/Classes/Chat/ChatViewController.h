//
//  ChatViewController.h
//  EaseIMKitDemo
//
//  Created by 娜塔莎 on 2020/11/17.
//  Copyright © 2020 djp. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface ChatViewController : UIViewController

- (instancetype)initWithConversationId:(NSString *)conversationId conversationType:(EMConversationType)conType;
@end

NS_ASSUME_NONNULL_END
