//
//  EaseContactsViewController.h
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/11/5.
//

#import <UIKit/UIKit.h>
#import "EaseContactsViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface EaseContactsViewController : UIViewController

- (instancetype)initWithViewModel:(EaseContactsViewModel *)model;

- (void)refreshViewWithModel:(EaseContactsViewModel *)viewModel;

@end

NS_ASSUME_NONNULL_END
