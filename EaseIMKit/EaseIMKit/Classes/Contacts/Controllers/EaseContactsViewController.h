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

@protocol EaseContactsViewControllerDelegate <EaseBaseViewControllerDelegate>
@optional
- (void)refreshTabView;
@optional

- (UITableViewCell *)easeTableView:(UITableView *)tableView cellForRowAtContact:(id <EaseContactDelegate>) contact;

- (NSArray<UIContextualAction *> *)easeTableView:(UITableView *)tableView
           trailingSwipeActionsForRowAtContact:(id <EaseContactDelegate>) contact
                                         actions:(NSArray<UIContextualAction *> *)actions;

- (void)easeTableView:(UITableView *)tableView didSelectRowAtContact:(id <EaseContactDelegate>) contact;

@end

@interface EaseContactsViewController : EaseBaseTableViewController
@property (nonatomic, strong) NSArray<EaseContactDelegate> *customHeaderItems;
@property (nonatomic, strong) NSArray<EaseContactDelegate> *contacts;
@property (nonatomic, strong) NSArray<EaseContactDelegate> *customFooterItems;
@property (nonatomic) id<EaseContactsViewControllerDelegate> delegate;


- (instancetype)initWithViewModel:(EaseContactsViewModel *)model;

@end

@interface EaseContactLetterModel : NSObject
@property (nonatomic, strong) NSString *contactLetter;
@property (nonatomic, strong) NSArray *contacts;
@end

NS_ASSUME_NONNULL_END
