/*
 * This file is part of the EaseWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "EaseImageCacheDefine.h"
#import "EaseImageCodersManager.h"
#import "EaseImageCoderHelper.h"
#import "EaseAnimatedImage.h"
#import "UIImage+EaseMetadata.h"
#import "EaseInternalMacros.h"

UIImage * _Nullable EaseImageCacheDecodeImageData(NSData * _Nonnull imageData, NSString * _Nonnull cacheKey, EaseWebImageOptions options, EaseWebImageContext * _Nullable context) {
    UIImage *image;
    BOOL decodeFirstFrame = Ease_OPTIONS_CONTAINS(options, EaseWebImageDecodeFirstFrameOnly);
    NSNumber *scaleValue = context[EaseWebImageContextImageScaleFactor];
    CGFloat scale = scaleValue.doubleValue >= 1 ? scaleValue.doubleValue : EaseImageScaleFactorForKey(cacheKey);
    NSNumber *preserveAspectRatioValue = context[EaseWebImageContextImagePreserveAspectRatio];
    NSValue *thumbnailSizeValue;
    BOOL shouldScaleDown = Ease_OPTIONS_CONTAINS(options, EaseWebImageScaleDownLargeImages);
    if (shouldScaleDown) {
        CGFloat thumbnailPixels = EaseImageCoderHelper.defaultScaleDownLimitBytes / 4;
        CGFloat dimension = ceil(sqrt(thumbnailPixels));
        thumbnailSizeValue = @(CGSizeMake(dimension, dimension));
    }
    if (context[EaseWebImageContextImageThumbnailPixelSize]) {
        thumbnailSizeValue = context[EaseWebImageContextImageThumbnailPixelSize];
    }
    
    EaseImageCoderMutableOptions *mutableCoderOptions = [NSMutableDictionary dictionaryWithCapacity:2];
    mutableCoderOptions[EaseImageCoderDecodeFirstFrameOnly] = @(decodeFirstFrame);
    mutableCoderOptions[EaseImageCoderDecodeScaleFactor] = @(scale);
    mutableCoderOptions[EaseImageCoderDecodePreserveAspectRatio] = preserveAspectRatioValue;
    mutableCoderOptions[EaseImageCoderDecodeThumbnailPixelSize] = thumbnailSizeValue;
    mutableCoderOptions[EaseImageCoderWebImageContext] = context;
    EaseImageCoderOptions *coderOptions = [mutableCoderOptions copy];
    
    // Grab the image coder
    id<EaseImageCoder> imageCoder;
    if ([context[EaseWebImageContextImageCoder] conformsToProtocol:@protocol(EaseImageCoder)]) {
        imageCoder = context[EaseWebImageContextImageCoder];
    } else {
        imageCoder = [EaseImageCodersManager sharedManager];
    }
    
    if (!decodeFirstFrame) {
        Class animatedImageClass = context[EaseWebImageContextAnimatedImageClass];
        // check whether we should use `EaseAnimatedImage`
        if ([animatedImageClass isSubclassOfClass:[UIImage class]] && [animatedImageClass conformsToProtocol:@protocol(EaseAnimatedImage)]) {
            image = [[animatedImageClass alloc] initWithData:imageData scale:scale options:coderOptions];
            if (image) {
                // Preload frames if supported
                if (options & EaseWebImagePreloadAllFrames && [image respondsToSelector:@selector(preloadAllFrames)]) {
                    [((id<EaseAnimatedImage>)image) preloadAllFrames];
                }
            } else {
                // Check image class matching
                if (options & EaseWebImageMatchAnimatedImageClass) {
                    return nil;
                }
            }
        }
    }
    if (!image) {
        image = [imageCoder decodedImageWithData:imageData options:coderOptions];
    }
    if (image) {
        BOOL shouldDecode = !Ease_OPTIONS_CONTAINS(options, EaseWebImageAvoidDecodeImage);
        if ([image.class conformsToProtocol:@protocol(EaseAnimatedImage)]) {
            // `EaseAnimatedImage` do not decode
            shouldDecode = NO;
        } else if (image.ease_isAnimated) {
            // animated image do not decode
            shouldDecode = NO;
        }
        if (shouldDecode) {
            image = [EaseImageCoderHelper decodedImageWithImage:image];
        }
    }
    
    return image;
}
