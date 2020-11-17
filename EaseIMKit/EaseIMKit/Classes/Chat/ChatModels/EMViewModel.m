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
        _chatViewBgColor = kColor_chatViewBg;
        //_chatBarBgColor = [UIColor whiteColor];
        _chatBarBgColor = [UIColor orangeColor];
        //_msgTimeItemBgColor = kColor_LightGray;
        _msgTimeItemBgColor = [UIColor purpleColor];
        _msgTimeItemFontColor = [UIColor grayColor];
        _receiveBubbleBgPicture = [UIImage imageNamed:@"msg_bg_send"];
        _sendBubbleBgPicture = [UIImage imageNamed:@"msg_bg_recv"];
        _contentFontSize = 18.f;
        _chatBarStyle = EMChatBarStyleAll;
    }
    return self;
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

- (void)setContentFontSize:(float)contentFontSize
{
    if (contentFontSize > 0) {
        _contentFontSize = contentFontSize;
    }
}

@end
