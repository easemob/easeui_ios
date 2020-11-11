//
//  IconResourceManage.h
//  EaseIMKit
//
//  Created by 娜塔莎 on 2020/11/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IconResourceManage : NSObject

//获取图标
+ (UIImage*)imageNamed:(NSString *)imageName class:(Class)aClass;

@end

NS_ASSUME_NONNULL_END
