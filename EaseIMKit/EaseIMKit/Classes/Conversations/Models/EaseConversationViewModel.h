//
//  EaseConversationViewModel.h
//  EaseIMKit
//
//  Created by 娜塔莎 on 2020/11/12.
//

#import <Foundation/Foundation.h>
#import "EaseBaseTableViewModel.h"
#import "EaseEnums.h"


NS_ASSUME_NONNULL_BEGIN

@interface EaseConversationViewModel : EaseBaseTableViewModel

// 头像样式
@property (nonatomic) EaseAvatarStyle avatarType;

// 默认头像
@property (nonatomic, strong) UIImage *defaultAvatarImage;

// 头像尺寸
@property (nonatomic) CGSize avatarSize;

// 头像位置
@property (nonatomic) UIEdgeInsets avatarEdgeInsets;

// 会话置顶背景色
@property (nonatomic, strong) UIColor *topBgColor;

// 昵称字体
@property (nonatomic, strong) UIFont *nameLabelFont;

// 昵称颜色
@property (nonatomic, strong) UIColor *nameLabelColor;

// 昵称位置
@property (nonatomic) UIEdgeInsets nameLabelEdgeInsets;

// 详情字体
@property (nonatomic, strong) UIFont *detailLabelFont;

// 详情字色
@property (nonatomic, strong) UIColor *detailLabelColor;

// 详情位置
@property (nonatomic) UIEdgeInsets detailLabelEdgeInsets;

// 时间字体
@property (nonatomic, strong) UIFont *timeLabelFont;

// 时间字色
@property (nonatomic, strong) UIColor *timeLabelColor;

// 时间位置
@property (nonatomic) UIEdgeInsets timeLabelEdgeInsets;

// 未读数显示风格
@property (nonatomic) EMUnReadCountViewPosition badgeLabelPosition;

// 未读数字体
@property (nonatomic, strong) UIFont *badgeLabelFont;

// 未读数字色
@property (nonatomic, strong) UIColor *badgeLabelTitleColor;

// 未读数背景色
@property (nonatomic, strong) UIColor *badgeLabelBgColor;

// 未读数角标高度
@property (nonatomic) CGFloat badgeLabelHeight;

// 未读数中心位置偏移
@property (nonatomic) CGVector badgeLabelCenterVector;

// 未读数显示上限, 超过上限后会显示 xx+
@property (nonatomic) int badgeMaxNum;



@end

NS_ASSUME_NONNULL_END
