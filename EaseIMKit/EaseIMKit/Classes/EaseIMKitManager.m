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

@synthesize conversationListController = _conversationListController;

+ (instancetype)shareEaseIMKit
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        easeIMKit = [[EaseIMKitManager alloc] init];
    });
    return easeIMKit;
}

- (id<IEaseConversationVcDelegate>)conversationListController
{
    if (!_conversationListController) {
        _conversationListController = [[EaseConversationsViewController alloc]init];
    }
    
    return _conversationListController;
}

@end
