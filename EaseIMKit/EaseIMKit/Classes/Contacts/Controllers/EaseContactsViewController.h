//
//  EaseContactsViewController.h
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/11/5.
//

#import <UIKit/UIKit.h>
#import "EaseBaseTableViewController.h"
#import "EaseContactDelegate.h"
#import "EaseContactsViewModel.h"


NS_ASSUME_NONNULL_BEGIN

@protocol EaseContactsTableViewDelegate <EaseTableViewDelegate>

@end

@interface EaseContactsViewController : EaseBaseTableViewController
@property (nonatomic, strong) NSArray<EaseContactDelegate> *normalItems;
@property (nonatomic, strong) NSArray<EaseContactDelegate> *contacts;

- (instancetype)initWithViewModel:(EaseContactsViewModel *)model;

- (void)resetViewModel:(EaseContactsViewModel *)viewModel;

@end

NS_ASSUME_NONNULL_END
