//
//  IconResourceManage.m
//  EaseIMKit
//
//  Created by 娜塔莎 on 2020/11/10.
//

#import "IconResourceManage.h"

@implementation IconResourceManage

+ (UIImage*)imageNamed:(NSString *)imageName class:(Class)aClass
{
    NSBundle *resource_bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:aClass].resourcePath stringByAppendingPathComponent:@"/EaseIMKitIcon.bundle"]];
    return [UIImage imageNamed:imageName inBundle:resource_bundle compatibleWithTraitCollection:nil];
}

@end
