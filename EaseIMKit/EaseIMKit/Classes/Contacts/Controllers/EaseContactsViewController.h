//
//  EaseContactsViewController.h
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/11/5.
//

#import <UIKit/UIKit.h>
#import "EaseBaseTableViewController.h"
#import "EaseContactModelDelegate.h"
#import "EaseContactsViewModel.h"


NS_ASSUME_NONNULL_BEGIN

@protocol EaseContactsTableViewDelegate  <NSObject>
- (void)easeTableView:(UITableView *)tableView didSelectItem:(id<EaseContactModelDelegate>)item;
@end

@interface EaseContactsViewController : EaseBaseTableViewController
@property (nonatomic, strong) NSArray<EaseContactModelDelegate> *normalItems;
@property (nonatomic, strong) NSArray<EaseContactModelDelegate> *contacts;
@property (nonatomic, weak) id<EaseContactsTableViewDelegate> easeTableViewDelegate;

- (instancetype)initWithViewModel:(EaseContactsViewModel *)model;

- (void)resetViewModel:(EaseContactsViewModel *)viewModel;

@end

NS_ASSUME_NONNULL_END
