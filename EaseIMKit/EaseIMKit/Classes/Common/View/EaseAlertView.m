//
//  EaseAlertView.m
//  EaseIM
//
//  Created by 娜塔莎 on 2020/9/27.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import "EaseAlertView.h"
#import "EaseHeaders.h"

@interface EaseAlertView ()

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *message;

@end

@implementation EaseAlertView

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message
{
    if (self = [super init]) {
        _title = (title && [title length] > 0) ? title : EaseLocalizableString(@"prompt", nil);
        _message = message;
    }
    return self;
}

- (void)show {
    [self _setupSubViews];
}

- (void)_setupSubViews
{
    self.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.1];
    UIWindow *win = [[[UIApplication sharedApplication] windows] firstObject];
    self.frame = win.bounds;
    [win addSubview:self];
    
    UIView *backView = [[UIView alloc]init];
    backView.backgroundColor = [UIColor whiteColor];
    backView.layer.cornerRadius = 15;
    [self addSubview:backView];
    [backView Ease_makeConstraints:^(EaseConstraintMaker *make) {
        make.left.equalTo(self).offset(30);
        make.right.equalTo(self).offset(-30);
        make.height.equalTo(@160);
        make.center.equalTo(self);
    }];
    
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.text = _title;
    titleLabel.textColor = [UIColor blackColor];
    [titleLabel setFont:[UIFont systemFontOfSize:16.f]];
    titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [backView addSubview:titleLabel];
    [titleLabel Ease_makeConstraints:^(EaseConstraintMaker *make) {
        make.top.equalTo(backView);
        make.left.right.equalTo(backView);
        make.height.equalTo(@50);
    }];
    
    UILabel *messageLabel = [[UILabel alloc]init];
    messageLabel.text = _message;
    messageLabel.textColor = [UIColor blackColor];
    [messageLabel setFont:[UIFont systemFontOfSize:14.f]];
    messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.numberOfLines = 2;
    [backView addSubview:messageLabel];
    [messageLabel Ease_makeConstraints:^(EaseConstraintMaker *make) {
        make.top.equalTo(titleLabel.ease_bottom);
        make.left.equalTo(backView).offset(16);
        make.right.equalTo(backView).offset(-16);
        make.height.equalTo(@45);
    }];
    
    UIView *line = [[UIView alloc]init];
    line.backgroundColor = [UIColor lightGrayColor];
    [backView addSubview:line];
    [line Ease_makeConstraints:^(EaseConstraintMaker *make) {
        make.top.equalTo(messageLabel.ease_bottom).offset(8);
        make.left.right.equalTo(backView);
        make.height.equalTo(@1);
    }];
    
    UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [confirmBtn addTarget:self action:@selector(confirmAction) forControlEvents:UIControlEventTouchUpInside];
    confirmBtn.layer.cornerRadius = 10;
    [confirmBtn setTitle:EaseLocalizableString(@"ok", nil) forState:UIControlStateNormal];
    [confirmBtn.titleLabel setFont:[UIFont systemFontOfSize:16.f]];
    [confirmBtn setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    [backView addSubview:confirmBtn];
    [confirmBtn Ease_makeConstraints:^(EaseConstraintMaker *make) {
        make.top.equalTo(line.ease_bottom);
        make.bottom.equalTo(backView);
        make.left.right.equalTo(backView);
    }];
}

- (void)confirmAction
{
    [self removeFromSuperview];
}

@end
