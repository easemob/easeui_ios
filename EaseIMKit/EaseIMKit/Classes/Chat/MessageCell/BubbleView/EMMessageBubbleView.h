//
//  EMMessageBubbleView.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/25.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EMMessageModel.h"
#import "EaseHeaders.h"
#import "EMViewModel.h"
#import "UIImage+EaseUI.h"

@interface EMMessageBubbleView : UIImageView

@property (nonatomic, readonly) EMMessageDirection direction;

@property (nonatomic, readonly) EMMessageType type;

@property (nonatomic, strong) EMMessageModel *model;

@property (nonatomic, strong) EMViewModel *viewModel;

- (instancetype)initWithDirection:(EMMessageDirection)aDirection
                             type:(EMMessageType)aType
                        viewModel:(EMViewModel *)viewModel;

- (void)setupBubbleBackgroundImage;

@end
