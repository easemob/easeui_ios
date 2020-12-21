/*
 * This file is part of the EaseWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "EaseImageLoader.h"
#import "EaseWebImageCacheKeyFilter.h"
#import "EaseImageCodersManager.h"
#import "EaseImageCoderHelper.h"
#import "EaseAnimatedImage.h"
#import "UIImage+EaseMetadata.h"
#import "EaseInternalMacros.h"
#import "objc/runtime.h"

static void * EaseImageLoaderProgressiveCoderKey = &EaseImageLoaderProgressiveCoderKey;

UIImage * _Nullable EaseImageLoaderDecodeImageData(NSData * _Nonnull imageData, NSURL * _Nonnull imageURL, EaseWebImageOptions options, EaseWebImageContext * _Nullable context) {
    NSCParameterAssert(imageData);
    NSCParameterAssert(imageURL);
    
    UIImage *image;
    id<EaseWebImageCacheKeyFilter> cacheKeyFilter = context[EaseWebImageContextCacheKeyFilter];
    NSString *cacheKey;
    if (cacheKeyFilter) {
        cacheKey = [cacheKeyFilter cacheKeyForURL:imageURL];
    } else {
        cacheKey = imageURL.absoluteString;
    }
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
        // check whether we should use `EaseAnimatedImage`
        Class animatedImageClass = context[EaseWebImageContextAnimatedImageClass];
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

UIImage * _Nullable EaseImageLoaderDecodeProgressiveImageData(NSData * _Nonnull imageData, NSURL * _Nonnull imageURL, BOOL finished,  id<EaseWebImageOperation> _Nonnull operation, EaseWebImageOptions options, EaseWebImageContext * _Nullable context) {
    NSCParameterAssert(imageData);
    NSCParameterAssert(imageURL);
    NSCParameterAssert(operation);
    
    UIImage *image;
    id<EaseWebImageCacheKeyFilter> cacheKeyFilter = context[EaseWebImageContextCacheKeyFilter];
    NSString *cacheKey;
    if (cacheKeyFilter) {
        cacheKey = [cacheKeyFilter cacheKeyForURL:imageURL];
    } else {
        cacheKey = imageURL.absoluteString;
    }
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
    
    // Grab the progressive image coder
    id<EaseProgressiveImageCoder> progressiveCoder = objc_getAssociatedObject(operation, EaseImageLoaderProgressiveCoderKey);
    if (!progressiveCoder) {
        id<EaseProgressiveImageCoder> imageCoder = context[EaseWebImageContextImageCoder];
        // Check the progressive coder if provided
        if ([imageCoder conformsToProtocol:@protocol(EaseProgressiveImageCoder)]) {
            progressiveCoder = [[[imageCoder class] alloc] initIncrementalWithOptions:coderOptions];
        } else {
            // We need to create a new instance for progressive decoding to avoid conflicts
            for (id<EaseImageCoder> coder in [EaseImageCodersManager sharedManager].coders.reverseObjectEnumerator) {
                if ([coder conformsToProtocol:@protocol(EaseProgressiveImageCoder)] &&
                    [((id<EaseProgressiveImageCoder>)coder) canIncrementalDecodeFromData:imageData]) {
                    progressiveCoder = [[[coder class] alloc] initIncrementalWithOptions:coderOptions];
                    break;
                }
            }
        }
        objc_setAssociatedObject(operation, EaseImageLoaderProgressiveCoderKey, progressiveCoder, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    // If we can't find any progressive coder, disable progressive download
    if (!progressiveCoder) {
        return nil;
    }
    
    [progressiveCoder updateIncrementalData:imageData finished:finished];
    if (!decodeFirstFrame) {
        // check whether we should use `EaseAnimatedImage`
        Class animatedImageClass = context[EaseWebImageContextAnimatedImageClass];
        if ([animatedImageClass isSubclassOfClass:[UIImage class]] && [animatedImageClass conformsToProtocol:@protocol(EaseAnimatedImage)] && [progressiveCoder conformsToProtocol:@protocol(EaseAnimatedImageCoder)]) {
            image = [[animatedImageClass alloc] initWithAnimatedCoder:(id<EaseAnimatedImageCoder>)progressiveCoder scale:scale];
            if (image) {
                // Progressive decoding does not preload frames
            } else {
                // Check image class matching
                if (options & EaseWebImageMatchAnimatedImageClass) {
                    return nil;
                }
            }
        }
    }
    if (!image) {
        image = [progressiveCoder incrementalDecodedImageWithOptions:coderOptions];
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
        // mark the image as progressive (completionBlock one are not mark as progressive)
        image.ease_isIncremental = YES;
    }
    
    return image;
}

EaseWebImageContextOption const EaseWebImageContextLoaderCachedImage = @"loaderCachedImage";
