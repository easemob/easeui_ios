//
//  IUserModel.h
//  ChatDemo-UI3.0
//
//  Created by dhc on 15/6/24.
//  Copyright (c) 2015年 easemob.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class EMBuddy;
@protocol IUserModel <NSObject>

@property (strong, nonatomic, readonly) EMBuddy *buddy;
@property (strong, nonatomic) NSString *nickname;
@property (strong, nonatomic) NSString *avatarURLPath;
@property (strong, nonatomic) UIImage *avatarImage;

- (instancetype)initWithBuddy:(EMBuddy *)buddy;

@end
