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

- (void)registerEaseMobLiteNotification
{
    [[EMClient shareClient].chatManager removeDelegate:self];
    [[EMClient shareClient].chatManager addDelegate:self delegateQueue:nil];
}

- (void)unregisterEaseMobLiteNotification
{
    [[EMClient shareClient].chatManager removeDelegate:self];
}

- (void)registerEaseMobNotification
{
    if ([[EaseSDKHelper shareHelper] isLite]) {
        [self registerEaseMobLiteNotification];
        return;
    }
    [[EMClient shareClient].chatManager removeDelegate:self];
    [[EMClient shareClient].chatManager addDelegate:self delegateQueue:nil];
    
    [[EMClient shareClient].callManager removeDelegate:self];
    [[EMClient shareClient].callManager addDelegate:self delegateQueue:nil];
}

- (void)unregisterEaseMobNotification
{
    if ([[EaseSDKHelper shareHelper] isLite]) {
        [self unregisterEaseMobLiteNotification];
        return;
    }
    [[EMClient shareClient].chatManager removeDelegate:self];
    [[EMClient shareClient].callManager removeDelegate:self];
}

@end
