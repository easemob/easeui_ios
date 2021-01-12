/*
 * This file is part of the EaseWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "EaseWebImageDefine.h"
#import "UIImage+EaseMetadata.h"
#import "NSImage+EaseCompatibility.h"
#import "EaseAssociatedObject.h"

#pragma mark - Image scale

static inline NSArray<NSNumber *> * _Nonnull EaseImageScaleFactors() {
    return @[@2, @3];
}

inline CGFloat EaseImageScaleFactorForKey(NSString * _Nullable key) {
    CGFloat scale = 1;
    if (!key) {
        return scale;
    }
    // Check if target OS support scale
#if Ease_WATCH
    if ([[WKInterfaceDevice currentDevice] respondsToSelector:@selector(screenScale)])
#elif Ease_UIKIT
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
#elif Ease_MAC
    if ([[NSScreen mainScreen] respondsToSelector:@selector(backingScaleFactor)])
#endif
    {
        // a@2x.png -> 8
        if (key.length >= 8) {
            // Fast check
            BOOL isURL = [key hasPrefix:@"http://"] || [key hasPrefix:@"https://"];
            for (NSNumber *scaleFactor in EaseImageScaleFactors()) {
                // @2x. for file name and normal url
                NSString *fileScale = [NSString stringWithFormat:@"@%@x.", scaleFactor];
                if ([key containsString:fileScale]) {
                    scale = scaleFactor.doubleValue;
                    return scale;
                }
                if (isURL) {
                    // %402x. for url encode
                    NSString *urlScale = [NSString stringWithFormat:@"%%40%@x.", scaleFactor];
                    if ([key containsString:urlScale]) {
                        scale = scaleFactor.doubleValue;
                        return scale;
                    }
                }
            }
        }
    }
    return scale;
}

inline UIImage * _Nullable EaseScaledImageForKey(NSString * _Nullable key, UIImage * _Nullable image) {
    if (!image) {
        return nil;
    }
    CGFloat scale = EaseImageScaleFactorForKey(key);
    return EaseScaledImageForScaleFactor(scale, image);
}

inline UIImage * _Nullable EaseScaledImageForScaleFactor(CGFloat scale, UIImage * _Nullable image) {
    if (!image) {
        return nil;
    }
    if (scale <= 1) {
        return image;
    }
    if (scale == image.scale) {
        return image;
    }
    UIImage *scaledImage;
    if (image.ease_isAnimated) {
        UIImage *animatedImage;
#if Ease_UIKIT || Ease_WATCH
        // `UIAnimatedImage` images share the same size and scale.
        NSMutableArray<UIImage *> *scaledImages = [NSMutableArray array];
        
        for (UIImage *tempImage in image.images) {
            UIImage *tempScaledImage = [[UIImage alloc] initWithCGImage:tempImage.CGImage scale:scale orientation:tempImage.imageOrientation];
            [scaledImages addObject:tempScaledImage];
        }
        
        animatedImage = [UIImage animatedImageWithImages:scaledImages duration:image.duration];
        animatedImage.ease_imageLoopCount = image.ease_imageLoopCount;
#else
        // Animated GIF for `NSImage` need to grab `NSBitmapImageRep`;
        NSRect imageRect = NSMakeRect(0, 0, image.size.width, image.size.height);
        NSImageRep *imageRep = [image bestRepresentationForRect:imageRect context:nil hints:nil];
        NSBitmapImageRep *bitmapImageRep;
        if ([imageRep isKindOfClass:[NSBitmapImageRep class]]) {
            bitmapImageRep = (NSBitmapImageRep *)imageRep;
        }
        if (bitmapImageRep) {
            NSSize size = NSMakeSize(image.size.width / scale, image.size.height / scale);
            animatedImage = [[NSImage alloc] initWithSize:size];
            bitmapImageRep.size = size;
            [animatedImage addRepresentation:bitmapImageRep];
        }
#endif
        scaledImage = animatedImage;
    } else {
#if Ease_UIKIT || Ease_WATCH
        scaledImage = [[UIImage alloc] initWithCGImage:image.CGImage scale:scale orientation:image.imageOrientation];
#else
        scaledImage = [[UIImage alloc] initWithCGImage:image.CGImage scale:scale orientation:kCGImagePropertyOrientationUp];
#endif
    }
    EaseImageCopyAssociatedObject(image, scaledImage);
    
    return scaledImage;
}

#pragma mark - Context option

EaseWebImageContextOption const EaseWebImageContextSetImageOperationKey = @"setImageOperationKey";
EaseWebImageContextOption const EaseWebImageContextCustomManager = @"customManager";
EaseWebImageContextOption const EaseWebImageContextImageCache = @"imageCache";
EaseWebImageContextOption const EaseWebImageContextImageLoader = @"imageLoader";
EaseWebImageContextOption const EaseWebImageContextImageCoder = @"imageCoder";
EaseWebImageContextOption const EaseWebImageContextImageTransformer = @"imageTransformer";
EaseWebImageContextOption const EaseWebImageContextImageScaleFactor = @"imageScaleFactor";
EaseWebImageContextOption const EaseWebImageContextImagePreserveAspectRatio = @"imagePreserveAspectRatio";
EaseWebImageContextOption const EaseWebImageContextImageThumbnailPixelSize = @"imageThumbnailPixelSize";
EaseWebImageContextOption const EaseWebImageContextQueryCacheType = @"queryCacheType";
EaseWebImageContextOption const EaseWebImageContextStoreCacheType = @"storeCacheType";
EaseWebImageContextOption const EaseWebImageContextOriginalQueryCacheType = @"originalQueryCacheType";
EaseWebImageContextOption const EaseWebImageContextOriginalStoreCacheType = @"originalStoreCacheType";
EaseWebImageContextOption const EaseWebImageContextAnimatedImageClass = @"animatedImageClass";
EaseWebImageContextOption const EaseWebImageContextDownloadRequestModifier = @"downloadRequestModifier";
EaseWebImageContextOption const EaseWebImageContextDownloadResponseModifier = @"downloadResponseModifier";
EaseWebImageContextOption const EaseWebImageContextDownloadDecryptor = @"downloadDecryptor";
EaseWebImageContextOption const EaseWebImageContextCacheKeyFilter = @"cacheKeyFilter";
EaseWebImageContextOption const EaseWebImageContextCacheSerializer = @"cacheSerializer";
