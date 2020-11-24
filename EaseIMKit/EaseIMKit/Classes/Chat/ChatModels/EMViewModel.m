//
//  EMViewModel.m
//  EaseIMKit
//
//  Created by 娜塔莎 on 2020/11/17.
//

#import "EMViewModel.h"
#import "EMColorDefine.h"

@implementation EMViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _chatViewHeight = 500;
        //_chatViewBgColor = kColor_chatViewBg;
        _chatViewBgColor = [UIColor systemPinkColor];
        //_chatBarBgColor = [UIColor whiteColor];
        _chatBarBgColor = [UIColor orangeColor];
        //_msgTimeItemBgColor = kColor_LightGray;
        _msgTimeItemBgColor = [UIColor purpleColor];
        _msgTimeItemFontColor = [UIColor grayColor];
        _receiveBubbleBgPicture = [UIImage imageNamed:@"msg_bg_recv"];
        _sendBubbleBgPicture = [UIImage imageNamed:@"msg_bg_send"];
        _contentFontSize = 18.f;
        _chatBarStyle = EMChatBarStyleAll;
        _avatarStyle = Circular;
        _avatarCornerRadius = 0;
        _avatarLength = 40;
    }
    return self;
}

- (void)setChatViewHeight:(CGFloat)chatViewHeight
{
    if (chatViewHeight > 0) {
        _chatViewHeight = chatViewHeight;
    }
}

- (void)setChatViewBgColor:(UIColor *)chatViewBgColor
{
    if (chatViewBgColor) {
        _chatViewBgColor = chatViewBgColor;
    }
}

- (void)setChatBarBgColor:(UIColor *)chatBarBgColor
{
    if (chatBarBgColor) {
        _chatBarBgColor = chatBarBgColor;
    }
}

- (void)setMsgTimeItemBgColor:(UIColor *)msgTimeItemBgColor
{
    if (msgTimeItemBgColor) {
        _msgTimeItemBgColor = msgTimeItemBgColor;
    }
}

- (void)setMsgTimeItemFontColor:(UIColor *)msgTimeItemFontColor
{
    if (msgTimeItemFontColor) {
        _msgTimeItemFontColor = msgTimeItemFontColor;
    }
}

- (void)setReceiveBubbleBgPicture:(UIImage *)receiveBubbleBgPicture
{
    if (receiveBubbleBgPicture) {
        _receiveBubbleBgPicture = receiveBubbleBgPicture;
    }
}

- (void)setSendBubbleBgPicture:(UIImage *)sendBubbleBgPicture
{
    if (sendBubbleBgPicture) {
        _sendBubbleBgPicture = sendBubbleBgPicture;
    }
}

- (void)setContentFontSize:(CGFloat)contentFontSize
{
    if (contentFontSize > 0) {
        _contentFontSize = contentFontSize;
    }
}

- (void)setChatBarStyle:(EMChatBarStyle)chatBarStyle
{
    if (chatBarStyle >= 1 && chatBarStyle <= 5) {
        _chatBarStyle = chatBarStyle;
    }
}

- (void)setAvatarStyle:(EaseAvatarStyle)avatarStyle
{
    if (avatarStyle >= 1 && avatarStyle <= 3) {
        _avatarStyle = avatarStyle;
    }
}

- (void)setAvatarCornerRadius:(CGFloat)avatarCornerRadius
{
    if (avatarCornerRadius > 0) {
        _avatarCornerRadius = avatarCornerRadius;
    }
}

- (void)setAvatarLength:(CGFloat)avatarLength
{
    if (avatarLength > 0) {
        _avatarLength = avatarLength;
    }
}

@end
