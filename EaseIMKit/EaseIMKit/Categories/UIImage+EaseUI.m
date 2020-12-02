//
//  UIImage+EaseUI.m
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/11/15.
//

#import "UIImage+EaseUI.h"
#import <objc/runtime.h>

@implementation UIImage (EaseUI)
+ (UIImage *)easeUIImageNamed:(NSString *)name {
    NSBundle *resource_bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"Frameworks/EaseIMKit.framework" ofType:nil]];
    return [UIImage imageNamed:name inBundle:resource_bundle compatibleWithTraitCollection:nil];
}
@end
