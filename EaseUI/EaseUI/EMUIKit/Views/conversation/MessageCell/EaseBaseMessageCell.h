//
//  EaseBaseMessageCell.h
//  ChatDemo-UI3.0
//
//  Created by dhc on 15/6/30.
//  Copyright (c) 2015年 easemob.com. All rights reserved.
//

#import "EaseMessageCell.h"

extern NSString *const EaseMessageCellIdentifierSendText;
extern NSString *const EaseMessageCellIdentifierSendLocation;
extern NSString *const EaseMessageCellIdentifierSendVoice;
extern NSString *const EaseMessageCellIdentifierSendVideo;
extern NSString *const EaseMessageCellIdentifierSendImage;
extern NSString *const EaseMessageCellIdentifierSendFile;

@interface EaseBaseMessageCell : EaseMessageCell
{
    UILabel *_nameLabel;
}

/*!
 @property
 @brief 头像尺寸
 */
@property (nonatomic) CGFloat avatarSize UI_APPEARANCE_SELECTOR; //default 30;

/*!
 @property
 @brief 头像圆角
 */
@property (nonatomic) CGFloat avatarCornerRadius UI_APPEARANCE_SELECTOR; //default 0;

/*!
 @property
 @brief 发送者昵称字体
 */
@property (nonatomic) UIFont *messageNameFont UI_APPEARANCE_SELECTOR; //default [UIFont systemFontOfSize:10];

/*!
 @property
 @brief 发送者昵称颜色
 */
@property (nonatomic) UIColor *messageNameColor UI_APPEARANCE_SELECTOR; //default [UIColor grayColor];

/*!
 @property
 @brief 发送者昵称高度
 */
@property (nonatomic) CGFloat messageNameHeight UI_APPEARANCE_SELECTOR; //default 15;

/*!
 @property
 @brief 是否显示发送者昵称
 */
@property (nonatomic) BOOL messageNameIsHidden UI_APPEARANCE_SELECTOR; //default NO;

@end
