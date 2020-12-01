//
//  EaseUserDelegate.h
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/11/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol EaseUserDelegate <NSObject>
@required
@property (nonatomic, copy, readonly) NSString *easeId;           // 环信id
@optional
@property (nonatomic, copy, readonly) NSString *showName;         // 显示昵称
@property (nonatomic, copy, readonly) NSString *avatarURL;        // 显示头像的url
@property (nonatomic, copy, readonly) UIImage *defaultAvatar;     // 默认头像显示

@end

NS_ASSUME_NONNULL_END
