/*
 * This file is part of the EaseWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "EaseImageGraphics.h"
#import "NSImage+EaseCompatibility.h"
#import "objc/runtime.h"

#if Ease_MAC
static void *kNSGraphicsContextScaleFactorKey;

static CGContextRef EaseCGContextCreateBitmapContext(CGSize size, BOOL opaque, CGFloat scale) {
    if (scale == 0) {
        // Match `UIGraphicsBeginImageContextWithOptions`, reset to the scale factor of the device’s main screen if scale is 0.
        scale = [NSScreen mainScreen].backingScaleFactor;
    }
    size_t width = ceil(size.width * scale);
    size_t height = ceil(size.height * scale);
    if (width < 1 || height < 1) return NULL;
    
    //pre-multiplied BGRA for non-opaque, BGRX for opaque, 8-bits per component, as Apple's doc
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGImageAlphaInfo alphaInfo = kCGBitmapByteOrder32Host | (opaque ? kCGImageAlphaNoneSkipFirst : kCGImageAlphaPremultipliedFirst);
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 0, space, kCGBitmapByteOrderDefault | alphaInfo);
    CGColorSpaceRelease(space);
    if (!context) {
        return NULL;
    }
    CGContextScaleCTM(context, scale, scale);
    
    return context;
}
#endif

CGContextRef EaseGraphicsGetCurrentContext(void) {
#if Ease_UIKIT || Ease_WATCH
    return UIGraphicsGetCurrentContext();
#else
    return NSGraphicsContext.currentContext.CGContext;
#endif
}

void EaseGraphicsBeginImageContext(CGSize size) {
#if Ease_UIKIT || Ease_WATCH
    UIGraphicsBeginImageContext(size);
#else
    EaseGraphicsBeginImageContextWithOptions(size, NO, 1.0);
#endif
}

void EaseGraphicsBeginImageContextWithOptions(CGSize size, BOOL opaque, CGFloat scale) {
#if Ease_UIKIT || Ease_WATCH
    UIGraphicsBeginImageContextWithOptions(size, opaque, scale);
#else
    CGContextRef context = EaseCGContextCreateBitmapContext(size, opaque, scale);
    if (!context) {
        return;
    }
    NSGraphicsContext *graphicsContext = [NSGraphicsContext graphicsContextWithCGContext:context flipped:NO];
    objc_setAssociatedObject(graphicsContext, &kNSGraphicsContextScaleFactorKey, @(scale), OBJC_ASSOCIATION_RETAIN);
    CGContextRelease(context);
    [NSGraphicsContext saveGraphicsState];
    NSGraphicsContext.currentContext = graphicsContext;
#endif
}

void EaseGraphicsEndImageContext(void) {
#if Ease_UIKIT || Ease_WATCH
    UIGraphicsEndImageContext();
#else
    [NSGraphicsContext restoreGraphicsState];
#endif
}

UIImage * EaseGraphicsGetImageFromCurrentImageContext(void) {
#if Ease_UIKIT || Ease_WATCH
    return UIGraphicsGetImageFromCurrentImageContext();
#else
    NSGraphicsContext *context = NSGraphicsContext.currentContext;
    CGContextRef contextRef = context.CGContext;
    if (!contextRef) {
        return nil;
    }
    CGImageRef imageRef = CGBitmapContextCreateImage(contextRef);
    if (!imageRef) {
        return nil;
    }
    CGFloat scale = 0;
    NSNumber *scaleFactor = objc_getAssociatedObject(context, &kNSGraphicsContextScaleFactorKey);
    if ([scaleFactor isKindOfClass:[NSNumber class]]) {
        scale = scaleFactor.doubleValue;
    }
    if (!scale) {
        // reset to the scale factor of the device’s main screen if scale is 0.
        scale = [NSScreen mainScreen].backingScaleFactor;
    }
    NSImage *image = [[NSImage alloc] initWithCGImage:imageRef scale:scale orientation:kCGImagePropertyOrientationUp];
    CGImageRelease(imageRef);
    return image;
#endif
}
