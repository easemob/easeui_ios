//
//  EaseConversationCell.m
//  EaseIMKit
//
//  Created by XieYajie on 2019/1/8.
//  Update © 2020 zhangchong. All rights reserved.
//

#import "EaseConversationCell.h"
#import "EaseHeaders.h"
#import "EMDateHelper.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface EaseConversationCell()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) EaseConversationViewModel *conversationCellViewModel;

@end

@implementation EaseConversationCell

- (instancetype)initWithConversationViewModel:(EaseConversationViewModel*)viewModel
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EMConversationCell"];
    if (self){
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        self.selectedBackgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
        self.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:1.0];
        self.backgroundColor = viewModel.cellBgColor;
        _conversationCellViewModel = viewModel;
        [self _setupSubview];
    }
    return self;
}

#pragma mark - private layout subviews

- (void)_setupSubview
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _avatarView = [[UIImageView alloc] init];
    [self.contentView addSubview:_avatarView];
    __weak typeof(self) weakSelf = self;
    [_avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.topMargin.equalTo(self.contentView).offset(weakSelf.conversationCellViewModel.avatarEdgeInsets.top);
        make.leftMargin.equalTo(self.contentView).offset(weakSelf.conversationCellViewModel.avatarEdgeInsets.left);
        make.bottomMargin.equalTo(self.contentView).offset(weakSelf.conversationCellViewModel.avatarEdgeInsets.bottom);
        make.rightMargin.equalTo(self.contentView).offset(weakSelf.conversationCellViewModel.avatarEdgeInsets.right);
        make.width.offset(weakSelf.conversationCellViewModel.avatarSize.width);
        make.height.offset(weakSelf.conversationCellViewModel.avatarSize.height);
    }];
    _avatarView.layer.cornerRadius = _avatarView.frame.size.width / 4;
    if (_conversationCellViewModel.avatarType == Rectangular)
        _avatarView.layer.cornerRadius = 0;
    if (_conversationCellViewModel.avatarType == Circular)
        _avatarView.layer.cornerRadius = _avatarView.frame.size.width / 2;
    
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.font = [UIFont systemFontOfSize:_conversationCellViewModel.wordSizeForCellTimestamp];
    _timeLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
    _timeLabel.backgroundColor = [UIColor clearColor];
    [_timeLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.contentView addSubview:_timeLabel];
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.avatarView);
        make.right.equalTo(self.contentView).offset(-15);
    }];
    
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.backgroundColor = [UIColor clearColor];
    _nameLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    _nameLabel.font = [UIFont systemFontOfSize:_conversationCellViewModel.wordSizeForCellTitle];
    [self.contentView addSubview:_nameLabel];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView.mas_centerY);
        make.left.equalTo(self.avatarView.mas_right);
        make.right.lessThanOrEqualTo(self.timeLabel.mas_left);
    }];
    
    bool badgeLongerIsValid = (_conversationCellViewModel.longer >= 20 && _conversationCellViewModel.longer <=  _avatarView.frame.size.width / 2);
    _badgeLabel = [[EMBadgeLabel alloc] init];
    _badgeLabel.clipsToBounds = YES;
    _badgeLabel.layer.cornerRadius = badgeLongerIsValid ? _conversationCellViewModel.longer / 2 : 10;
    [self.contentView addSubview:_badgeLabel];
    [_badgeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_centerY).offset(3);
        make.right.equalTo(self.contentView).offset(-15);
        make.height.equalTo(badgeLongerIsValid ? @(_conversationCellViewModel.longer) : @20);
        make.width.greaterThanOrEqualTo(badgeLongerIsValid ? @(_conversationCellViewModel.longer) : @20);
    }];
    if (_conversationCellViewModel.unReadCountPosition == EMTopRightCornerForAvatar) {
        //未读数在头像右上角
        [_badgeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_avatarView.mas_top);
            make.centerY.equalTo(_avatarView.mas_right);
        }];
    }
    
    _detailLabel = [[UILabel alloc] init];
    _detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _detailLabel.backgroundColor = [UIColor clearColor];
    _detailLabel.font = [UIFont systemFontOfSize:_conversationCellViewModel.wordSizeForCellDetail];
    _detailLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
    [self.contentView addSubview:_detailLabel];
    [_detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_centerY).offset(3);
        make.left.equalTo(self.nameLabel);
        make.right.equalTo(self.badgeLabel.mas_left).offset(-5);
        make.bottom.equalTo(self.contentView).offset(-8);
    }];

    self.selectionStyle = UITableViewCellSelectionStyleGray;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return YES;
}

- (void)setModel:(id<EaseConversationModelDelegate>)model
{
    _model = model;
    [self.avatarView sd_setImageWithURL:[NSURL URLWithString:_model.avatarURL] placeholderImage:_model.defaultAvatar];
    self.nameLabel.text = _model.showName;
    // TODO:
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:_model.showInfo];
    self.detailLabel.attributedText = attrString;
    self.timeLabel.text = [EMDateHelper formattedTimeFromTimeInterval:_model.lastestUpdateTime];
    
    if (_model.unreadMessagesCount == 0) {
        self.badgeLabel.value = @"";
        self.badgeLabel.hidden = YES;
    } else {
        self.badgeLabel.value = [NSString stringWithFormat:@" %@ ", _model.unreadMessagesCount > 99 ? (_model.unreadMessagesCount > 199 ? @"..." : @"99+") : @(_model.unreadMessagesCount)];
        self.badgeLabel.hidden = NO;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
    {
        [super setSelected:selected animated:animated];
        self.badgeLabel.backgroundColor = _conversationCellViewModel.unReadCountViewBgColor;
    }
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
    {
        [super setHighlighted:highlighted animated:animated];
        self.badgeLabel.backgroundColor = _conversationCellViewModel.unReadCountViewBgColor;
    }

@end
