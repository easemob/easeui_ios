//
//  EaseMessageCell.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/25.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EaseMessageCell.h"

#import "EaseMessageStatusView.h"

#import "EMMsgTextBubbleView.h"
#import "EMMsgImageBubbleView.h"
#import "EMMsgAudioBubbleView.h"
#import "EMMsgVideoBubbleView.h"
#import "EMMsgLocationBubbleView.h"
#import "EMMsgFileBubbleView.h"
#import "EMMsgExtGifBubbleView.h"
#import "UIImageView+EaseWebCache.h"

@interface EaseMessageCell()

@property (nonatomic, strong) UIImageView *avatarView;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) EaseMessageStatusView *statusView;

@property (nonatomic, strong) UIButton *readReceiptBtn;//阅读回执按钮

@property (nonatomic, strong) EaseChatViewModel *viewModel;

@end

@implementation EaseMessageCell

- (instancetype)initWithDirection:(EMMessageDirection)aDirection
                             chatType:(EMChatType)aChatType
                           messageType:(EMMessageType)aMessageType
                            viewModel:(EaseChatViewModel*)viewModel

{
    NSString *identifier = [EaseMessageCell cellIdentifierWithDirection:aDirection type:aMessageType];
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    if (self) {
        _direction = aDirection;
        _viewModel = viewModel;
        if (_viewModel.msgAlignmentStyle == EaseAlignmentlLeft && aChatType == EMChatTypeGroupChat) {
            _direction = EMMessageDirectionReceive;
        }
        [self _setupViewsWithType:aMessageType chatType:aChatType];
    }
    [self.bubbleView setupBubbleBackgroundImage];
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Class Methods

+ (NSString *)cellIdentifierWithDirection:(EMMessageDirection)aDirection
                                     type:(EMMessageType)aType
{
    NSString *identifier = @"EMMsgCellDirectionSend";
    if (aDirection == EMMessageDirectionReceive) {
        identifier = @"EMMsgCellDirectionRecv";
    }
    
    if (aType == EMMessageTypeText || aType == EMMessageTypeExtCall) {
        identifier = [NSString stringWithFormat:@"%@Text", identifier];
    } else if (aType == EMMessageTypeImage) {
        identifier = [NSString stringWithFormat:@"%@Image", identifier];
    } else if (aType == EMMessageTypeVoice) {
        identifier = [NSString stringWithFormat:@"%@Voice", identifier];
    } else if (aType == EMMessageTypeVideo) {
        identifier = [NSString stringWithFormat:@"%@Video", identifier];
    } else if (aType == EMMessageTypeLocation) {
        identifier = [NSString stringWithFormat:@"%@Location", identifier];
    } else if (aType == EMMessageTypeFile) {
        identifier = [NSString stringWithFormat:@"%@File", identifier];
    } else if (aType == EMMessageTypeExtGif) {
        identifier = [NSString stringWithFormat:@"%@ExtGif", identifier];
    } else if (aType == EMMessageTypeCustom) {
        identifier = [NSString stringWithFormat:@"%@Custom", identifier];
    }
    
    return identifier;
}

#pragma mark - Subviews

- (void)_setupViewsWithType:(EMMessageType)aType chatType:(EMChatType)chatType
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];

    _avatarView = [[UIImageView alloc] init];
    _avatarView.contentMode = UIViewContentModeScaleAspectFit;
    _avatarView.backgroundColor = [UIColor clearColor];
    _avatarView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarDidSelect:)];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(avatarLongPressAction:)];
    [_avatarView addGestureRecognizer:tap];
    [_avatarView addGestureRecognizer:longPress];
    if (_viewModel.avatarStyle == RoundedCorner) {
        _avatarView.layer.cornerRadius = _viewModel.avatarCornerRadius;
    }
    if (_viewModel.avatarStyle == Circular) {
        _avatarView.layer.cornerRadius = avatarLonger / 2;
    }
    if (_viewModel.avatarStyle != Rectangular) {
        _avatarView.clipsToBounds = _avatarView.clipsToBounds = YES;;
    }
    [self.contentView addSubview:_avatarView];
    if (self.direction == EMMessageDirectionReceive) {
        [_avatarView Ease_makeConstraints:^(EaseConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(15);
            make.left.equalTo(self.contentView).offset(2*componentSpacing);
            make.width.height.equalTo(@(avatarLonger));
        }];
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:13];
        _nameLabel.textColor = [UIColor grayColor];
        if (chatType != EMChatTypeChat) {
            [self.contentView addSubview:_nameLabel];
            [_nameLabel Ease_makeConstraints:^(EaseConstraintMaker *make) {
                make.top.equalTo(self.avatarView);
                make.left.equalTo(self.avatarView.ease_right).offset(8);
                make.right.equalTo(self.contentView).offset(-componentSpacing);
            }];
        }
    } else {
        [_avatarView Ease_makeConstraints:^(EaseConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(15);
            make.right.equalTo(self.contentView).offset(-2*componentSpacing);
            make.width.height.equalTo(@(avatarLonger));
        }];
    }

    _bubbleView = [self _getBubbleViewWithType:aType];
    _bubbleView.userInteractionEnabled = YES;
    _bubbleView.clipsToBounds = YES;
    [self.contentView addSubview:_bubbleView];
    if (self.direction == EMMessageDirectionReceive) {
        [_bubbleView Ease_makeConstraints:^(EaseConstraintMaker *make) {
            if (chatType != EMChatTypeChat) {
                make.top.equalTo(self.nameLabel.ease_bottom).offset(3);
            } else {
                make.top.equalTo(self.avatarView);
            }
            make.bottom.equalTo(self.contentView).offset(-15);
            make.left.equalTo(self.avatarView.ease_right).offset(componentSpacing);
            make.right.lessThanOrEqualTo(self.contentView).offset(-70);
        }];
    } else {
        [_bubbleView Ease_makeConstraints:^(EaseConstraintMaker *make) {
            make.top.equalTo(self.avatarView);
            make.bottom.equalTo(self.contentView).offset(-15);
            make.left.greaterThanOrEqualTo(self.contentView).offset(70);
            make.right.equalTo(self.avatarView.ease_left).offset(-componentSpacing);
        }];
    }

    _statusView = [[EaseMessageStatusView alloc] init];
    [self.contentView addSubview:_statusView];
    if (self.direction == EMMessageDirectionSend || (_viewModel.msgAlignmentStyle == EaseAlignmentlLeft && chatType == EMChatTypeGroupChat)) {
        [_statusView Ease_makeConstraints:^(EaseConstraintMaker *make) {
            make.centerY.equalTo(self.bubbleView.ease_centerY);
            if (_viewModel.msgAlignmentStyle == EaseAlignmentlLeft && chatType == EMChatTypeGroupChat) {
                make.left.equalTo(self.bubbleView.ease_right).offset(5);
            } else {
                make.right.equalTo(self.bubbleView.ease_left).offset(-5);
            }
            make.height.equalTo(@(componentSpacing * 2));
        }];
        __weak typeof(self) weakself = self;
        [_statusView setResendCompletion:^{
            if (weakself.delegate && [weakself.delegate respondsToSelector:@selector(messageCellDidResend:)]) {
                [weakself.delegate messageCellDidResend:weakself.model];
            }
        }];
    } else {
        _statusView.backgroundColor = [UIColor redColor];
        _statusView.clipsToBounds = YES;
        _statusView.layer.cornerRadius = 4;
        [_statusView Ease_makeConstraints:^(EaseConstraintMaker *make) {
            make.centerY.equalTo(self.bubbleView);
            make.left.equalTo(self.bubbleView.ease_right).offset(5);
            make.width.height.equalTo(@8);
        }];
    }
    
    [self setCellIsReadReceipt];
}

- (void)setCellIsReadReceipt{
    _readReceiptBtn = [[UIButton alloc]init];
    _readReceiptBtn.layer.cornerRadius = 5;
    _readReceiptBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    _readReceiptBtn.backgroundColor = [UIColor lightGrayColor];
    [_readReceiptBtn.titleLabel setTextColor:[UIColor whiteColor]];
    _readReceiptBtn.titleLabel.font = [UIFont systemFontOfSize: 10.0];
    [_readReceiptBtn addTarget:self action:@selector(readReceiptDetilAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_readReceiptBtn];
    if(self.direction == EMMessageDirectionSend) {
        [_readReceiptBtn Ease_makeConstraints:^(EaseConstraintMaker *make) {
            make.top.equalTo(self.bubbleView.ease_bottom).offset(2);
            make.right.equalTo(self.bubbleView.ease_right);
            make.width.equalTo(@130);
            make.height.equalTo(@15);
        }];
    }
}

- (EMMessageBubbleView *)_getBubbleViewWithType:(EMMessageType)aType
{
    EMMessageBubbleView *bubbleView = nil;
    switch (aType) {
        case EMMessageTypeText:
        case EMMessageTypeExtCall:
            bubbleView = [[EMMsgTextBubbleView alloc] initWithDirection:self.direction type:aType viewModel:_viewModel];
            break;
        case EMMessageTypeImage:
            bubbleView = [[EMMsgImageBubbleView alloc] initWithDirection:self.direction type:aType viewModel:_viewModel];
            break;
        case EMMessageTypeVoice:
            bubbleView = [[EMMsgAudioBubbleView alloc] initWithDirection:self.direction type:aType viewModel:_viewModel];
            break;
        case EMMessageTypeVideo:
            bubbleView = [[EMMsgVideoBubbleView alloc] initWithDirection:self.direction type:aType viewModel:_viewModel];
            break;
        case EMMessageTypeLocation:
            bubbleView = [[EMMsgLocationBubbleView alloc] initWithDirection:self.direction type:aType viewModel:_viewModel];
            break;
        case EMMessageTypeFile:
            bubbleView = [[EMMsgFileBubbleView alloc] initWithDirection:self.direction type:aType viewModel:_viewModel];
            break;
        case EMMessageTypeExtGif:
            bubbleView = [[EMMsgExtGifBubbleView alloc] initWithDirection:self.direction type:aType viewModel:_viewModel];
            break;
        case EMMessageTypeCustom:
            bubbleView = [[EMMessageBubbleView alloc] initWithDirection:self.direction type:aType
                viewModel:_viewModel];
            break;
        default:
            break;
    }
    if (bubbleView) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bubbleViewTapAction:)];
        [bubbleView addGestureRecognizer:tap];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(bubbleViewLongPressAction:)];
        [bubbleView addGestureRecognizer:longPress];
    }
    
    return bubbleView;
}

- (void)setStatusHidden:(BOOL)isHidden
{
    self.statusView.hidden = isHidden;
}

#pragma mark - Setter

- (void)setModel:(EaseMessageModel *)model
{
    _model = model;
    self.bubbleView.model = model;
    if (model.direction == EMMessageDirectionSend) {
        [self.statusView setSenderStatus:model.message.status isReadAcked:model.message.chatType == EMChatTypeChat ? model.message.isReadAcked : NO];
    } else {
        if (model.type == EMMessageBodyTypeVoice) {
            self.statusView.hidden = model.message.isListened;
        }
    }
    if (model.type != EMChatTypeChat) {
        if (model.userDataDelegate && [model.userDataDelegate respondsToSelector:@selector(showName)] && ![model.userDataDelegate.showName isEqualToString:@""]) {
            self.nameLabel.text = model.userDataDelegate.showName;
        } else {
            self.nameLabel.text = model.message.from;
        }
    }
    BOOL isCustomAvatar = NO;
    if (model.userDataDelegate && [model.userDataDelegate respondsToSelector:@selector(defaultAvatar)]) {
        if (model.userDataDelegate.defaultAvatar) {
            _avatarView.image = model.userDataDelegate.defaultAvatar;
            isCustomAvatar = YES;
        }
    }
    if (_model.userDataDelegate && [_model.userDataDelegate respondsToSelector:@selector(avatarURL)]) {
        if ([_model.userDataDelegate.avatarURL length] > 0) {
            [_avatarView Ease_setImageWithURL:[NSURL URLWithString:_model.userDataDelegate.avatarURL]
                               placeholderImage:[UIImage easeUIImageNamed:@"defaultAvatar"]];
            isCustomAvatar = YES;
        }
    }
    if (!isCustomAvatar) {
        _avatarView.image = [UIImage easeUIImageNamed:@"defaultAvatar"];
    }
    if (model.message.isNeedGroupAck) {
        self.readReceiptBtn.hidden = NO;
        [self.readReceiptBtn setTitle:[NSString stringWithFormat:EaseLocalizableString(@"readers", nil),_model.message.groupAckCount] forState:UIControlStateNormal];
    } else {
        self.readReceiptBtn.hidden = YES;
    }
}

#pragma mark - Action

- (void)readReceiptDetilAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(messageReadReceiptDetil:)]) {
        [self.delegate messageReadReceiptDetil:self];
    }
}

//头像点击
- (void)avatarDidSelect:(UITapGestureRecognizer *)aTap
{
    if (aTap.state == UIGestureRecognizerStateEnded) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(avatarDidSelected:)]) {
            [self.delegate avatarDidSelected:_model];
        }
    }
}
//头像长按
- (void)avatarLongPressAction:(UILongPressGestureRecognizer *)aLongPress
{
    if (aLongPress.state == UIGestureRecognizerStateBegan) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(avatarDidLongPress:)]) {
            [self.delegate avatarDidLongPress:self.model];
        }
    }
}
//气泡点击
- (void)bubbleViewTapAction:(UITapGestureRecognizer *)aTap
{
    if (aTap.state == UIGestureRecognizerStateEnded) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(messageCellDidSelected:)]) {
            [self.delegate messageCellDidSelected:self];
        }
    }
}
//气泡长按
- (void)bubbleViewLongPressAction:(UILongPressGestureRecognizer *)aLongPress
{
    if (aLongPress.state == UIGestureRecognizerStateBegan) {
        if (self.model.type == EMMessageTypeText) {
            EMMsgTextBubbleView *textBubbleView = (EMMsgTextBubbleView*)self.bubbleView;
            textBubbleView.textLabel.backgroundColor = [UIColor colorWithRed:156/255.0 green:206/255.0 blue:243/255.0 alpha:1.0];
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(messageCellDidLongPress:cgPoint:)]) {
            [self.delegate messageCellDidLongPress:self cgPoint:CGPointZero];
        }
    }
    //[aLongPress release];
}

@end
