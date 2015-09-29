//
//  EMBubbleView.h
//  ChatDemo-UI3.0
//
//  Created by dhc on 15/6/29.
//  Copyright (c) 2015年 easemob.com. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGFloat const EMMessageCellPadding;

extern NSString *const EMMessageCellIdentifierSendText;
extern NSString *const EMMessageCellIdentifierSendLocation;
extern NSString *const EMMessageCellIdentifierSendVoice;
extern NSString *const EMMessageCellIdentifierSendVideo;
extern NSString *const EMMessageCellIdentifierSendImage;
extern NSString *const EMMessageCellIdentifierSendFile;

extern NSString *const EMMessageCellIdentifierRecvText;
extern NSString *const EMMessageCellIdentifierRecvLocation;
extern NSString *const EMMessageCellIdentifierRecvVoice;
extern NSString *const EMMessageCellIdentifierRecvVideo;
extern NSString *const EMMessageCellIdentifierRecvImage;
extern NSString *const EMMessageCellIdentifierRecvFile;

@interface EMBubbleView : UIView
{
    UIEdgeInsets _margin;
    CGFloat _fileIconSize;
}

@property (nonatomic) BOOL isSender;

@property (nonatomic, readonly) UIEdgeInsets margin;

@property (strong, nonatomic) NSMutableArray *marginConstraints;

@property (strong, nonatomic) UIImageView *backgroundImageView;

//text views
@property (strong, nonatomic) UILabel *textLabel;

//image views
@property (strong, nonatomic) UIImageView *imageView;

//location views
@property (strong, nonatomic) UIImageView *locationImageView;
@property (strong, nonatomic) UILabel *locationLabel;

//voice views
@property (strong, nonatomic) UIImageView *voiceImageView;
@property (strong, nonatomic) UILabel *voiceDurationLabel;
@property (strong, nonatomic) UIImageView *isReadView;

//video views
@property (strong, nonatomic) UIImageView *videoImageView;
@property (strong, nonatomic) UIImageView *videoTagView;

//file views
@property (strong, nonatomic) UIImageView *fileIconView;
@property (strong, nonatomic) UILabel *fileNameLabel;
@property (strong, nonatomic) UILabel *fileSizeLabel;

- (instancetype)initWithMargin:(UIEdgeInsets)margin
                      isSender:(BOOL)isSender;

@end
