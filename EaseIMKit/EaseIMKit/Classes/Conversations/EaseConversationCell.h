//
//  EaseConversationCell.h
//  EaseIMKit
//
//  Created by XieYajie on 2019/1/8.
//  Update © 2020 zhangchong. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EMBadgeLabel.h"
#import "EaseConversationViewModel.h"
#import "EaseConversationModelDelegate.h"

@interface EaseConversationCell : UITableViewCell

@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) EMBadgeLabel *badgeLabel;
@property (nonatomic, assign) id<EaseConversationModelDelegate> model;

- (instancetype)initWithConversationViewModel:(EaseConversationViewModel *)viewModel;

@end
