//
//  ChatViewController.h
//  EaseIMKitDemo
//
//  Created by 娜塔莎 on 2020/11/17.
//  Copyright © 2020 djp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EaseIMKit/EaseIMKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface ChatViewController : UIViewController
@property (nonatomic, strong) NSString *chatter;
@property (nonatomic) EMConversationType conversationType;
@end

NS_ASSUME_NONNULL_END
