//
//  EMMessageReactionView.m
//  EaseIMKit
//
//  Created by 冯钊 on 2022/2/11.
//

#import "EMMessageReactionView.h"

#import "View+EaseAdditions.h"
#import "UIImage+EaseUI.h"

@import HyphenateChat;

@interface EMMessageReactionView ()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIImageView *moreImageView;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, assign) CGFloat countLabelWidth;
@property (nonatomic, strong) NSMutableArray <UIImageView *>*imageViews;

@end

@implementation EMMessageReactionView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _contentView = [[UIView alloc] init];
        [self addSubview:_contentView];
        
        _contentView.layer.borderWidth = 2;
        _contentView.layer.borderColor = UIColor.whiteColor.CGColor;
        _contentView.layer.cornerRadius = 14;
        _contentView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1];
        
        _moreImageView = [[UIImageView alloc] init];
        _moreImageView.image = [UIImage easeUIImageNamed:@"more_reaction"];
        _moreImageView.contentMode = UIViewContentModeScaleAspectFit;
        [_contentView addSubview:_moreImageView];
        
        _countLabel = [[UILabel alloc] init];
        [_contentView addSubview:_countLabel];
        
        _imageViews = [NSMutableArray array];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap)];
        [_contentView addGestureRecognizer:tap];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    int showMaxReactionCount = (int)_reactionList.count;
    if (showMaxReactionCount > 5) {
        showMaxReactionCount = 4;
    }
    
    CGFloat w = 0;
    for (int i = 0; i < _imageViews.count; i ++) {
        if (i < showMaxReactionCount) {
            _imageViews[i].hidden = NO;
            _imageViews[i].image = [UIImage easeUIImageNamed:_reactionList[i].reaction];
            if (_reactionList.count == 1) {
                _imageViews[i].frame = CGRectMake(6, 6, 16, 16);
            } else {
                _imageViews[i].frame = CGRectMake(10 + 20 * i, 6, 16, 16);
            }
        } else {
            _imageViews[i].hidden = YES;
        }
    }
    
    if (showMaxReactionCount == 1 && _reactionList.firstObject.count == 1) {
        w = 28;
        _countLabel.hidden = YES;
        _moreImageView.hidden = YES;
    } else {
        if (_reactionList.count > 5) {
            w = 120 + _countLabelWidth;
            _moreImageView.frame = CGRectMake(90, 0, 16, self.bounds.size.height);
            _moreImageView.hidden = NO;
        } else {
            w = 20 + 20 * showMaxReactionCount + _countLabelWidth;
            _moreImageView.hidden = YES;
        }
        _countLabel.hidden = NO;
        _countLabel.frame = CGRectMake(w - _countLabelWidth - 8, 0, _countLabelWidth, 28);
    }
    
    CGFloat x = _direction == EMMessageDirectionSend ? self.bounds.size.width - w : 0;
    _contentView.frame = CGRectMake(x, 0, w, self.bounds.size.height);
}

- (void)onTap {
    if (_onClick) {
        _onClick();
    }
}

- (void)setReactionList:(NSArray<EMMessageReaction *> *)reactionList {
    _reactionList = reactionList;
    if (reactionList.count <= 0) {
        self.hidden = YES;
        return;
    }
    
    self.hidden = NO;
    uint64_t allCount = 0;
    for (EMMessageReaction *reaction in _reactionList) {
        allCount += reaction.count;
    }
    NSString *countLabelText = [NSString stringWithFormat:@"%llu", allCount];
    _countLabelWidth = [countLabelText boundingRectWithSize:CGSizeMake(10000, 1000) options:0 attributes:@{
        NSFontAttributeName: _countLabel.font
    } context:nil].size.width;
    
    if (reactionList.count == 1 && reactionList.firstObject.count == 1) {
        _countLabel.hidden = YES;
    } else {
        _countLabel.hidden = NO;
        _countLabel.text = countLabelText;
    }
    
    int showMaxReactionCount = (int)reactionList.count;
    if (showMaxReactionCount > 5) {
        showMaxReactionCount = 4;
    }
    
    if (showMaxReactionCount > _imageViews.count) {
        NSUInteger loopCount = showMaxReactionCount - _imageViews.count;
        for (NSUInteger i = 0; i < loopCount; i ++) {
            UIImageView *imageView = [[UIImageView alloc] init];
            [_contentView addSubview:imageView];
            [_imageViews addObject:imageView];
        }
    }
    
    [self setNeedsLayout];
}

@end
