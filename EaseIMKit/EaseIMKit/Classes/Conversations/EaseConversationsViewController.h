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

@protocol EaseConversationsViewControllerDelegate <EaseTableViewDelegate>

@end


@interface EaseConversationsViewController : EaseBaseTableViewController
@end

NS_ASSUME_NONNULL_END
