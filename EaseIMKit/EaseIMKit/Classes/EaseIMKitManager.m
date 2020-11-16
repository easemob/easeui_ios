//
//  EaseIMKitManager.m
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/10/29.
//

#import "EaseIMKitManager.h"
#import "EaseConversationsViewController.h"

static EaseIMKitManager *easeIMKit = nil;
@implementation EaseIMKitManager

+ (instancetype)shareEaseIMKit
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        easeIMKit = [[EaseIMKitManager alloc] init];
    });
    return easeIMKit;
}

@end
