//
//  EMHelper.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/2/22.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <Hyphenate/Hyphenate.h>

#import <Masonry/Masonry.h>

#import "EaseEnums.h"
#import "EaseDefines.h"
#import "EaseColorDefine.h"

#import "NSObject+Alert.h"

#import "EaseAlertController.h"
#import "EaseAlertView.h"

#import "EaseEmojiHelper.h"
#import "UIViewController+HUD.h"
#import "UIColor+EaseUI.h"

#define UIColorFromRGB(rgbValue)  UIColorFromRGBA(rgbValue, 1.0)

#define UIColorFromRGBA(rgbValue,a)  ([UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a])

