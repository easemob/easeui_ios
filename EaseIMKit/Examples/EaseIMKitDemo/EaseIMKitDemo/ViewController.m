//
//  ViewController.m
//  EaseIMKitDemo
//
//  Created by 杜洁鹏 on 2020/10/29.
//  Copyright © 2020 djp. All rights reserved.
//

#import "ViewController.h"
#import "ConversationCellModel.h"

@interface ViewController ()<EaseConversationVCDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    EaseConversationsViewController *conVC = [[EaseConversationsViewController alloc] initWithOptions:nil];
    conVC.delegate = self;
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIViewController *rootViewController = window.rootViewController;
    if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)rootViewController;
        [nav pushViewController:conVC animated:NO];
    }
    /*
    [self.view addSubview:conVC.view];
    [conVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self addChildViewController:conVC];
    conVC.view.frame = self.view.bounds;*/
}

#pragma mark - EaseConversationVCDelegate
- (id<EaseConversationCellModelDelegate>)conversationCellForModel:(NSString *)conversationId
                                                 conversationType:(EMConversationType)aType{
    /*
    ConversationCellModel *cellModel = [[ConversationCellModel alloc] init];
    if (aType == EMConversationTypeChat)
        cellModel.avatarImg = [UIImage imageNamed:@"defaultAvatar"];
    if (aType == EMConversationTypeGroupChat)
        cellModel.avatarImg = [UIImage imageNamed:@"defaultAvatar"];
    if (aType == EMConversationTypeChatRoom)
        cellModel.avatarImg = [UIImage imageNamed:@"defaultAvatar"];*/
    return nil;
}

@end
