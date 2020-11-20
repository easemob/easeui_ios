//
//  EaseConversationsViewController.h
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/10/29.
//

#import <UIKit/UIKit.h>
#import <Hyphenate/Hyphenate.h>
#import "EaseBaseTableViewController.h"
#import "EaseConversationModelDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@protocol EaseConversationsViewControllerDelegate <EaseBaseViewControllerDelegate>
@optional
- (void)easeTableView:(UITableView *)tableView didSelectItem:(__kindof id<EaseConversationModelDelegate>)item;
- (CGFloat)easeTableView:(UITableView *)tableView heightForItem:(id<EaseConversationModelDelegate>)item;
- (__kindof EaseConversationCell *)easeTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSArray<UIContextualAction *> *)tableView:(UITableView *)tableView
       trailingSwipeActionsForRowAtIndexPath:(NSIndexPath *)indexPath
                                     actions:(NSArray<UIContextualAction *> *)actions;
@end


@interface EaseConversationsViewController : EaseBaseTableViewController
@property (nonatomic, strong) NSMutableArray <EaseConversationModelDelegate> * dataAry;
@property (nonatomic) id <EaseConversationsViewControllerDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
