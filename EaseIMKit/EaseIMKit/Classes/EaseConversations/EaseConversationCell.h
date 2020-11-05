//
//  EaseConversationCell.h
//  EaseIMKit
//
//  Created by XieYajie on 2019/1/8.
//  Update © 2020 zhangchong. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EMBadgeLabel.h"
#import "EaseConversationCellOptions.h"
#import "EMConversationHelper.h"

@class EaseConversationCell;
@protocol EaseConversationCellDelegate <NSObject>
@optional
- (void)conversationCellDidTouchEnd:(EaseConversationCell *)aCell;
- (void)conversationCellDidLongPress:(EaseConversationCell *)aCell;
@end


@interface EaseConversationCell : UITableViewCell

@property (nonatomic, assign) id<EaseConversationCellDelegate> delegate;
@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) EMBadgeLabel *badgeLabel;
@property (nonatomic, assign) id<EaseConversationModelDelegate> model;

- (instancetype)initWithConversationCellOptions:(EaseConversationCellOptions*)options;
- (void)setSelectedStatus;

@end
