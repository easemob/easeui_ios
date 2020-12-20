//
//  EaseAlertController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/12/24.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "EaseAlertController.h"
#import "EaseHeaders.h"
#import "UIImage+EaseUI.h"
#import "UIColor+EaseUI.h"

@interface EaseAlertController()

@property (nonatomic, strong) UIView *mainView;

@end

@implementation EaseAlertController

- (instancetype)initWithStyle:(EaseAlertViewStyle)aStyle
                      message:(NSString *)aMessage
{
    self = [super init];
    if (self) {
        [self _setupWithStyle:aStyle message:aMessage];
    }
    
    return self;
}

- (void)_setupWithStyle:(EaseAlertViewStyle)aStyle
                message:(NSString *)aMessage
{
    self.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.1];
    
    self.mainView = [[UIView alloc] init];
    self.mainView.backgroundColor = [UIColor whiteColor];
    self.mainView.layer.cornerRadius = 5.0;
    self.mainView.layer.shadowColor = [UIColor grayColor].CGColor;
    self.mainView.layer.shadowOffset = CGSizeMake(2, 5);
    self.mainView.layer.shadowOpacity = 0.5;
    [self addSubview:self.mainView];
    [self.mainView Ease_makeConstraints:^(EaseConstraintMaker *make) {
        make.top.equalTo(self).offset(-60);
        make.centerX.equalTo(self);
        make.left.greaterThanOrEqualTo(self).offset(30);
    }];
    
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = [UIColor clearColor];
    bgView.clipsToBounds = YES;
    bgView.layer.cornerRadius = 5.0;
    [self.mainView addSubview:bgView];
    [bgView Ease_makeConstraints:^(EaseConstraintMaker *make) {
        make.edges.equalTo(self.mainView);
    }];
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [self _tagColorWithStyle:aStyle];
    [bgView addSubview:line];
    [line Ease_makeConstraints:^(EaseConstraintMaker *make) {
        make.top.equalTo(bgView);
        make.bottom.equalTo(bgView);
        make.left.equalTo(bgView);
        make.width.equalTo(@3);
    }];
    
    UIImageView *tagView = [[UIImageView alloc] init];
    tagView.image = [self _tagImageWithStyle:aStyle];
    [bgView addSubview:tagView];
    [tagView Ease_makeConstraints:^(EaseConstraintMaker *make) {
        make.centerY.equalTo(bgView);
        make.left.equalTo(bgView).offset(15);
    }];
    
    UILabel *label = [[UILabel alloc] init];
    label.numberOfLines = 5;
    label.font = [UIFont systemFontOfSize:16];
    label.text = aMessage;
    [bgView addSubview:label];
    [label Ease_makeConstraints:^(EaseConstraintMaker *make) {
        make.left.equalTo(tagView.ease_right).offset(10);
        make.right.equalTo(bgView).offset(-15);
        make.top.equalTo(bgView).offset(12);
        make.bottom.equalTo(bgView).offset(-12);
    }];
}

- (UIColor *)_tagColorWithStyle:(EaseAlertViewStyle)aStyle
{
    UIColor *color = [UIColor colorWithHexString:@"#2D74D7"];
    switch (aStyle) {
        case EaseAlertViewStyleError:
            color = [UIColor colorWithHexString:@"#CC3A23"];
            break;
        case EaseAlertViewStyleInfo:
            color = [UIColor colorWithHexString:@"#E8C040"];
            break;
        case EaseAlertViewStyleSuccess:
            color = [UIColor colorWithHexString:@"#239E55"];
            break;
            
        default:
            break;
    }
    
    return color;
}

- (UIImage *)_tagImageWithStyle:(EaseAlertViewStyle)aStyle
{
    NSString *imageName = @"alert_default";
    switch (aStyle) {
        case EaseAlertViewStyleError:
            imageName = @"alert_error";
            break;
        case EaseAlertViewStyleInfo:
            imageName = @"alert_info";
            break;
        case EaseAlertViewStyleSuccess:
            imageName = @"alert_success";
            break;
            
        default:
            break;
    }
    
    return [UIImage easeUIImageNamed:imageName];
}

+ (void)showAlertWithStyle:(EaseAlertViewStyle)aStyle
                   message:(NSString *)aMessage
{
    EaseAlertController *view = [[EaseAlertController alloc] initWithStyle:aStyle message:aMessage];
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:view];
    [view Ease_makeConstraints:^(EaseConstraintMaker *make) {
        make.edges.equalTo(keyWindow);
    }];
    
    [view layoutIfNeeded];
    [view setNeedsUpdateConstraints];
    [view.mainView Ease_updateConstraints:^(EaseConstraintMaker *make) {
        make.top.equalTo(view).offset(50);
    }];
    [UIView animateWithDuration:0.3 animations:^{
        [view layoutIfNeeded];
    } completion:^(BOOL finished) {
        //
    }];
    
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [view layoutIfNeeded];
        [view setNeedsUpdateConstraints];
        [view.mainView Ease_updateConstraints:^(EaseConstraintMaker *make) {
            make.top.equalTo(view).offset(-60);
        }];
        [UIView animateWithDuration:0.3 animations:^{
            [view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [view removeFromSuperview];
        }];
    });
}

+ (void)showErrorAlert:(NSString *)aMessage
{
    [EaseAlertController showAlertWithStyle:EaseAlertViewStyleError message:aMessage];
}

+ (void)showSuccessAlert:(NSString *)aMessage
{
    [EaseAlertController showAlertWithStyle:EaseAlertViewStyleSuccess message:aMessage];
}

+ (void)showInfoAlert:(NSString *)aMessage
{
    [EaseAlertController showAlertWithStyle:EaseAlertViewStyleInfo message:aMessage];
}

@end
