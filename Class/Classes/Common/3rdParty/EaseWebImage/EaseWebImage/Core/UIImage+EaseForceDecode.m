/*
 * This file is part of the EaseWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImage+EaseForceDecode.h"
#import "EaseImageCoderHelper.h"
#import "objc/runtime.h"

@implementation UIImage (EaseForceDecode)

- (BOOL)ease_isDecoded {
    NSNumber *value = objc_getAssociatedObject(self, @selector(ease_isDecoded));
    return value.boolValue;
}

- (void)setEase_isDecoded:(BOOL)ease_isDecoded {
    objc_setAssociatedObject(self, @selector(ease_isDecoded), @(ease_isDecoded), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (nullable UIImage *)Ease_decodedImageWithImage:(nullable UIImage *)image {
    if (!image) {
        return nil;
    }
    return [EaseImageCoderHelper decodedImageWithImage:image];
}

+ (nullable UIImage *)Ease_decodedAndScaledDownImageWithImage:(nullable UIImage *)image {
    return [self Ease_decodedAndScaledDownImageWithImage:image limitBytes:0];
}

+ (nullable UIImage *)Ease_decodedAndScaledDownImageWithImage:(nullable UIImage *)image limitBytes:(NSUInteger)bytes {
    if (!image) {
        return nil;
    }
    return [EaseImageCoderHelper decodedAndScaledDownImageWithImage:image limitBytes:bytes];
}

@end
