/*
* This file is part of the EaseWebImage package.
* (c) Olivier Poitrey <rs@dailymotion.com>
* (c) Fabrice Aneche
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/

#import "UIImage+EaseExtendedCacheData.h"
#import <objc/runtime.h>

@implementation UIImage (EaseExtendedCacheData)

- (id<NSObject, NSCoding>)ease_extendedObject {
    return objc_getAssociatedObject(self, @selector(ease_extendedObject));
}

- (void)setEase_extendedObject:(id<NSObject, NSCoding>)ease_extendedObject {
    objc_setAssociatedObject(self, @selector(ease_extendedObject), ease_extendedObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
