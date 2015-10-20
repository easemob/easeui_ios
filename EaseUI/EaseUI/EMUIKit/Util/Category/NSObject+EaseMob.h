//
//  NSObject+EaseMob.h
//  ChatDemo-UI3.0
//
//  Created by dhc on 15/6/26.
//  Copyright (c) 2015年 easemob.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (EaseMob)

- (void)registerEaseMobLiteNotification;

- (void)unregisterEaseMobLiteNotification;

- (void)registerEaseMobNotification;

- (void)unregisterEaseMobNotification;

@end
