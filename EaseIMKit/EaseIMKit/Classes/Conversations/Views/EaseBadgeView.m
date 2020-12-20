//
//  EaseBadgeView.m
//  
//
//  Created by 杜洁鹏 on 2020/11/20.
//

#import "EaseBadgeView.h"
#import "Easeonry.h"

@interface EaseBadgeView ()
@property (nonatomic, strong) UILabel *label;
@end

@implementation EaseBadgeView

- (instancetype)init {
    if (self = [super init]) {
        [self _setupSubViews];
        _maxNum = 99;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self _setupSubViews];
        _maxNum = 99;
    }
    return self;
}

- (void)layoutSubviews {
    self.clipsToBounds = YES;
    self.layer.cornerRadius = self.frame.size.height / 2;
    
    [self.label Ease_updateConstraints:^(EaseConstraintMaker *make) {
        make.center.equalTo(self);
        make.left.greaterThanOrEqualTo(self).offset(6);
        make.right.greaterThanOrEqualTo(self).offset(-6);
    }];
}

- (void)_setupSubViews {
    [self addSubview:self.label];
}

- (void)setBadge:(int)badge {
    if (badge == 0) {
        [self setHidden:YES];
        return;
    }else {
        [self setHidden:NO];
    }
    
    NSString *text = @"";
    if (badge > _maxNum) {
        text = [NSString stringWithFormat:@"%d+", _maxNum];
    }else {
        text = [NSString stringWithFormat:@"%d", badge];
    }
    self.label.text = text;
}

- (int)badge {
    return [self.label.text intValue];
}

- (void)setBadgeColor:(UIColor *)badgeColor {
    self.label.textColor = badgeColor;
}

- (UIColor *)badgeColor {
    return self.label.textColor;
}

- (void)setFont:(UIFont *)font {
    self.label.font = font;
}

- (UIFont *)font {
    return self.label.font;
}

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] initWithFrame:CGRectZero];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.lineBreakMode = NSLineBreakByWordWrapping;
        [_label setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];

    }
    return _label;
}

@end
