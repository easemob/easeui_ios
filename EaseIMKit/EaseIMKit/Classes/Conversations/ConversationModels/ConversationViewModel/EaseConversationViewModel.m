//
//  EaseConversationViewModel.m
//  EaseIMKit
//
//  Created by 娜塔莎 on 2020/11/12.
//

#import "EaseConversationViewModel.h"

@implementation EaseConversationViewModel
@synthesize avatarSize = _avatarSize;
@synthesize avatarEdgeInsets = _avatarEdgeInsets;
- (instancetype)init
{
    self = [super init];
    if (self) {
        _avatarSize = CGSizeMake(80, 40);
        _avatarEdgeInsets = UIEdgeInsetsMake(3, 3, 3, 3);
        _wordSizeForCellTitle = 18.0;
        _wordSizeForCellDetail = 16.0;
        _wordSizeForCellTimestamp = 12.0;
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

// super
- (void)setCellBgColor:(UIColor *)conversationCellBgColor
{
    if (conversationCellBgColor) {
        self.cellBgColor = conversationCellBgColor;
    }
}


- (void)setCellHeight:(CGFloat)cellHeight
{
    if (cellHeight && cellHeight > 0) {
        self.cellHeight = cellHeight < 0 ? 0 : cellHeight;
    }
}

- (void)setViewBgColor:(UIColor *)viewBgColor
{
    if (viewBgColor) {
        self.viewBgColor = viewBgColor;
    }
}


- (void)setWordSizeForCellTitle:(CGFloat)wordSizeForCellTitle
{
    if (wordSizeForCellTitle && wordSizeForCellTitle > 0) {
        _wordSizeForCellTitle = wordSizeForCellTitle;
    }
}

- (void)setWordSizeForCellDetail:(CGFloat)wordSizeForCellDetail
{
    if (wordSizeForCellDetail && wordSizeForCellDetail > 0) {
        _wordSizeForCellDetail = wordSizeForCellDetail;
    }
}

- (void)setWordSizeForCellTimestamp:(CGFloat)wordSizeForCellTimestamp
{
    if (wordSizeForCellTimestamp && wordSizeForCellTimestamp > 0) {
        _wordSizeForCellTimestamp = wordSizeForCellTimestamp;
    }
}

- (void)setUnReadCountPosition:(EMUnReadCountViewPosition)unReadCountPosition
{
    if (unReadCountPosition >= 0 && unReadCountPosition <= 1) {
        _unReadCountPosition = unReadCountPosition;
    }
}

- (void)setUnReadCountViewBgColor:(UIColor *)unReadCountViewBgColor
{
    if (unReadCountViewBgColor) {
        _unReadCountViewBgColor = unReadCountViewBgColor;
    }
}

- (void)setLonger:(CGFloat)longer
{
    if (longer >= 20 && longer <= 40) {
        _longer = longer;
    }
}

- (void)setBlankPerchView:(UIView *)blankPerchView
{
    if (blankPerchView) {
        _blankPerchView = blankPerchView;
    }
}

@end
