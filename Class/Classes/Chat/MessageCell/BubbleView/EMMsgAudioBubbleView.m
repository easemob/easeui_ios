//
//  EMMsgAudioBubbleView.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/2/14.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMMsgAudioBubbleView.h"

#define kEMMsgAudioMinWidth 30
#define kEMMsgAudioMaxWidth 120

@interface EMMsgAudioBubbleView()
{
    EaseChatViewModel *_viewModel;
}
@property (nonatomic) float maxWidth;
@end
 
@implementation EMMsgAudioBubbleView

- (instancetype)initWithDirection:(EMMessageDirection)aDirection
                             type:(EMMessageType)aType
                            viewModel:(EaseChatViewModel *)viewModel
{
    self = [super initWithDirection:aDirection type:aType viewModel:viewModel];
    if (self) {
        _viewModel = viewModel;
        [self _setupSubviews];
    }
    
    return self;
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    _maxWidth= [UIScreen mainScreen].bounds.size.width / 2 - 100;
    [self setupBubbleBackgroundImage];
    
    self.imgView = [[UIImageView alloc] init];
    self.imgView.contentMode = UIViewContentModeScaleAspectFit;
    self.imgView.clipsToBounds = YES;
    self.imgView.animationDuration = 1.0;
    [self addSubview:self.imgView];
    [self.imgView Ease_makeConstraints:^(EaseConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.top.equalTo(self).offset(8);
        make.width.height.equalTo(@30);
    }];
    
    self.textLabel = [[UILabel alloc] init];
    self.textLabel.font = [UIFont systemFontOfSize:14];
    self.textLabel.numberOfLines = 0;
    [self addSubview:self.textLabel];
    [self.textLabel Ease_makeConstraints:^(EaseConstraintMaker *make) {
        make.top.equalTo(self).offset(8);
        make.bottom.equalTo(self).offset(-8);
    }];
    self.textLabel.textColor = [UIColor blackColor];
    if (self.direction == EMMessageDirectionSend) {
        
        [self.imgView Ease_makeConstraints:^(EaseConstraintMaker *make) {
            make.right.equalTo(self).offset(-5);
        }];
        [self.textLabel Ease_makeConstraints:^(EaseConstraintMaker *make) {
            make.right.equalTo(self.imgView.ease_left).offset(-3);
            make.left.equalTo(self).offset(5);
        }];
        
        self.textLabel.textAlignment = NSTextAlignmentRight;
        
        self.imgView.image = [UIImage easeUIImageNamed:@"msg_send_audio"];
        self.imgView.animationImages = @[[UIImage easeUIImageNamed:@"msg_send_audio02"], [UIImage easeUIImageNamed:@"msg_send_audio01"], [UIImage easeUIImageNamed:@"msg_send_audio"]];
    } else {
        
        [self.imgView Ease_makeConstraints:^(EaseConstraintMaker *make) {
            make.left.equalTo(self).offset(5);
        }];
        [self.textLabel Ease_makeConstraints:^(EaseConstraintMaker *make) {
            make.left.equalTo(self.imgView.ease_right).offset(3);
            make.right.equalTo(self).offset(-5);
        }];
        
        self.textLabel.textAlignment = NSTextAlignmentLeft;
        
        self.imgView.image = [UIImage easeUIImageNamed:@"msg_recv_audio"];
        self.imgView.animationImages = @[[UIImage easeUIImageNamed:@"msg_recv_audio02"], [UIImage easeUIImageNamed:@"msg_recv_audio01"], [UIImage easeUIImageNamed:@"msg_recv_audio"]];
    }
}

#pragma mark - Setter

- (void)setModel:(EaseMessageModel *)model
{
    EMMessageType type = model.type;
    if (type == EMMessageTypeVoice) {
        
        EMVoiceMessageBody *body = (EMVoiceMessageBody *)model.message.body;
        self.textLabel.text = [NSString stringWithFormat:@"%d\"",(int)body.duration];
        [self.imgView stopAnimating];
        if (model.isPlaying) {
            [self.imgView startAnimating];
        }
        [self.imgView setNeedsLayout];
        [self.imgView layoutIfNeeded];
        
        float width = kEMMsgAudioMinWidth * body.duration / 10;
        if (width > _maxWidth) {
            width = _maxWidth;
        } else if (width < kEMMsgAudioMinWidth) {
            width = kEMMsgAudioMinWidth;
        }
        [self.textLabel Ease_updateConstraints:^(EaseConstraintMaker *make) {
            make.width.Ease_equalTo(width);
        }];
    }
}

@end
