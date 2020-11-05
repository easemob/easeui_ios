//
//  EaseConversationCellOptions.m
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/10/29.
//

#import "EaseConversationCellOptions.h"
#import "Masonry.h"

@implementation EaseConversationCellOptions

- (instancetype)init
{
    self = [super init];
    if (self) {
        _bgColor = [UIColor whiteColor];
        _avatarStyle = EMAvatarStyleCorner;
        _unReadCountPosition = EMRightForCell;
        _unReadCountViewBgColor = [UIColor redColor];
        _longer = 20;
        _blankPerchView = [self defaultBlankPerchView];
    }
    
    return self;
}

- (UIView *)defaultBlankPerchView
{
    UIView *blankPerchView = [[UIView alloc]init];
    UIImageView *blankImgView = [[UIImageView alloc]init];
    blankImgView.image = [UIImage imageNamed:@"blankConversation"];
    [blankPerchView addSubview:blankImgView];
    [blankImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(blankPerchView);
    }];
    UILabel *blankPadding = [[UILabel alloc]init];
    blankPadding.text = @"寻找自我 保持本色";
    blankPadding.textColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0];
    blankPadding.font = [UIFont systemFontOfSize:12.0];
    [blankPerchView addSubview:blankPadding];
    [blankPadding mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(blankImgView.mas_bottom).offset(14);
        make.centerX.equalTo(blankImgView);
    }];
    
    return blankPerchView;
}

#pragma mark - Setter

- (void)setBgColor:(UIColor *)bgColor
{
    if (bgColor)
        _bgColor = bgColor;
}

- (void)setAvatarStyle:(EMAvatarStyle)avatarStyle
{
    if (avatarStyle >= EMAvatarMIN && avatarStyle <= EMAvatarMAX)
        _avatarStyle = avatarStyle;
}

- (void)setUnReadCountPosition:(EMUnReadCountViewPosition)unReadCountPosition
{
    if (unReadCountPosition >= EMPositionMIN && unReadCountPosition <= EMPositionMAX)
        _unReadCountPosition = unReadCountPosition;
}

- (void)setUnReadCountViewBgColor:(UIColor *)unReadCountViewBgColor
{
    if (unReadCountViewBgColor)
        _unReadCountViewBgColor = unReadCountViewBgColor;
}

- (void)setLonger:(CGFloat)longer
{
    if (longer >= 20 && longer <= 40)
        _longer = longer;
}

- (void)setBlankPerchView:(UIView *)blankPerchView
{
    if (blankPerchView)
        _blankPerchView = blankPerchView;
}

@end
