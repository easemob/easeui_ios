//
//  EaseMessageStatusView.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/25.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EaseMessageStatusView.h"
#import "EaseLoadingCALayer.h"
#import "EaseOneLoadingAnimationView.h"
#import "UIImage+EaseUI.h"

@interface EaseMessageStatusView()

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIButton *failButton;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@property (strong, nonatomic) IBOutlet EaseOneLoadingAnimationView *loadingView;//加载view

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation EaseMessageStatusView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.hidden = YES;
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

#pragma mark - Subviews

- (UILabel *)label
{
    if (_label == nil) {
        _label = [[UILabel alloc] init];
        _label.textColor = [UIColor grayColor];
        _label.font = [UIFont systemFontOfSize:13];
    }
    
    return _label;
}

- (UIButton *)failButton
{
    if (_failButton == nil) {
        _failButton = [[UIButton alloc] init];
        [_failButton setImage:[UIImage easeUIImageNamed:@"iconSendFail"] forState:UIControlStateNormal];
        [_failButton addTarget:self action:@selector(failButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _failButton;
}

- (UIView *)loadingView
{
    if (_loadingView == nil) {
        _loadingView = [[EaseOneLoadingAnimationView alloc]initWithRadius:9.0];
        //_loadingView.backgroundColor = [UIColor lightGrayColor];
    }
    return _loadingView;
}

- (UIActivityIndicatorView *)activityView
{
    if (_activityView == nil) {
        if (@available(iOS 13.0, *)) {
            _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        } else {
            _activityView = [[UIActivityIndicatorView alloc]init];
        }
        _activityView.color = [UIColor colorWithHexString:@"#2D74D7"];
    }
    
    return _activityView;
}

#pragma mark - Public

- (void)setSenderStatus:(EMMessageStatus)aStatus
            isReadAcked:(BOOL)aIsReadAcked
{
    if (aStatus == EMMessageStatusDelivering) {
        self.hidden = NO;
        [_label removeFromSuperview];
        [_failButton removeFromSuperview];
        /*
        [self addSubview:self.activityView];
        [self.activityView Ease_makeConstraints:^(EaseConstraintMaker *make) {
            make.edges.equalTo(self);
            make.width.equalTo(@20);
        }];
        [self.activityView startAnimating];*/
        
        [self addSubview:self.loadingView];
        [self.loadingView Ease_makeConstraints:^(EaseConstraintMaker *make) {
            make.edges.equalTo(self);
            make.width.equalTo(@20);
        }];
        [self.loadingView startAnimation];
    
    } else if (aStatus == EMMessageStatusFailed || aStatus == EMMessageStatusPending) {
        self.hidden = NO;
        [_label removeFromSuperview];
        
        //[_activityView stopAnimating];
        //[_activityView removeFromSuperview];
        
        [_loadingView stopTimer];
        [_loadingView removeFromSuperview];
        [self addSubview:self.failButton];
        [self.failButton Ease_makeConstraints:^(EaseConstraintMaker *make) {
            make.edges.equalTo(self);
            make.width.equalTo(@20);
        }];
    } else if (aStatus == EMMessageStatusSucceed) {
        self.hidden = NO;
        [_failButton removeFromSuperview];
        /*
        [_activityView stopAnimating];
        [_activityView removeFromSuperview];
        */
        [_loadingView stopTimer];
        [_loadingView removeFromSuperview];
        self.label.text = aIsReadAcked ? EaseLocalizableString(@"read", nil) : nil;
        [self addSubview:self.label];
        [self.label Ease_makeConstraints:^(EaseConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    } else {
        self.hidden = YES;
        [_label removeFromSuperview];
        [_failButton removeFromSuperview];
        
        //[_activityView stopAnimating];
        //[_activityView removeFromSuperview];
        [_loadingView stopTimer];
        [_loadingView removeFromSuperview];
    }
}

#pragma mark - Action

- (void)failButtonAction
{
    if (self.resendCompletion) {
        self.resendCompletion();
    }
}

@end
