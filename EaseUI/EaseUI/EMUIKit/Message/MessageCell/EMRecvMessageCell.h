//
//  EMRecvMessageCell.h
//  ChatDemo-UI3.0
//
//  Created by dhc on 15/6/30.
//  Copyright (c) 2015年 easemob.com. All rights reserved.
//

#import "EMMessageCell.h"

extern NSString *const EMMessageCellIdentifierRecvText;
extern NSString *const EMMessageCellIdentifierRecvLocation;
extern NSString *const EMMessageCellIdentifierRecvVoice;
extern NSString *const EMMessageCellIdentifierRecvVideo;
extern NSString *const EMMessageCellIdentifierRecvImage;
extern NSString *const EMMessageCellIdentifierRecvFile;

@interface EMRecvMessageCell : EMMessageCell
{
    UIImageView *_avatarView;
    UILabel *_nameLabel;
}

@property (nonatomic) CGFloat avatarSize UI_APPEARANCE_SELECTOR; //default 30;

@property (nonatomic) CGFloat avatarCornerRadius UI_APPEARANCE_SELECTOR; //default 0;

@property (nonatomic) UIFont *messageNameFont UI_APPEARANCE_SELECTOR; //default [UIFont systemFontOfSize:10];

@property (nonatomic) UIColor *messageNameColor UI_APPEARANCE_SELECTOR; //default [UIColor grayColor];

@property (nonatomic) CGFloat messageNameHeight UI_APPEARANCE_SELECTOR; //default 15;

@end
