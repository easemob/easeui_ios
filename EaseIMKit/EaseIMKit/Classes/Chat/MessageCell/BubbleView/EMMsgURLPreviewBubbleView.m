//
//  EMMsgURLPreviewBubbleView.m
//  EaseIMKit
//
//  Created by 冯钊 on 2023/5/24.
//

#import "EMMsgURLPreviewBubbleView.h"
#import "EaseURLPreviewManager.h"
#import "UIImageView+EaseWebCache.h"

@interface EMMsgURLPreviewBubbleView ()
{
    EaseChatViewModel *_viewModel;
}

@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIView *urlPreviewLoadingView;
@property (nonatomic, strong) UIImageView *urlPreviewLoadingImageView;
@property (nonatomic, strong) UILabel *urlPreviewLoadingLabel;
@property (nonatomic, strong) UIView *urlPreviewView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation EMMsgURLPreviewBubbleView

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
    [self setupBubbleBackgroundImage];
    
    self.textLabel = [[UILabel alloc] init];
    self.textLabel.font = [UIFont systemFontOfSize:_viewModel.contentFontSize];
    self.textLabel.numberOfLines = 0;
<<<<<<< HEAD
    self.textLabel.textColor = _viewModel.contentFontColor;
    [self addSubview:self.textLabel];
    [self.textLabel Ease_makeConstraints:^(EaseConstraintMaker *make) {
        make.top.left.equalTo(@10);
        make.right.bottom.equalTo(@-10);
=======
    [self addSubview:self.textLabel];
    [self.textLabel Ease_makeConstraints:^(EaseConstraintMaker *make) {
        make.top.equalTo(self.ease_top).offset(10);
        make.bottom.equalTo(self.ease_bottom).offset(-10);
    }];
    self.textLabel.textColor = _viewModel.contentFontColor;
    if (self.direction == EMMessageDirectionSend) {
        [self.textLabel Ease_makeConstraints:^(EaseConstraintMaker *make) {
            make.left.equalTo(self.ease_left).offset(10);
            make.right.equalTo(self.ease_right).offset(-10);
        }];
    } else {
        [self.textLabel Ease_makeConstraints:^(EaseConstraintMaker *make) {
            make.left.equalTo(self.ease_left).offset(10);
            make.right.equalTo(self.ease_right).offset(-10);
        }];
    }
    
    _urlPreviewLoadingView = [[UIView alloc] init];
    _urlPreviewLoadingView.backgroundColor = UIColor.clearColor;
    [self addSubview:_urlPreviewLoadingView];
    
    _urlPreviewLoadingImageView = [[UIImageView alloc] init];
    _urlPreviewLoadingImageView.image = [UIImage easeUIImageNamed:@"url_preview_loading"];
    [_urlPreviewLoadingView addSubview:_urlPreviewLoadingImageView];
    
    _urlPreviewLoadingLabel = [[UILabel alloc] init];
    _urlPreviewLoadingLabel.font = [UIFont systemFontOfSize:11];
    _urlPreviewLoadingLabel.textColor = [UIColor colorWithRed:0.302 green:0.361 blue:0.482 alpha:1];
    _urlPreviewLoadingLabel.text = @"解析中...";
    [_urlPreviewLoadingView addSubview:_urlPreviewLoadingLabel];
    
    [_urlPreviewLoadingView Ease_makeConstraints:^(EaseConstraintMaker *make) {
        make.top.equalTo(self.textLabel.ease_bottom).offset(9);
        make.left.right.equalTo(self.textLabel);
        make.bottom.equalTo(@-9);
        make.height.equalTo(@16);
    }];
    
    [_urlPreviewLoadingImageView Ease_makeConstraints:^(EaseConstraintMaker *make) {
        make.left.centerY.equalTo(_urlPreviewLoadingView);
        make.size.equalTo(@16);
    }];
    
    [_urlPreviewLoadingLabel Ease_makeConstraints:^(EaseConstraintMaker *make) {
        make.centerY.equalTo(_urlPreviewLoadingView);
        make.left.equalTo(_urlPreviewLoadingImageView.ease_right).offset(4);
        make.right.equalTo(_urlPreviewLoadingView);
>>>>>>> ok
    }];
}

#pragma mark - Setter

- (void)setModel:(EaseMessageModel *)model
{
    EMTextMessageBody *body = (EMTextMessageBody *)model.message.body;
    NSString *text = [EaseEmojiHelper convertEmoji:body.text];
    NSMutableAttributedString *attaStr = [[NSMutableAttributedString alloc] initWithString:text];
    
    NSDataDetector *detector = [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink error:nil];
    NSArray *checkArr = [detector matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    if (checkArr.count == 1) {
        NSTextCheckingResult *result = checkArr.firstObject;
        NSString *urlStr = result.URL.absoluteString;
        NSRange range = [text rangeOfString:urlStr options:NSCaseInsensitiveSearch];
        if (range.length > 0) {
            NSURL *url = [NSURL URLWithString:urlStr];
            [attaStr setAttributes:@{NSLinkAttributeName : url} range:NSMakeRange(range.location, urlStr.length)];
            EaseURLPreviewResult *result = [EaseURLPreviewManager.shared resultWithURL:url];
            if (result && result.state != EaseURLPreviewStateFaild) {
                [self updateLayoutWithURLPreview: result];
            } else {
                [self updateLayoutWithoutURLPreview];
            }
        }
    } else {
        [self updateLayoutWithoutURLPreview];
    }
    
    self.textLabel.attributedText = attaStr;
}

- (void)updateLayoutWithURLPreview:(EaseURLPreviewResult *)result
{
<<<<<<< HEAD
    [self.textLabel Ease_remakeConstraints:^(EaseConstraintMaker *make) {
        make.top.left.equalTo(@10);
        make.right.equalTo(@-10);
    }];
=======
    if (self.direction == EMMessageDirectionSend) {
        [_textLabel Ease_remakeConstraints:^(EaseConstraintMaker *make) {
            make.top.equalTo(self.ease_top).offset(10);
            make.left.equalTo(self.ease_left).offset(10);
            make.right.equalTo(self.ease_right).offset(-10);
        }];
    } else {
        [_textLabel Ease_remakeConstraints:^(EaseConstraintMaker *make) {
            make.top.equalTo(self.ease_top).offset(10);
            make.left.equalTo(self.ease_left).offset(10);
            make.right.equalTo(self.ease_right).offset(-10);
        }];
    }
>>>>>>> ok
    if (result.state == EaseURLPreviewStateSuccess) {
        _urlPreviewLoadingView.hidden = YES;
        self.urlPreviewView.hidden = NO;
        _titleLabel.text = result.title;
        _contentLabel.text = result.desc;
        [_imageView Ease_setImageWithURL:[NSURL URLWithString:result.imageUrl] placeholderImage:[UIImage easeUIImageNamed:@"url_preview_placeholder"]];
<<<<<<< HEAD
        [_urlPreviewLoadingView Ease_remakeConstraints:^(EaseConstraintMaker *make) {}];
        [_urlPreviewView Ease_remakeConstraints:^(EaseConstraintMaker *make) {
            make.top.equalTo(self.textLabel.ease_bottom).offset(9);
            if (self.direction == EMMessageDirectionSend) {
                make.left.greaterThanOrEqualTo(@12);
                make.right.equalTo(@-12);
            } else {
                make.left.equalTo(@12);
                make.right.lessThanOrEqualTo(@-12);
            }
=======
        [_urlPreviewLoadingView Ease_remakeConstraints:^(EaseConstraintMaker *make) {
            make.left.top.width.height.equalTo(@0);
        }];
        [_urlPreviewView Ease_remakeConstraints:^(EaseConstraintMaker *make) {
            make.top.equalTo(self.textLabel.ease_bottom).offset(9);
            make.left.equalTo(@12);
            make.right.equalTo(@-12);
>>>>>>> ok
            make.bottom.equalTo(@-9);
            make.height.equalTo(@100);
            make.width.equalTo(@217);
        }];
    } else {
<<<<<<< HEAD
        self.urlPreviewLoadingView.hidden = NO;
        _urlPreviewView.hidden = YES;
        [_urlPreviewView Ease_remakeConstraints:^(EaseConstraintMaker *make) {}];
        [_urlPreviewLoadingView Ease_remakeConstraints:^(EaseConstraintMaker *make) {
=======
        _urlPreviewLoadingView.hidden = NO;
        _urlPreviewView.hidden = YES;
        [_urlPreviewLoadingView Ease_makeConstraints:^(EaseConstraintMaker *make) {
>>>>>>> ok
            make.top.equalTo(self.textLabel.ease_bottom).offset(9);
            make.left.right.equalTo(self.textLabel);
            make.bottom.equalTo(@-9);
            make.height.equalTo(@16);
        }];
<<<<<<< HEAD
=======
        [_urlPreviewView Ease_remakeConstraints:^(EaseConstraintMaker *make) {
            make.left.top.width.height.equalTo(@0);
        }];
>>>>>>> ok
    }
}

- (void)updateLayoutWithoutURLPreview
{
    _urlPreviewView.hidden = YES;
    _urlPreviewLoadingView.hidden = YES;
<<<<<<< HEAD
    
    [_urlPreviewView Ease_remakeConstraints:^(EaseConstraintMaker *make) {}];
    [_urlPreviewLoadingView Ease_remakeConstraints:^(EaseConstraintMaker *make) {}];
    [_textLabel Ease_remakeConstraints:^(EaseConstraintMaker *make) {
        make.top.left.equalTo(@10);
        make.right.bottom.equalTo(@-10);
=======
    if (self.direction == EMMessageDirectionSend) {
        [_textLabel Ease_remakeConstraints:^(EaseConstraintMaker *make) {
            make.top.equalTo(self.ease_top).offset(10);
            make.left.equalTo(self.ease_left).offset(10);
            make.right.equalTo(self.ease_right).offset(-10);
            make.bottom.equalTo(self.ease_bottom).offset(-10);
        }];
    } else {
        [_textLabel Ease_remakeConstraints:^(EaseConstraintMaker *make) {
            make.top.equalTo(self.ease_top).offset(10);
            make.left.equalTo(self.ease_left).offset(10);
            make.right.equalTo(self.ease_right).offset(-10);
            make.bottom.equalTo(self.ease_bottom).offset(-10);
        }];
    }
    [_urlPreviewView Ease_remakeConstraints:^(EaseConstraintMaker *make) {
        make.left.top.width.height.equalTo(@0);
    }];
    [_urlPreviewLoadingView Ease_remakeConstraints:^(EaseConstraintMaker *make) {
        make.left.top.width.height.equalTo(@0);
>>>>>>> ok
    }];
}

- (UIView *)urlPreviewView
{
    if (!_urlPreviewView) {
        _urlPreviewView = [[UIView alloc] init];
        _urlPreviewView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.04];
        _urlPreviewView.layer.cornerRadius = 8;
        [self addSubview:_urlPreviewView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.numberOfLines = 1;
        _titleLabel.textColor = UIColor.blackColor;
        _titleLabel.font = [UIFont systemFontOfSize:15];
        [_urlPreviewView addSubview:_titleLabel];
        
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.numberOfLines = 4;
        _contentLabel.textColor = [UIColor colorWithRed:0.302 green:0.361 blue:0.482 alpha:1];
        _contentLabel.font = [UIFont systemFontOfSize:12];
        [_urlPreviewView addSubview:_contentLabel];
        
        _imageView = [[UIImageView alloc] init];
<<<<<<< HEAD
        _imageView.backgroundColor = UIColor.clearColor;
        _imageView.image = [UIImage easeUIImageNamed:@"url_preview_placeholder"];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
=======
        _imageView.image = [UIImage easeUIImageNamed:@"url_preview_placeholder"];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
>>>>>>> ok
        _imageView.layer.masksToBounds = YES;
        _imageView.layer.cornerRadius = 4;
        [_urlPreviewView addSubview:_imageView];
        
<<<<<<< HEAD
=======
        [_urlPreviewView Ease_makeConstraints:^(EaseConstraintMaker *make) {
            make.top.equalTo(self.textLabel.ease_bottom).offset(9);
            make.left.equalTo(@12);
            make.right.equalTo(@-12);
            make.bottom.equalTo(@-9);
            make.height.equalTo(@100);
            make.width.greaterThanOrEqualTo(@217);
        }];
        
>>>>>>> ok
        [_titleLabel Ease_makeConstraints:^(EaseConstraintMaker *make) {
            make.left.top.equalTo(@12);
            make.right.equalTo(@-12);
            make.height.equalTo(@20);
        }];
        
        [_contentLabel Ease_makeConstraints:^(EaseConstraintMaker *make) {
            make.left.equalTo(_titleLabel);
            make.top.equalTo(_titleLabel.ease_bottom).offset(4);
            make.right.equalTo(_imageView.ease_left).offset(-8);
        }];
        
        [_imageView Ease_makeConstraints:^(EaseConstraintMaker *make) {
            make.width.height.equalTo(@52);
            make.right.equalTo(@-12);
            make.top.equalTo(@36);
        }];
    }
    return _urlPreviewView;
}

<<<<<<< HEAD
- (UIView *)urlPreviewLoadingView
{
    if (!_urlPreviewLoadingView) {
        _urlPreviewLoadingView = [[UIView alloc] init];
        _urlPreviewLoadingView.backgroundColor = UIColor.clearColor;
        [self addSubview:_urlPreviewLoadingView];
        
        _urlPreviewLoadingImageView = [[UIImageView alloc] init];
        _urlPreviewLoadingImageView.image = [UIImage easeUIImageNamed:@"url_preview_loading"];
        [_urlPreviewLoadingView addSubview:_urlPreviewLoadingImageView];
        
        _urlPreviewLoadingLabel = [[UILabel alloc] init];
        _urlPreviewLoadingLabel.font = [UIFont systemFontOfSize:11];
        _urlPreviewLoadingLabel.textColor = [UIColor colorWithRed:0.302 green:0.361 blue:0.482 alpha:1];
        _urlPreviewLoadingLabel.text = @"解析中...";
        [_urlPreviewLoadingView addSubview:_urlPreviewLoadingLabel];
        
        [_urlPreviewLoadingImageView Ease_makeConstraints:^(EaseConstraintMaker *make) {
            make.left.centerY.equalTo(_urlPreviewLoadingView);
            make.size.equalTo(@16);
        }];
        
        [_urlPreviewLoadingLabel Ease_makeConstraints:^(EaseConstraintMaker *make) {
            make.centerY.equalTo(_urlPreviewLoadingView);
            make.left.equalTo(_urlPreviewLoadingImageView.ease_right).offset(4);
            make.right.equalTo(_urlPreviewLoadingView);
        }];
    }
    return _urlPreviewLoadingView;
}
=======
>>>>>>> ok

@end
