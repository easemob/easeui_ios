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
    UIEdgeInsets edge = UIEdgeInsetsMake(8, 8, 8, 8);
    if (self.direction == EMMessageDirectionSend) {
        UIImage *image = [_viewModel.sendBubbleBgPicture resizableImageWithCapInsets:edge resizingMode:UIImageResizingModeStretch];
        [self setImage:image];
    } else {
        UIImage *image = [_viewModel.receiveBubbleBgPicture resizableImageWithCapInsets:edge resizingMode:UIImageResizingModeStretch];
        [self setImage:image];
    }
}

@end
