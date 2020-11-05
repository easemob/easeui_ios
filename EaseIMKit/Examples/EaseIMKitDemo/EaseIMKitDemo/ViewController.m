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
