//
//  ConversationsViewController.m
//  EaseIMKitDemo
//
//  Created by 杜洁鹏 on 2020/11/5.
//  Copyright © 2020 djp. All rights reserved.
//

#import "ConversationsViewController.h"
#import "ConversationModel.h"
#import <EaseIMKit.h>
#import "EaseChatViewController.h"

@interface ConversationsViewController () <EaseConversationsViewControllerDelegate>
{
    EaseConversationViewModel *_viewMdeol;
}
@end

@implementation ConversationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _viewMdeol = [[EaseConversationViewModel alloc] init];
    _viewMdeol.avatarEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 30);
    EaseConversationsViewController *easeConvsVC = [[EaseConversationsViewController alloc] initWithModel:_viewMdeol];
    easeConvsVC.easeTableViewDelegate = self;
    [self addChildViewController:easeConvsVC];
    [self.view addSubview:easeConvsVC.view];
    [easeConvsVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
}
   
#pragma mark - EaseConversationVCDelegate

- (UIContextualAction *)sideslipCustomAction:(UITableView *)tableView dataArray:(NSMutableArray *)dataArray trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIContextualAction *customAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"自定义" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        NSLog(@"customAction");
    }];
    customAction.backgroundColor = [UIColor orangeColor];
    return customAction;
}

/*
- (NSArray<id<EaseItemDelegate>> *)resetDataAry {
    ConversationModel *model = [[ConversationModel alloc] init];
    return @[model];
}
*/

- (void)easeTableView:(UITableView *)tableView didSelectRowAtItem:(id<EaseItemDelegate>)item
{
    EaseChatViewController *chatController = [[EaseChatViewController alloc]init];
    chatController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatController animated:YES];
}

@end
