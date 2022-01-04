//
//  EaseConversationCell.m
//  EaseIMKit
//
//  Created by XieYajie on 2019/1/8.
//  Update © 2020 zhangchong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EaseConversationCell.h"
#import "EaseDateHelper.h"
#import "EaseBadgeView.h"
#import "Easeonry.h"
#import "UIImageView+EaseWebCache.h"

@interface EaseConversationCell()

@property (nonatomic, strong) EaseConversationViewModel *viewModel;

@end

@implementation EaseConversationCell

+ (EaseConversationCell *)tableView:(UITableView *)tableView cellViewModel:(EaseConversationViewModel *)viewModel {
    static NSString *cellId = @"EMConversationCell";
    EaseConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[EaseConversationCell alloc] initWithConversationsViewModel:viewModel identifier: cellId];
    }
    
    return cell;
}

- (instancetype)initWithConversationsViewModel:(EaseConversationViewModel*)viewModel
                                   identifier:(NSString *)identifier
{

    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier]){
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _viewModel = viewModel;
        [self _addSubViews];
        [self _setupSubViewsConstraints];
        [self _setupViewsProperty];
    }
    return self;
}

#pragma mark - private layout subviews

- (void)_addSubViews {
    _avatarView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _detailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _badgeLabel = [[EaseBadgeView alloc] initWithFrame:CGRectZero];
    _redDot = [[UIImageView alloc] initWithFrame:CGRectZero];
    _undisturbRing = [[UIImageView alloc] initWithFrame:CGRectZero];
    _badgeLabel.hidden = YES;
    self.redDot.hidden = YES;
    self.undisturbRing.hidden = YES;
    [self.contentView addSubview:_avatarView];
    [self.contentView addSubview:_nameLabel];
    [self.contentView addSubview:_timeLabel];
    [self.contentView addSubview:_detailLabel];
    [self.contentView addSubview:_badgeLabel];
    [self.avatarView addSubview:_redDot];
    [self.contentView addSubview:_undisturbRing];
}

- (void)_setupViewsProperty {
    
    self.backgroundColor = _viewModel.cellBgColor;
    
    if (_viewModel.avatarType != Rectangular) {
        _avatarView.clipsToBounds = YES;
        if (_viewModel.avatarType == RoundedCorner) {
            _avatarView.layer.cornerRadius = 5;
        }
        else if(_viewModel.avatarType == Circular) {
            _avatarView.layer.cornerRadius = _viewModel.avatarSize.width / 2;
        }
        
    }else {
        _avatarView.clipsToBounds = NO;
    }
    
    _avatarView.backgroundColor = [UIColor clearColor];
    _avatarView.contentMode = UIViewContentModeScaleAspectFit;
    
    _nameLabel.font = _viewModel.nameLabelFont;
    _nameLabel.textColor = _viewModel.nameLabelColor;
    _nameLabel.lineBreakMode = NSLineBreakByCharWrapping;
    _nameLabel.backgroundColor = [UIColor clearColor];
    
    _detailLabel.font = _viewModel.detailLabelFont;
    _detailLabel.textColor = _viewModel.detailLabelColor;
    _detailLabel.lineBreakMode = NSLineBreakByCharWrapping;
    _detailLabel.backgroundColor = [UIColor clearColor];
    
    _timeLabel.font = _viewModel.timeLabelFont;
    _timeLabel.textColor = _viewModel.timeLabelColor;
    _timeLabel.backgroundColor = [UIColor clearColor];
    [_timeLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    
    _badgeLabel.font = _viewModel.badgeLabelFont;
    _badgeLabel.backgroundColor = _viewModel.badgeLabelBgColor;
    _badgeLabel.badgeColor = _viewModel.badgeLabelTitleColor;
    _badgeLabel.maxNum = _viewModel.badgeMaxNum;
    
    _redDot.image = [UIImage imageNamed:@"undisturbDot"];
    _undisturbRing.image = [UIImage imageNamed:@"undisturbRing"];
    
    self.selectionStyle = UITableViewCellSelectionStyleGray;
}

- (void)_setupSubViewsConstraints
{
    
    __weak typeof(self) weakSelf = self;
    
    [_avatarView Ease_remakeConstraints:^(EaseConstraintMaker *make) {
        make.top.equalTo(weakSelf.contentView.ease_top).offset(weakSelf.viewModel.avatarEdgeInsets.top + 11);
        make.bottom.equalTo(weakSelf.contentView.ease_bottom).offset(-weakSelf.viewModel.avatarEdgeInsets.bottom - 13);
        make.left.equalTo(weakSelf.contentView.ease_left).offset(weakSelf.viewModel.avatarEdgeInsets.left + 20);
        make.width.offset(weakSelf.viewModel.avatarSize.width);
        make.height.offset(weakSelf.viewModel.avatarSize.height).priority(750);
    }];
    
    [_nameLabel Ease_remakeConstraints:^(EaseConstraintMaker *make) {
        make.top.equalTo(weakSelf.contentView.ease_top).offset(weakSelf.viewModel.nameLabelEdgeInsets.top + 12);
        make.left.equalTo(weakSelf.avatarView.ease_right).offset(weakSelf.viewModel.avatarEdgeInsets.right + weakSelf.viewModel.nameLabelEdgeInsets.left + 12);
    }];
    
    [_detailLabel Ease_remakeConstraints:^(EaseConstraintMaker *make) {
        make.top.equalTo(weakSelf.nameLabel.ease_bottom).offset(weakSelf.viewModel.nameLabelEdgeInsets.bottom + weakSelf.viewModel.detailLabelEdgeInsets.top);
        make.left.equalTo(weakSelf.avatarView.ease_right).offset(weakSelf.viewModel.avatarEdgeInsets.right + weakSelf.viewModel.detailLabelEdgeInsets.left + 12);
        make.bottom.equalTo(weakSelf.contentView.ease_bottom).offset(weakSelf.viewModel.detailLabelEdgeInsets.bottom - 18);
    }];
    
    [_timeLabel Ease_remakeConstraints:^(EaseConstraintMaker *make) {
        make.top.equalTo(weakSelf.contentView.ease_top).offset(weakSelf.viewModel.timeLabelEdgeInsets.top + 12);
        make.right.equalTo(weakSelf.contentView.ease_right).offset(-weakSelf.viewModel.timeLabelEdgeInsets.right - 18);
        make.left.greaterThanOrEqualTo(weakSelf.nameLabel.ease_right).offset(weakSelf.viewModel.nameLabelEdgeInsets.right + weakSelf.viewModel.timeLabelEdgeInsets.left + 8);
    }];

  
    if (_viewModel.badgeLabelPosition == EMAvatarTopRight) {
        [_badgeLabel Ease_remakeConstraints:^(EaseConstraintMaker *make) {
            make.height.offset(_viewModel.badgeLabelHeight);
            make.width.Ease_greaterThanOrEqualTo(weakSelf.viewModel.badgeLabelHeight).priority(1000);
            make.centerY.equalTo(weakSelf.avatarView.ease_top).offset(weakSelf.viewModel.badgeLabelCenterVector.dy + 4);
            make.centerX.equalTo(weakSelf.avatarView.ease_right).offset(weakSelf.viewModel.badgeLabelCenterVector.dx - 8);
        }];
        
        [_detailLabel Ease_updateConstraints:^(EaseConstraintMaker *make) {
            make.right.equalTo(weakSelf.contentView.ease_right).offset(-weakSelf.viewModel.detailLabelEdgeInsets.right - 18);
        }];
    }else {
        [_badgeLabel Ease_remakeConstraints:^(EaseConstraintMaker *make) {
            make.height.offset(_viewModel.badgeLabelHeight);
            make.width.Ease_greaterThanOrEqualTo(weakSelf.viewModel.badgeLabelHeight).priority(1000);
            make.centerY.equalTo(weakSelf.avatarView.ease_top).offset(weakSelf.viewModel.badgeLabelCenterVector.dy + 4);
            make.centerX.equalTo(weakSelf.avatarView.ease_right).offset(weakSelf.viewModel.badgeLabelCenterVector.dx - 8);
        }];
    }
    CGFloat r = _viewModel.avatarSize.width/2.0;
    CGFloat padding = r - ceilf(r/sqrt(2)) - 6;//求得以内切圆半径为斜边的等直角边直角三角形的单直角边长度，用内切圆半径减去它再减去红点视图的一半距离求得偏移量

    [_redDot Ease_remakeConstraints:^(EaseConstraintMaker *make) {
        make.height.Ease_equalTo(12);
        make.width.Ease_equalTo(12);
        make.top.equalTo(weakSelf.avatarView.ease_top).offset(padding);
        make.right.equalTo(weakSelf.avatarView.ease_right).offset(-padding);
    }];
    
    [_undisturbRing Ease_remakeConstraints:^(EaseConstraintMaker *make) {
        make.height.Ease_equalTo(16);
        make.width.Ease_equalTo(16);
        make.top.equalTo(weakSelf.timeLabel.ease_bottom).offset(5);
        make.right.equalTo(weakSelf.contentView.ease_right).offset(-weakSelf.viewModel.timeLabelEdgeInsets.right - 18);
    }];
}

- (void)setModel:(EaseConversationModel *)model
{
    _model = model;
    
    UIImage *img = nil;
    if ([_model respondsToSelector:@selector(defaultAvatar)]) {
        img = _model.defaultAvatar;
    }
    
    if (_viewModel.defaultAvatarImage && !img) {
        img = _viewModel.defaultAvatarImage;
    }
    
    if ([_model respondsToSelector:@selector(avatarURL)]) {
        [self.avatarView Ease_setImageWithURL:[NSURL URLWithString:_model.avatarURL]
                           placeholderImage:img];
    }else {
        self.avatarView.image = img;
    }
    
    if ([_model respondsToSelector:@selector(showName)]) {
        self.nameLabel.text = _model.showName;
    }
    
    if (model.isTop) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = _viewModel.topBgColor;
    } else {
        self.backgroundColor = _viewModel.cellBgColor;
    }
    
    self.detailLabel.attributedText = _model.showInfo;
    self.timeLabel.text = [EaseDateHelper formattedTimeFromTimeInterval:_model.lastestUpdateTime];
    if (model.showBadgeValue == YES) {
        self.badgeLabel.badge = model.unreadMessagesCount;
        self.redDot.hidden = YES;
        self.badgeLabel.hidden = !(model.unreadMessagesCount > 0);
    } else {
        self.badgeLabel.hidden = YES;
        self.redDot.hidden = !(model.unreadMessagesCount > 0);
    }
    self.undisturbRing.hidden = model.showBadgeValue;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    self.badgeLabel.backgroundColor = _viewModel.badgeLabelBgColor;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    self.badgeLabel.backgroundColor = _viewModel.badgeLabelBgColor;
}

- (void)resetViewModel:(EaseConversationViewModel *)aViewModel {
    _viewModel = aViewModel;
    [self _addSubViews];
    [self _setupSubViewsConstraints];
    [self _setupViewsProperty];
}

@end
