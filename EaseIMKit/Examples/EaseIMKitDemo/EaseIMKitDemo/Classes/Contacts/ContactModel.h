//
//  ContactModel.h
//  EaseIMKitDemo
//
//  Created by 杜洁鹏 on 2020/11/24.
//  Copyright © 2020 djp. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ContactModel : NSObject <EaseContactDelegate>
@property (nonatomic, strong) UIImage *defaultAvatar;
@property (nonatomic, strong) NSString *showName;
@end

NS_ASSUME_NONNULL_END
