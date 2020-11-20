//
//  EaseHelper.h
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/11/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define UIColorFromRGB(rgbValue)  UIColorFromRGBA(rgbValue, 1.0)

#define UIColorFromRGBA(rgbValue,a)  ([UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a])





@interface EaseHelper : NSObject

@end

NS_ASSUME_NONNULL_END
