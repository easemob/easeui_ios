//
//  EaseUserModel.h
//  ChatDemo-UI3.0
//
//  Created by dhc on 15/6/24.
//  Copyright (c) 2015年 easemob.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IUserModel.h"

@interface EaseUserModel : NSObject<IUserModel>

@property (strong, nonatomic, readonly) NSString *buddy;
@property (strong, nonatomic) NSString *nickname;
@property (strong, nonatomic) NSString *avatarURLPath;
@property (strong, nonatomic) UIImage *avatarImage;

- (instancetype)initWithBuddy:(NSString *)buddy;

@end
