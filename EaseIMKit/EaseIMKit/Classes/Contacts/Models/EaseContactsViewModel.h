//
//  EaseContactsViewModel.h
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/11/5.
//

#import <Foundation/Foundation.h>
#import "EaseBaseTableViewModel.h"
#import "EaseEnums.h"

NS_ASSUME_NONNULL_BEGIN

@interface EaseContactsViewModel : EaseBaseTableViewModel

// 头像样式
@property (nonatomic) EaseAvatarStyle avatarType;

// 默认头像
@property (nonatomic, strong) UIImage *defaultAvatarImage;

// 头像尺寸
@property (nonatomic) CGSize avatarSize;

// 头像位置
@property (nonatomic) UIEdgeInsets avatarEdgeInsets;

// 昵称字体
@property (nonatomic, strong) UIFont *nameLabelFont;

// 昵称颜色
@property (nonatomic, strong) UIColor *nameLabelColor;

// 昵称位置
@property (nonatomic) UIEdgeInsets nameLabelEdgeInsets;

// section title 字体
@property (nonatomic, strong) UIFont *sectionTitleFont;

// section title颜色
@property (nonatomic, strong) UIColor *sectionTitleColor;

// section title背景
@property (nonatomic, strong) UIColor *sectionTitleBgColor;

// section title 位置
@property (nonatomic) UIEdgeInsets sectionTitleEdgeInsets;

// section title label 高度 (section title view = sectionTitleLabelHeight + sectionTitleEdgeInsets.top + sectionTitleEdgeInsets.bottom)
@property (nonatomic) CGFloat sectionTitleLabelHeight;

@end

NS_ASSUME_NONNULL_END
