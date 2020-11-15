//
//  UIImage+EaseUI.m
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/11/15.
//

#import "UIImage+EaseUI.h"
#import <objc/runtime.h>

@implementation UIImage (EaseUI)
+(void)load {
    Method imageWithName = class_getClassMethod([self class], @selector(imageNamed:));
    Method dImageWithName = class_getClassMethod([self class], @selector(easeUIImageNamed:));
    method_exchangeImplementations(imageWithName, dImageWithName);
}

+ (UIImage *)easeUIImageNamed:(NSString *)name {
    NSBundle *resource_bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"/Frameworks/EaseIMKit.framework/EaseIMKit" ofType:@"bundle"]];
    return [UIImage imageNamed:name inBundle:resource_bundle compatibleWithTraitCollection:nil];
}
@end
