//
//  EMMessageBubbleView.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/25.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EaseMessageModel.h"
#import "EaseHeaders.h"
#import "EaseChatViewModel.h"
#import "UIImage+EaseUI.h"

@interface EMMessageBubbleView : UIImageView

@property (nonatomic, readonly) EMMessageDirection direction;

@property (nonatomic, readonly) EMMessageType type;

@property (nonatomic, strong) EaseMessageModel *model;

@property (nonatomic, strong) EaseChatViewModel *viewModel;

- (instancetype)initWithDirection:(EMMessageDirection)aDirection
                             type:(EMMessageType)aType
                        viewModel:(EaseChatViewModel *)viewModel;

- (void)setupBubbleBackgroundImage;

@end
