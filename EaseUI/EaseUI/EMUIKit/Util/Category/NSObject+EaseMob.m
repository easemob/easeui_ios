//
//  NSObject+EaseMob.m
//  ChatDemo-UI3.0
//
//  Created by dhc on 15/6/26.
//  Copyright (c) 2015年 easemob.com. All rights reserved.
//

#import "NSObject+EaseMob.h"

#import "EaseMob.h"
#import "EaseSDKHelper.h"

@implementation NSObject (EaseMob)

- (void)registerEaseMobNotification
{
#if DEMO_CALL == 1
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
    [[EaseMob sharedInstance].callManager removeDelegate:self];
    [[EaseMob sharedInstance].callManager addDelegate:self delegateQueue:nil];
    
#else
    
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
#endif
}

- (void)unregisterEaseMobNotification
{
#if DEMO_CALL == 1
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    [[EaseMob sharedInstance].callManager removeDelegate:self];
#else
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
#endif
    
}

@end
