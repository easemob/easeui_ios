//
//  EMMessageBubbleView.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/25.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMMessageBubbleView.h"

@implementation EMMessageBubbleView

- (instancetype)initWithDirection:(EMMessageDirection)aDirection
                             type:(EMMessageType)aType
                        viewModel:(EaseChatViewModel *)viewModel
{
    self = [super init];
    if (self) {
        _direction = aDirection;
        _type = aType;
        _viewModel = viewModel;
    }
    
    return self;
}

- (void)setupBubbleBackgroundImage
{
    if (self.direction == EMMessageDirectionSend) {
        self.image = [_viewModel.sendBubbleBgPicture stretchableImageWithLeftCapWidth:15 topCapHeight:15];
    } else {
        self.image = [_viewModel.receiveBubbleBgPicture stretchableImageWithLeftCapWidth:15 topCapHeight:15];
    }
    //[self compressQualityImage];
}

- (void)compressQualityImage
{
    CGFloat compressQuality = 1;
    NSData *data = UIImageJPEGRepresentation(self.image, compressQuality);
    self.image = [UIImage imageWithData:data];
}

@end
