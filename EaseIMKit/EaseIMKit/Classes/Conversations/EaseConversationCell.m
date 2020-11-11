//
//  EaseConversationCell.m
//  EaseIMKit
//
//  Created by XieYajie on 2019/1/8.
//  Update © 2020 zhangchong. All rights reserved.
//

#import "EaseConversationCell.h"
#import "EMHeaders.h"
#import "EMDateHelper.h"
#import "EaseConversationModelUtil.h"
#import "EaseConversationExtController.h"

@interface EaseConversationCell()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) EaseConversationCellOptions *conversationCellOptions;

@end

@implementation EaseConversationCell

- (instancetype)initWithConversationCellOptions:(EaseConversationCellOptions*)options
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EMConversationCell"];
    if (self){
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        self.selectedBackgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
        self.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:1.0];
        self.backgroundColor = options.conversationCellBgColor;
        _conversationCellOptions = options;
        if (!_conversationCellOptions) {
            _conversationCellOptions = [[EaseConversationCellOptions alloc]init];
        }
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
    [_avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(14);
        make.left.equalTo(self.contentView).offset(16);
        make.bottom.equalTo(self.contentView).offset(-14);
        make.width.equalTo(self.avatarView.mas_height).multipliedBy(1);
    }];
    _avatarView.layer.cornerRadius = _avatarView.frame.size.width / 4;
    if (_conversationCellOptions.avatarStyle == EMAvatarStyleRectangular)
        _avatarView.layer.cornerRadius = 0;
    if (_conversationCellOptions.avatarStyle == EMAvatarStyleCircular)
        _avatarView.layer.cornerRadius = _avatarView.frame.size.width / 2;
    
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.font = [UIFont systemFontOfSize:_conversationCellOptions.wordSizeForCellTimestamp];
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
    _nameLabel.font = [UIFont systemFontOfSize:_conversationCellOptions.wordSizeForCellTitle];
    [self.contentView addSubview:_nameLabel];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView.mas_centerY);
        make.left.equalTo(self.avatarView.mas_right).offset(8);
        make.right.equalTo(self.timeLabel.mas_left);
    }];
    
    bool badgeLongerIsValid = (_conversationCellOptions.longer >= 20 && _conversationCellOptions.longer <=  _avatarView.frame.size.width / 2);
    _badgeLabel = [[EMBadgeLabel alloc] init];
    _badgeLabel.clipsToBounds = YES;
    _badgeLabel.layer.cornerRadius = badgeLongerIsValid ? _conversationCellOptions.longer / 2 : 10;
    [self.contentView addSubview:_badgeLabel];
    [_badgeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_centerY).offset(3);
        make.right.equalTo(self.contentView).offset(-15);
        make.height.equalTo(badgeLongerIsValid ? @(_conversationCellOptions.longer) : @20);
        make.width.greaterThanOrEqualTo(badgeLongerIsValid ? @(_conversationCellOptions.longer) : @20);
    }];
    if (_conversationCellOptions.unReadCountPosition == EMTopRightCornerForAvatar) {
        //未读数在头像右上角
        [_badgeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_avatarView.mas_top);
            make.centerY.equalTo(_avatarView.mas_right);
        }];
    }
    
    _detailLabel = [[UILabel alloc] init];
    _detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _detailLabel.backgroundColor = [UIColor clearColor];
    _detailLabel.font = [UIFont systemFontOfSize:_conversationCellOptions.wordSizeForCellDetail];
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

#pragma mark - setter

- (NSAttributedString *)_getDetailWithModel:(EaseConversationModel *)conversationModel
{
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:@""];
    
    EMMessage *lastMessage = conversationModel.latestMessage;
    if (!lastMessage) {
        return attributedStr;
    }
    
    NSString *latestMessageTitle = @"";
    EMMessageBody *messageBody = lastMessage.body;
    switch (messageBody.type) {
        case EMMessageBodyTypeText:
        {
            NSString *str = [EMEmojiHelper convertEmoji:((EMTextMessageBody *)messageBody).text];
            if ([str isEqualToString:EMCOMMUNICATE_CALLER_MISSEDCALL]) {
                str = @"未接听，点击回拨";
                if ([lastMessage.from isEqualToString:[EMClient sharedClient].currentUsername])
                    str = @"已取消";
            }
            if ([str isEqualToString:EMCOMMUNICATE_CALLED_MISSEDCALL]) {
                str = @"对方已取消";
                if ([lastMessage.from isEqualToString:[EMClient sharedClient].currentUsername])
                    str = @"对方拒绝通话";
            }
            latestMessageTitle = str;
            if (lastMessage.ext && [lastMessage.ext objectForKey:EMCOMMUNICATE_TYPE]) {
                NSString *communicateStr = @"";
                if ([[lastMessage.ext objectForKey:EMCOMMUNICATE_TYPE] isEqualToString:EMCOMMUNICATE_TYPE_VIDEO])
                    communicateStr = @"[视频通话]";
                if ([[lastMessage.ext objectForKey:EMCOMMUNICATE_TYPE] isEqualToString:EMCOMMUNICATE_TYPE_VOICE])
                    communicateStr = @"[语音通话]";
                latestMessageTitle = [NSString stringWithFormat:@"%@ %@", communicateStr, latestMessageTitle];
            }
        }
            break;
        case EMMessageBodyTypeImage:
            latestMessageTitle = @"[图片]";
            break;
        case EMMessageBodyTypeVoice:
            latestMessageTitle = @"[音频]";
            break;
        case EMMessageBodyTypeLocation:
            latestMessageTitle = @"[位置]";
            break;
        case EMMessageBodyTypeVideo:
            latestMessageTitle = @"[视频]";
            break;
        case EMMessageBodyTypeFile:
            latestMessageTitle = @"[文件]";
            break;
        default:
            break;
    }

    /*
    if (ext && [ext[kConversation_IsRead] isEqualToString:kConversation_AtAll]) {
        NSString *allMsg = @"[有全体消息]";
        latestMessageTitle = [NSString stringWithFormat:@"%@ %@", allMsg, latestMessageTitle];
        attributedStr = [[NSMutableAttributedString alloc] initWithString:latestMessageTitle];
        [attributedStr setAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:1.0 green:.0 blue:.0 alpha:0.5]} range:NSMakeRange(0, allMsg.length)];
    } else */
    EMConversation *conversation = [EaseConversationModelUtil getConversationWithConversationModel:conversationModel];
    
    if ([EaseConversationExtController isConversationAtMe:conversation]) {
        NSString *atStr = @"[有人@我]";
        latestMessageTitle = [NSString stringWithFormat:@"%@ %@", atStr, latestMessageTitle];
        attributedStr = [[NSMutableAttributedString alloc] initWithString:latestMessageTitle];
        [attributedStr setAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:255/255.0 green:43/255.0 blue:43/255.0 alpha:1.0]} range:NSMakeRange(0, atStr.length)];
    } else if ([EaseConversationExtController getChatDraft:conversation] && ![[EaseConversationExtController getChatDraft:conversation] isEqualToString:@""]){
        NSString *draftStr = @"[草稿]";
        latestMessageTitle = [NSString stringWithFormat:@"%@ %@", draftStr, [EaseConversationExtController getChatDraft:conversation]];
        attributedStr = [[NSMutableAttributedString alloc] initWithString:latestMessageTitle];
        [attributedStr setAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:255/255.0 green:43/255.0 blue:43/255.0 alpha:1.0]} range:NSMakeRange(0, draftStr.length)];
    } else {
        attributedStr = [[NSMutableAttributedString alloc] initWithString:latestMessageTitle];
    }
    
    return attributedStr;
}

- (NSString *)_getTimeWithModel:(EaseConversationModel *)conversationModel
{
    NSString *latestMessageTime = @"";
    EMMessage *lastMessage = conversationModel.latestMessage;
    if (lastMessage) {
        double timeInterval = lastMessage.timestamp ;
        if(timeInterval > 140000000000) {
            timeInterval = timeInterval / 1000;
        }
        NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        latestMessageTime = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]];
    }
    return latestMessageTime;
}

- (void)setModel:(EaseConversationModel*)model
{
    _model = model;
    /*
    if (_model.conversationType == EMConversationTypeChat)
        self.avatarView.image = [IconResourceManage imageNamed:@"defaultAvatar" class:[self class]];
    if (_model.conversationType == EMConversationTypeGroupChat)
        self.avatarView.image = [IconResourceManage imageNamed:@"groupConversation" class:[self class]];
    if (_model.conversationType == EMConversationTypeChatRoom)
        self.avatarView.image = [IconResourceManage imageNamed:@"chatroomConversation" class:[self class]];
    if ([_model.conversationId isEqualToString:EMSYSTEMNOTIFICATIONID])
        self.avatarView.image = [IconResourceManage imageNamed:@"systemNotify" class:[self class]];*/
    self.avatarView.image = _model.avatarImg;
    self.nameLabel.text = _model.conversationNickname;
    self.detailLabel.attributedText = [self _getDetailWithModel:_model];
    self.timeLabel.text = [self _getTimeWithModel:_model];
    
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
        self.badgeLabel.backgroundColor = _conversationCellOptions.unReadCountViewBgColor;
    }
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
    {
        [super setHighlighted:highlighted animated:animated];
        self.badgeLabel.backgroundColor = _conversationCellOptions.unReadCountViewBgColor;
    }

@end
