//
//  EaseContactCell.h
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/11/10.
//

#import <UIKit/UIKit.h>
#import "EaseContactsViewModel.h"
#import "EaseContactDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface EaseContactCell : UITableViewCell
@property (nonatomic, strong, readonly) UIImageView *avatarView;
@property (nonatomic, strong, readonly) UILabel *nameLabel;
@property (nonatomic) id<EaseContactDelegate> model;

+ (EaseContactCell *)tableView:(UITableView *)tableView cellViewModel:(EaseContactsViewModel *)viewModel;

@end

NS_ASSUME_NONNULL_END
