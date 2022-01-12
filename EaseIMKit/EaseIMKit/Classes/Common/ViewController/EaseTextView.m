/************************************************************
  *  * HyphenateChat CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2016 HyphenateChat Inc. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of HyphenateChat Inc.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from HyphenateChat Inc.
  */

#import "EaseTextView.h"
#import "EaseHeaders.h"


@interface EaseTextView ()
@property (nonatomic ,strong) UILabel *placeHolderLabel;
@end

@implementation EaseTextView
#pragma mark - Life cycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveTextDidChangeNotification:)
                                                     name:UITextViewTextDidChangeNotification
                                                   object:self];
        [self placeAndLayoutSubviews];
    }
    return self;
}

- (void)placeAndLayoutSubviews {
    [self addSubview:self.placeHolderLabel];
    [self.placeHolderLabel Ease_makeConstraints:^(EaseConstraintMaker *make) {
        make.top.equalTo(self).offset(7.0);
        make.left.equalTo(self).offset(14.0);
        make.right.equalTo(self).offset(-14.0);
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:self];
}

#pragma mark - Notifications
- (void)didReceiveTextDidChangeNotification:(NSNotification *)notification {
    self.placeHolderLabel.hidden = self.text.length > 0 ? YES : NO;
}


#pragma mark getter and setter
- (UILabel *)placeHolderLabel {
    if (_placeHolderLabel == nil) {
        _placeHolderLabel = [[UILabel alloc] init];
        _placeHolderLabel.font = self.font;
        _placeHolderLabel.textColor = [UIColor lightGrayColor];
        _placeHolderLabel.textAlignment = NSTextAlignmentLeft;
        _placeHolderLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _placeHolderLabel;
}

- (void)setPlaceHolder:(NSString *)placeHolder {
    _placeHolder = placeHolder;
    self.placeHolderLabel.text = _placeHolder;
}

- (void)setPlaceHolderColor:(UIColor *)placeHolderColor {
    _placeHolderColor = placeHolderColor;
    self.placeHolderLabel.textColor = _placeHolderColor;
}



@end
