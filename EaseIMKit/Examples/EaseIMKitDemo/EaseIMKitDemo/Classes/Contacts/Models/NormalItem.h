//
//  NormalItem.h
//  EaseIMKitDemo
//
//  Created by 杜洁鹏 on 2020/11/10.
//  Copyright © 2020 djp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EaseIMKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NormalItem : NSObject <EaseContactModelDelegate>
@property (nonatomic, copy) NSString *showName;
@property (nonatomic, copy) NSString *avatarURL;
@property (nonatomic, copy) NSString *defaultAvatar;
@end

NS_ASSUME_NONNULL_END
