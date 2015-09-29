//
//  EMMessageCell.m
//  ChatDemo-UI3.0
//
//  Created by dhc on 15/6/26.
//  Copyright (c) 2015年 easemob.com. All rights reserved.
//

#import "EMMessageCell.h"

#import "EMBubbleView+Text.h"
#import "EMBubbleView+Image.h"
#import "EMBubbleView+Location.h"
#import "EMBubbleView+Voice.h"
#import "EMBubbleView+Video.h"
#import "EMBubbleView+File.h"

CGFloat const EMMessageCellPadding = 10;

NSString *const EMMessageCellIdentifierRecvText = @"EMMessageCellRecvText";
NSString *const EMMessageCellIdentifierRecvLocation = @"EMMessageCellRecvLocation";
NSString *const EMMessageCellIdentifierRecvVoice = @"EMMessageCellRecvVoice";
NSString *const EMMessageCellIdentifierRecvVideo = @"EMMessageCellRecvVideo";
NSString *const EMMessageCellIdentifierRecvImage = @"EMMessageCellRecvImage";
NSString *const EMMessageCellIdentifierRecvFile = @"EMMessageCellRecvFile";

NSString *const EMMessageCellIdentifierSendText = @"EMMessageCellSendText";
NSString *const EMMessageCellIdentifierSendLocation = @"EMMessageCellSendLocation";
NSString *const EMMessageCellIdentifierSendVoice = @"EMMessageCellSendVoice";
NSString *const EMMessageCellIdentifierSendVideo = @"EMMessageCellSendVideo";
NSString *const EMMessageCellIdentifierSendImage = @"EMMessageCellSendImage";
NSString *const EMMessageCellIdentifierSendFile = @"EMMessageCellSendFile";

@interface EMMessageCell()
{
    MessageBodyType _messageType;
}

@property (nonatomic) NSLayoutConstraint *statusWidthConstraint;
@property (nonatomic) NSLayoutConstraint *hasReadWidthConstraint;
@property (nonatomic) NSLayoutConstraint *bubbleMaxWidthConstraint;

@end

@implementation EMMessageCell

@synthesize statusButton = _statusButton;
@synthesize bubbleView = _bubbleView;
@synthesize hasRead = _hasRead;

+ (void)initialize
{
    // UIAppearance Proxy Defaults
    EMMessageCell *cell = [self appearance];
    cell.statusSize = 20;
    cell.bubbleMaxWidth = 230;
    cell.bubbleMargin = UIEdgeInsetsMake(8, 10, 8, 15);
    
    cell.messageTextFont = [UIFont systemFontOfSize:15];
    cell.messageTextColor = [UIColor blackColor];
    
    cell.messageLocationFont = [UIFont systemFontOfSize:12];
    cell.messageLocationColor = [UIColor whiteColor];
    
    cell.messageVoiceDurationColor = [UIColor grayColor];
    cell.messageVoiceDurationFont = [UIFont systemFontOfSize:12];
    
    cell.messageFileNameColor = [UIColor blackColor];
    cell.messageFileNameFont = [UIFont systemFontOfSize:13];
    cell.messageFileSizeColor = [UIColor grayColor];
    cell.messageFileSizeFont = [UIFont systemFontOfSize:11];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
                        model:(id<IMessageModel>)model
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _messageType = model.bodyType;
        [self _setupSubviewsWithType:_messageType
                            isSender:model.isSender
                               model:model];
    }
    
    return self;
}

#pragma mark - setup subviews

- (void)_setupSubviewsWithType:(MessageBodyType)messageType
                      isSender:(BOOL)isSender
                         model:(id<IMessageModel>)model
{
    _statusButton = [[UIButton alloc] init];
    _statusButton.translatesAutoresizingMaskIntoConstraints = NO;
    _statusButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [_statusButton setImage:[UIImage imageNamed:@"EaseUIResource.bundle/messageSendFail"] forState:UIControlStateNormal];
    [_statusButton addTarget:self action:@selector(statusAction) forControlEvents:UIControlEventTouchUpInside];
    _statusButton.hidden = YES;
    [self.contentView addSubview:_statusButton];
    
    _bubbleView = [[EMBubbleView alloc] initWithMargin:_bubbleMargin isSender:isSender];
    _bubbleView.translatesAutoresizingMaskIntoConstraints = NO;
    _bubbleView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_bubbleView];
    
    _avatarView = [[UIImageView alloc] init];
    _avatarView.translatesAutoresizingMaskIntoConstraints = NO;
    _avatarView.backgroundColor = [UIColor clearColor];
    _avatarView.clipsToBounds = YES;
    _avatarView.userInteractionEnabled = YES;
    [self.contentView addSubview:_avatarView];
    
    _hasRead = [[UILabel alloc] init];
    _hasRead.translatesAutoresizingMaskIntoConstraints = NO;
    _hasRead.text = NSLocalizedString(@"hasRead", @"Read");
    _hasRead.textAlignment = NSTextAlignmentCenter;
    _hasRead.font = [UIFont systemFontOfSize:12];
    _hasRead.hidden = YES;
    [_hasRead sizeToFit];
    [self.contentView addSubview:_hasRead];
    
    if ([self isCustomBubbleView:model]) {
        [self setCustomBubbleView:model];
    } else {
        switch (messageType) {
            case eMessageBodyType_Text:
            {
                [_bubbleView setupTextBubbleView];
                
                _bubbleView.textLabel.font = _messageTextFont;
                _bubbleView.textLabel.textColor = _messageTextColor;
            }
                break;
            case eMessageBodyType_Image:
            {
                [_bubbleView setupImageBubbleView];
                
                _bubbleView.imageView.image = [UIImage imageNamed:@"EaseUIResource.bundle/imageDownloadFail"];
            }
                break;
            case eMessageBodyType_Location:
            {
                [_bubbleView setupLocationBubbleView];
                
                _bubbleView.locationImageView.image = [[UIImage imageNamed:@"EaseUIResource.bundle/chat_location_preview"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
                _bubbleView.locationLabel.font = _messageLocationFont;
                _bubbleView.locationLabel.textColor = _messageLocationColor;
            }
                break;
            case eMessageBodyType_Voice:
            {
                [_bubbleView setupVoiceBubbleView];
                
                _bubbleView.voiceDurationLabel.textColor = _messageVoiceDurationColor;
                _bubbleView.voiceDurationLabel.font = _messageVoiceDurationFont;
            }
                break;
            case eMessageBodyType_Video:
            {
                [_bubbleView setupVideoBubbleView];
                
                _bubbleView.videoTagView.image = [UIImage imageNamed:@"EaseUIResource.bundle/messageVideo"];
            }
                break;
            case eMessageBodyType_File:
            {
                [_bubbleView setupFileBubbleView];
                
                _bubbleView.fileNameLabel.font = _messageFileNameFont;
                _bubbleView.fileNameLabel.textColor = _messageFileNameColor;
                _bubbleView.fileSizeLabel.font = _messageFileSizeFont;
            }
                break;
            default:
                break;
        }
    }
    
    [self _setupConstraints];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bubbleViewTapAction:)];
    [_bubbleView addGestureRecognizer:tapRecognizer];
    
    UITapGestureRecognizer *tapRecognizer2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarViewTapAction:)];
    [_avatarView addGestureRecognizer:tapRecognizer2];
}

#pragma mark - Setup Constraints

- (void)_setupConstraints
{
    //bubble view
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-EMMessageCellPadding]];
    
    self.bubbleMaxWidthConstraint = [NSLayoutConstraint constraintWithItem:self.bubbleView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.bubbleMaxWidth];
    [self addConstraint:self.bubbleMaxWidthConstraint];
//    self.bubbleMaxWidthConstraint.active = YES;
    
    //status button
    self.statusWidthConstraint = [NSLayoutConstraint constraintWithItem:self.statusButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.statusSize];
    [self addConstraint:self.statusWidthConstraint];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.statusButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.statusButton attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.statusButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    
    [self _updateHasReadWidthConstraint];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.hasRead attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.hasRead attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.statusButton attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
}

#pragma mark - Update Constraint

- (void)_updateHasReadWidthConstraint
{
    if (_hasRead) {
        [self removeConstraint:self.hasReadWidthConstraint];
        
        self.hasReadWidthConstraint = [NSLayoutConstraint constraintWithItem:_hasRead attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:40];
        [self addConstraint:self.hasReadWidthConstraint];
    }
}

- (void)_updateStatusButtonWidthConstraint
{
    if (_statusButton) {
        [self removeConstraint:self.statusWidthConstraint];
        
        self.statusWidthConstraint = [NSLayoutConstraint constraintWithItem:self.statusButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:self.statusSize];
        [self addConstraint:self.statusWidthConstraint];
    }
}

- (void)_updateBubbleMaxWidthConstraint
{
    [self removeConstraint:self.bubbleMaxWidthConstraint];
//    self.bubbleMaxWidthConstraint.active = NO;
    
    self.bubbleMaxWidthConstraint = [NSLayoutConstraint constraintWithItem:self.bubbleView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.bubbleMaxWidth];
    [self addConstraint:self.bubbleMaxWidthConstraint];
//    self.bubbleMaxWidthConstraint.active = YES;
}

#pragma mark - setter

- (void)setModel:(id<IMessageModel>)model
{
    _model = model;
    if ([self isCustomBubbleView:model]) {
        [self setCustomModel:model];
    } else {
        switch (model.bodyType) {
            case eMessageBodyType_Text:
            {
                _bubbleView.textLabel.text = model.text;
            }
                break;
            case eMessageBodyType_Image:
            {
                UIImage *image = _model.thumbnailImage;
                if (!image) {
                    image = _model.image;
                    if (!image) {
                        image = [UIImage imageNamed:_model.failImageName];
                    }
                }
                _bubbleView.imageView.image = image;
            }
                break;
            case eMessageBodyType_Location:
            {
                _bubbleView.locationLabel.text = _model.address;
            }
                break;
            case eMessageBodyType_Voice:
            {
                if (_model.isMediaPlaying) {
                    [_bubbleView.voiceImageView startAnimating];
                }
                else{
                    [_bubbleView.voiceImageView stopAnimating];
                }
                
                _bubbleView.voiceDurationLabel.text = [NSString stringWithFormat:@"%d''",(int)_model.mediaDuration];
            }
                break;
            case eMessageBodyType_Video:
            {
                UIImage *image = _model.thumbnailImage;
                if (!image) {
                    image = _model.image;
                    if (!image) {
                        image = [UIImage imageNamed:_model.failImageName];
                    }
                }
                _bubbleView.videoImageView.image = image;
            }
                break;
            case eMessageBodyType_File:
            {
                _bubbleView.fileIconView.image = [UIImage imageNamed:_model.fileIconName];
                _bubbleView.fileNameLabel.text = _model.fileName;
                _bubbleView.fileSizeLabel.text = _model.fileSizeDes;
            }
                break;
            default:
                break;
        }
    }
}

- (void)setStatusSize:(CGFloat)statusSize
{
    _statusSize = statusSize;
    [self _updateStatusButtonWidthConstraint];
}

- (void)setSendBubbleBackgroundImage:(UIImage *)sendBubbleBackgroundImage
{
    _sendBubbleBackgroundImage = sendBubbleBackgroundImage;
}

- (void)setRecvBubbleBackgroundImage:(UIImage *)recvBubbleBackgroundImage
{
    _recvBubbleBackgroundImage = recvBubbleBackgroundImage;
}

- (void)setBubbleMaxWidth:(CGFloat)bubbleMaxWidth
{
    _bubbleMaxWidth = bubbleMaxWidth;
    [self _updateBubbleMaxWidthConstraint];
}

- (void)setBubbleMargin:(UIEdgeInsets)bubbleMargin
{
    _bubbleMargin = bubbleMargin;
    if ([self isCustomBubbleView:_model]) {
        [self updateCustomBubbleViewMargin:bubbleMargin model:_model];
    } else {
        if (_bubbleView) {
            switch (_messageType) {
                case eMessageBodyType_Text:
                {
                    [_bubbleView updateTextMargin:_bubbleMargin];
                }
                    break;
                case eMessageBodyType_Image:
                {
                    [_bubbleView updateImageMargin:_bubbleMargin];
                }
                    break;
                case eMessageBodyType_Location:
                {
                    [_bubbleView updateLocationMargin:_bubbleMargin];
                }
                    break;
                case eMessageBodyType_Voice:
                {
                    [_bubbleView updateVoiceMargin:_bubbleMargin];
                }
                    break;
                case eMessageBodyType_Video:
                {
                    [_bubbleView updateVideoMargin:_bubbleMargin];
                }
                    break;
                case eMessageBodyType_File:
                {
                    [_bubbleView updateFileMargin:_bubbleMargin];
                }
                    break;
                default:
                    break;
            }
            
        }
    }
}

- (void)setMessageTextFont:(UIFont *)messageTextFont
{
    _messageTextFont = messageTextFont;
    if (_bubbleView.textLabel) {
        _bubbleView.textLabel.font = messageTextFont;
    }
}

- (void)setMessageTextColor:(UIColor *)messageTextColor
{
    _messageTextColor = messageTextColor;
    if (_bubbleView.textLabel) {
        _bubbleView.textLabel.textColor = _messageTextColor;
    }
}

- (void)setMessageLocationColor:(UIColor *)messageLocationColor
{
    _messageLocationColor = messageLocationColor;
    if (_bubbleView.locationLabel) {
        _bubbleView.locationLabel.textColor = _messageLocationColor;
    }
}

- (void)setMessageLocationFont:(UIFont *)messageLocationFont
{
    _messageLocationFont = messageLocationFont;
    if (_bubbleView.locationLabel) {
        _bubbleView.locationLabel.font = _messageLocationFont;
    }
}

- (void)setSendMessageVoiceAnimationImages:(NSArray *)sendMessageVoiceAnimationImages
{
    _sendMessageVoiceAnimationImages = sendMessageVoiceAnimationImages;
}

- (void)setRecvMessageVoiceAnimationImages:(NSArray *)recvMessageVoiceAnimationImages
{
    _recvMessageVoiceAnimationImages = recvMessageVoiceAnimationImages;
}

- (void)setMessageVoiceDurationColor:(UIColor *)messageVoiceDurationColor
{
    _messageVoiceDurationColor = messageVoiceDurationColor;
    if (_bubbleView.voiceDurationLabel) {
        _bubbleView.voiceDurationLabel.textColor = _messageVoiceDurationColor;
    }
}

- (void)setMessageVoiceDurationFont:(UIFont *)messageVoiceDurationFont
{
    _messageVoiceDurationFont = messageVoiceDurationFont;
    if (_bubbleView.voiceDurationLabel) {
        _bubbleView.voiceDurationLabel.font = _messageVoiceDurationFont;
    }
}

- (void)setMessageFileNameFont:(UIFont *)messageFileNameFont
{
    _messageFileNameFont = messageFileNameFont;
    if (_bubbleView.fileNameLabel) {
        _bubbleView.fileNameLabel.font = _messageFileNameFont;
    }
}

- (void)setMessageFileNameColor:(UIColor *)messageFileNameColor
{
    _messageFileNameColor = messageFileNameColor;
    if (_bubbleView.fileNameLabel) {
        _bubbleView.fileNameLabel.textColor = _messageFileNameColor;
    }
}

- (void)setMessageFileSizeFont:(UIFont *)messageFileSizeFont
{
    _messageFileSizeFont = messageFileSizeFont;
    if (_bubbleView.fileSizeLabel) {
        _bubbleView.fileSizeLabel.font = _messageFileSizeFont;
    }
}

- (void)setMessageFileSizeColor:(UIColor *)messageFileSizeColor
{
    _messageFileSizeColor = messageFileSizeColor;
    if (_bubbleView.fileSizeLabel) {
        _bubbleView.fileSizeLabel.textColor = _messageFileSizeColor;
    }
}

#pragma mark - action

- (void)bubbleViewTapAction:(UITapGestureRecognizer *)tapRecognizer
{
    if (tapRecognizer.state == UIGestureRecognizerStateEnded) {
        if (!_delegate) {
            return;
        }
        
        switch (_model.bodyType) {
            case eMessageBodyType_Image:
            {
//                if ([_delegate respondsToSelector:@selector(imageMessageCellSelcted:)]) {
//                    [_delegate imageMessageCellSelcted:_model];
//                }
                if ([_delegate respondsToSelector:@selector(messageCellSelected:withMessageCellTapEventType:)]) {
                    [_delegate messageCellSelected:_model withMessageCellTapEventType:EMMessageCellEventImageBubbleTap];
                }
            }
                break;
            case eMessageBodyType_Location:
            {
//                if ([_delegate respondsToSelector:@selector(locationMessageCellSelcted:)]) {
//                    [_delegate locationMessageCellSelcted:_model];
//                }
                if ([_delegate respondsToSelector:@selector(messageCellSelected:withMessageCellTapEventType:)]) {
                    [_delegate messageCellSelected:_model withMessageCellTapEventType:EMMessageCellEventLocationBubbleTap];
                }
            }
                break;
            case eMessageBodyType_Voice:
            {
                _model.isMediaPlaying = !_model.isMediaPlaying;
                if (_model.isMediaPlaying) {
                    [_bubbleView.voiceImageView startAnimating];
                }
                else{
                    [_bubbleView.voiceImageView stopAnimating];
                }
//                _bubbleView.voiceImageView
//                if ([_delegate respondsToSelector:@selector(voiceMessageCellSelcted:)]) {
//                    [_delegate voiceMessageCellSelcted:_model];
//                }
                if ([_delegate respondsToSelector:@selector(messageCellSelected:withMessageCellTapEventType:)]) {
                    [_delegate messageCellSelected:_model withMessageCellTapEventType:EMMessageCellEventAudioBubbleTap];
                }
            }
                break;
            case eMessageBodyType_Video:
            {
//                if ([_delegate respondsToSelector:@selector(videoMessageCellSelcted:)]) {
//                    [_delegate videoMessageCellSelcted:_model];
//                }
                if ([_delegate respondsToSelector:@selector(messageCellSelected:withMessageCellTapEventType:)]) {
                    [_delegate messageCellSelected:_model withMessageCellTapEventType:EMMessageCellEvenVideoBubbleTap];
                }
            }
                break;
            case eMessageBodyType_File:
            {
//                if ([_delegate respondsToSelector:@selector(fileMessageCellSelcted:)]) {
//                    [_delegate fileMessageCellSelcted:_model];
//                }
                if ([_delegate respondsToSelector:@selector(messageCellSelected:withMessageCellTapEventType:)]) {
                    [_delegate messageCellSelected:_model withMessageCellTapEventType:EMMessageCellEventFileBubbleTap];
                }
            }
                break;
            default:
                break;
        }
    }
}

- (void)avatarViewTapAction:(UITapGestureRecognizer *)tapRecognizer
{
    if ([_delegate respondsToSelector:@selector(avatarViewSelcted:)]) {
        [_delegate avatarViewSelcted:_model];
    }
}

- (void)statusAction
{
    if ([_delegate respondsToSelector:@selector(statusButtonSelcted:withMessageCell:)]) {
        [_delegate statusButtonSelcted:_model withMessageCell:self];
    }
}

#pragma mark - IModelCell

- (BOOL)isCustomBubbleView:(id<IMessageModel>)model
{
    return NO;
}

- (void)setCustomModel:(id<IMessageModel>)model
{

}

- (void)setCustomBubbleView:(id<IMessageModel>)model
{

}

- (void)updateCustomBubbleViewMargin:(UIEdgeInsets)bubbleMargin model:(id<IMessageModel>)model
{

}

#pragma mark - public

+ (NSString *)cellIdentifierWithModel:(id<IMessageModel>)model
{
    NSString *cellIdentifier = nil;
    if (model.isSender) {
        switch (model.bodyType) {
            case eMessageBodyType_Text:
                cellIdentifier = EMMessageCellIdentifierSendText;
                break;
            case eMessageBodyType_Image:
                cellIdentifier = EMMessageCellIdentifierSendImage;
                break;
            case eMessageBodyType_Video:
                cellIdentifier = EMMessageCellIdentifierSendVideo;
                break;
            case eMessageBodyType_Location:
                cellIdentifier = EMMessageCellIdentifierSendLocation;
                break;
            case eMessageBodyType_Voice:
                cellIdentifier = EMMessageCellIdentifierSendVoice;
                break;
            case eMessageBodyType_File:
                cellIdentifier = EMMessageCellIdentifierSendFile;
                break;
            default:
                break;
        }
    }
    else{
        switch (model.bodyType) {
            case eMessageBodyType_Text:
                cellIdentifier = EMMessageCellIdentifierRecvText;
                break;
            case eMessageBodyType_Image:
                cellIdentifier = EMMessageCellIdentifierRecvImage;
                break;
            case eMessageBodyType_Video:
                cellIdentifier = EMMessageCellIdentifierRecvVideo;
                break;
            case eMessageBodyType_Location:
                cellIdentifier = EMMessageCellIdentifierRecvLocation;
                break;
            case eMessageBodyType_Voice:
                cellIdentifier = EMMessageCellIdentifierRecvVoice;
                break;
            case eMessageBodyType_File:
                cellIdentifier = EMMessageCellIdentifierRecvFile;
                break;
            default:
                break;
        }
    }
    
    return cellIdentifier;
}

+ (CGFloat)cellHeightWithModel:(id<IMessageModel>)model
{
    if (model.cellHeight > 0) {
        return model.cellHeight;
    }
    
    EMMessageCell *cell = [self appearance];
    CGFloat bubbleMaxWidth = cell.bubbleMaxWidth - cell.bubbleMargin.left - cell.bubbleMargin.right;
    
    CGFloat height = EMMessageCellPadding + cell.bubbleMargin.top + cell.bubbleMargin.bottom;
    
    switch (model.bodyType) {
        case eMessageBodyType_Text:
        {
            NSString *text = model.text;
            UIFont *textFont = cell.messageTextFont;
            CGRect rect = [text boundingRectWithSize:CGSizeMake(bubbleMaxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:textFont} context:nil];
            height += (rect.size.height > 20 ? rect.size.height : 20) + 10;
        }
            break;
        case eMessageBodyType_Image:
        case eMessageBodyType_Video:
        {
            CGSize retSize = model.thumbnailImageSize;
            if (retSize.width == 0 || retSize.height == 0) {
                retSize.width = kEMMessageImageSizeWidth;
                retSize.height = kEMMessageImageSizeHeight;
            }
            else if (retSize.width > retSize.height) {
                CGFloat height =  kEMMessageImageSizeWidth / retSize.width * retSize.height;
                retSize.height = height;
                retSize.width = kEMMessageImageSizeWidth;
            }
            else {
                CGFloat width = kEMMessageImageSizeHeight / retSize.height * retSize.width;
                retSize.width = width;
                retSize.height = kEMMessageImageSizeHeight;
            }

            height += retSize.height;
        }
            break;
        case eMessageBodyType_Location:
        {
            height += kEMMessageLocationHeight;
        }
            break;
        case eMessageBodyType_Voice:
        {
            height += kEMMessageVoiceHeight;
        }
            break;
        case eMessageBodyType_File:
        {
            NSString *text = model.fileName;
            UIFont *font = cell.messageFileNameFont;
            CGRect nameRect = [text boundingRectWithSize:CGSizeMake(bubbleMaxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
            height += (nameRect.size.height > 20 ? nameRect.size.height : 20);
            
            text = model.fileSizeDes;
            font = cell.messageFileSizeFont;
            CGRect sizeRect = [text boundingRectWithSize:CGSizeMake(bubbleMaxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
            height += (sizeRect.size.height > 15 ? sizeRect.size.height : 15);
        }
            break;
        default:
            break;
    }

    height += EMMessageCellPadding;
    model.cellHeight = height;
    
    return height;
}

@end
