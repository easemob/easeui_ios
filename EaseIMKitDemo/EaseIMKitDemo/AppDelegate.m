//
//  AppDelegate.m
//  EaseIMKitDemo
//
//  Created by 杜洁鹏 on 2020/10/29.
//  Copyright © 2020 djp. All rights reserved.
//

#import "AppDelegate.h"
#import <HyphenateChat/HyphenateChat.h>

#define kDefaultName @"chong"

#define kDefaultPassword @"1"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    EMOptions *options = [EMOptions optionsWithAppkey:@"easemob-demo#easeim"];
    options.enableConsoleLog = YES;

    [EaseIMKitManager initWithEMOptions:options];
    
    if (EMClient.sharedClient.isLoggedIn && ![EMClient.sharedClient.currentUsername isEqualToString:kDefaultName]) {
        [EMClient.sharedClient logout:YES];
    }
    
    [[EMClient sharedClient] loginWithUsername:kDefaultName
                                      password:kDefaultPassword
                                    completion:^(NSString *aUsername, EMError *aError)
    {
    }];
    return YES;
}




@end
