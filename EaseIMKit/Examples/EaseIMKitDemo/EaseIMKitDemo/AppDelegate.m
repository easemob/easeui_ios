//
//  AppDelegate.m
//  EaseIMKitDemo
//
//  Created by 杜洁鹏 on 2020/10/29.
//  Copyright © 2020 djp. All rights reserved.
//

#import "AppDelegate.h"
#import <Hyphenate/Hyphenate.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    EMOptions *options = [EMOptions optionsWithAppkey:@"easemob-demo#chatdemoui"];
    [EMClient.sharedClient initializeSDKWithOptions:options];
    [[EMClient sharedClient] loginWithUsername:@"chong" password:@"1" completion:nil];
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
