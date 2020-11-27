//
//  ContactModel.h
//  EaseIMKitDemo
//
//  Created by 杜洁鹏 on 2020/11/24.
//  Copyright © 2020 djp. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ContactModel : NSObject <EaseUserDelegate>
@property (nonatomic, strong) NSString *huanXinId;
@property (nonatomic, strong) UIImage *avatar;
@property (nonatomic, strong) NSString *nickname;

- (UIImage *)defaultAvatar;
- (NSString *)showName;
@end

NS_ASSUME_NONNULL_END
