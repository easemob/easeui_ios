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
- (NSInteger)easeNumberOfSectionsInTableView:(UITableView *)tableView;

- (UITableViewCell *)easeTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

- (NSInteger)easeTableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

- (NSArray<UIContextualAction *> *)easeTableView:(UITableView *)tableView
           trailingSwipeActionsForRowAtIndexPath:(NSIndexPath *)indexPath
                                         actions:(NSArray<UIContextualAction *> *)actions;

- (void)easeTableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end


@interface EaseConversationsViewController : EaseBaseTableViewController
@property (nonatomic, strong) NSMutableArray <EaseConversationModelDelegate> * dataAry;
@property (nonatomic) id <EaseConversationsViewControllerDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
