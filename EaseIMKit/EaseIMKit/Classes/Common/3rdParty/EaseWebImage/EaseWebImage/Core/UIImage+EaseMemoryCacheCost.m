/*
 * This file is part of the EaseWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImage+EaseMemoryCacheCost.h"
#import "objc/runtime.h"
#import "NSImage+EaseCompatibility.h"

FOUNDATION_STATIC_INLINE NSUInteger EaseMemoryCacheCostForImage(UIImage *image) {
    CGImageRef imageRef = image.CGImage;
    if (!imageRef) {
        return 0;
    }
    NSUInteger bytesPerFrame = CGImageGetBytesPerRow(imageRef) * CGImageGetHeight(imageRef);
    NSUInteger frameCount;
#if Ease_MAC
    frameCount = 1;
#elif Ease_UIKIT || Ease_WATCH
    frameCount = image.images.count > 0 ? image.images.count : 1;
#endif
    NSUInteger cost = bytesPerFrame * frameCount;
    return cost;
}

@implementation UIImage (EaseMemoryCacheCost)

- (NSUInteger)Ease_memoryCost {
    NSNumber *value = objc_getAssociatedObject(self, @selector(Ease_memoryCost));
    NSUInteger memoryCost;
    if (value != nil) {
        memoryCost = [value unsignedIntegerValue];
    } else {
        memoryCost = EaseMemoryCacheCostForImage(self);
    }
    return memoryCost;
}

- (void)setSd_memoryCost:(NSUInteger)Ease_memoryCost {
    objc_setAssociatedObject(self, @selector(Ease_memoryCost), @(Ease_memoryCost), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
