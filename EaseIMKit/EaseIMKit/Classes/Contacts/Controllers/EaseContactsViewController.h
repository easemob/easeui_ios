//
//  EaseContactsViewController.h
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/11/5.
//

#import <UIKit/UIKit.h>
#import "EaseBaseTableViewController.h"
#import "EaseContactCellModelDelegate.h"
#import "EaseContactsViewModel.h"


NS_ASSUME_NONNULL_BEGIN

@interface EaseContactsViewController : EaseBaseTableViewController
@property (nonatomic, strong) NSArray<EaseContactCellModelDelegate> *contacts;

- (instancetype)initWithViewModel:(EaseContactsViewModel *)model;

- (void)resetViewModel:(EaseContactsViewModel *)viewModel;

@end

NS_ASSUME_NONNULL_END
