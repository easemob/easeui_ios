//
//  EaseContactModelDelegate.h
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/11/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    Normal,
    Contact,
} EaseContactModelType;


@protocol EaseContactModelDelegate <NSObject>

@required
@property (nonatomic, copy, readonly) NSString *avatarURL; // 显示头像的url
@property (nonatomic, copy, readonly) UIImage *defaultAvatar; // 默认头像显示
@property (nonatomic, copy, readonly) NSString *showName; // 显示头像的昵称
@property (nonatomic, copy, readonly) NSString *firstLetter; // 首字母
@property (nonatomic, assign) EaseContactModelType type;

@end

NS_ASSUME_NONNULL_END
