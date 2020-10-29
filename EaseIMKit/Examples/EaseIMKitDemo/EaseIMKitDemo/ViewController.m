//
//  ViewController.m
//  EaseIMKitDemo
//
//  Created by 杜洁鹏 on 2020/10/29.
//  Copyright © 2020 djp. All rights reserved.
//

#import "ViewController.h"
#import <EaseIMKit/EaseIMKit.h>
#import "ConversationCellModel.h"

@interface ViewController ()<EaseConversationVCDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    EaseConversationsViewController *conVC = [[EaseConversationsViewController alloc] initWithOptions:nil];
    conVC.delegate = self;
    [self.view addSubview:conVC.view];
    [self addChildViewController:conVC];
    conVC.view.frame = self.view.bounds;
}


#pragma mark - EaseConversationVCDelegate
- (id<EaseConversationCellModelDelegate>)conversationCellForModel:(NSString *)conversationId
                                                 conversationType:(EMConversationType)aType{
    
    return [[ConversationCellModel alloc] init];
}

@end
