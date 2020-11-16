//
//  EaseItemDelegate.h
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/11/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol EaseItemDelegate <NSObject>

@required
@property (nonatomic, copy, readonly) NSString *itemId; // item id
@property (nonatomic, copy) NSString *showName;         // 显示昵称
@property (nonatomic, copy) NSString *avatarURL;        // 显示头像的url
@property (nonatomic, copy) UIImage *defaultAvatar;     // 默认头像显示

@end

NS_ASSUME_NONNULL_END
