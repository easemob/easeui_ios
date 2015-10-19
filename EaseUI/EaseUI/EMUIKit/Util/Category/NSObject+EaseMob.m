//
//  NSObject+EaseMob.m
//  ChatDemo-UI3.0
//
//  Created by dhc on 15/6/26.
//  Copyright (c) 2015年 easemob.com. All rights reserved.
//

#import "NSObject+EaseMob.h"

#import "EaseMob.h"

@implementation NSObject (EaseMob)

- (void)registerEaseMobLiteNotification
{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
}

- (void)unregisterEaseMobLiteNotification
{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}

- (void)registerEaseMobNotification
{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
    [[EaseMob sharedInstance].callManager removeDelegate:self];
    [[EaseMob sharedInstance].callManager addDelegate:self delegateQueue:nil];
}

- (void)unregisterEaseMobNotification
{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    [[EaseMob sharedInstance].callManager removeDelegate:self];
}

@end
