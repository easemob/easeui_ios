//
//  EaseAvatarNameCell.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/9.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EaseAvatarNameModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol EaseAvatarNameCellDelegate;
@interface EaseAvatarNameCell : UITableViewCell

@property (nonatomic, weak) id<EaseAvatarNameCellDelegate> delegate;

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, strong) UIImageView *avatarView;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *detailLabel;

@property (nonatomic, strong) UILabel *timestampLabel;

@property (nonatomic, strong) UIButton *accessoryButton;

@property (nonatomic, strong) EaseAvatarNameModel *model;

@end

@protocol EaseAvatarNameCellDelegate<NSObject>

@optional

- (void)cellAccessoryButtonAction:(EaseAvatarNameCell *)aCell;

@end

NS_ASSUME_NONNULL_END
