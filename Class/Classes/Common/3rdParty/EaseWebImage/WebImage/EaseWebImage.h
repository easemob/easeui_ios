/*
 * This file is part of the EaseWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 * (c) Florent Vilmart
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <EaseWebImage/EaseWebImageCompat.h>

//! Project version number for EaseWebImage.
FOUNDATION_EXPORT double EaseWebImageVersionNumber;

//! Project version string for EaseWebImage.
FOUNDATION_EXPORT const unsigned char EaseWebImageVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <EaseWebImage/PublicHeader.h>

#import <EaseWebImage/EaseWebImageManager.h>
#import <EaseWebImage/EaseWebImageCacheKeyFilter.h>
#import <EaseWebImage/EaseWebImageCacheSerializer.h>
#import <EaseWebImage/EaseImageCacheConfig.h>
#import <EaseWebImage/EaseImageCache.h>
#import <EaseWebImage/EaseMemoryCache.h>
#import <EaseWebImage/EaseDiskCache.h>
#import <EaseWebImage/EaseImageCacheDefine.h>
#import <EaseWebImage/EaseImageCachesManager.h>
#import <EaseWebImage/UIView+EaseWebCache.h>
#import <EaseWebImage/UIImageView+EaseWebCache.h>
#import <EaseWebImage/UIImageView+EaseHighlightedWebCache.h>
#import <EaseWebImage/EaseWebImageDownloaderConfig.h>
#import <EaseWebImage/EaseWebImageDownloaderOperation.h>
#import <EaseWebImage/EaseWebImageDownloaderRequestModifier.h>
#import <EaseWebImage/EaseWebImageDownloaderResponseModifier.h>
#import <EaseWebImage/EaseWebImageDownloaderDecryptor.h>
#import <EaseWebImage/EaseImageLoader.h>
#import <EaseWebImage/EaseImageLoadersManager.h>
#import <EaseWebImage/UIButton+EaseWebCache.h>
#import <EaseWebImage/EaseWebImagePrefetcher.h>
#import <EaseWebImage/UIView+EaseWebCacheOperation.h>
#import <EaseWebImage/UIImage+EaseMetadata.h>
#import <EaseWebImage/UIImage+EaseMultiFormat.h>
#import <EaseWebImage/UIImage+EaseMemoryCacheCost.h>
#import <EaseWebImage/UIImage+EaseExtendedCacheData.h>
#import <EaseWebImage/EaseWebImageOperation.h>
#import <EaseWebImage/EaseWebImageDownloader.h>
#import <EaseWebImage/EaseWebImageTransition.h>
#import <EaseWebImage/EaseWebImageIndicator.h>
#import <EaseWebImage/EaseImageTransformer.h>
#import <EaseWebImage/UIImage+EaseTransform.h>
#import <EaseWebImage/EaseAnimatedImage.h>
#import <EaseWebImage/EaseAnimatedImageView.h>
#import <EaseWebImage/EaseAnimatedImageView+WebCache.h>
#import <EaseWebImage/EaseAnimatedImagePlayer.h>
#import <EaseWebImage/EaseImageCodersManager.h>
#import <EaseWebImage/EaseImageCoder.h>
#import <EaseWebImage/EaseImageAPNGCoder.h>
#import <EaseWebImage/EaseImageGIFCoder.h>
#import <EaseWebImage/EaseImageIOCoder.h>
#import <EaseWebImage/EaseImageFrame.h>
#import <EaseWebImage/EaseImageCoderHelper.h>
#import <EaseWebImage/EaseImageGraphics.h>
#import <EaseWebImage/EaseGraphicsImageRenderer.h>
#import <EaseWebImage/UIImage+EaseGIF.h>
#import <EaseWebImage/UIImage+EaseForceDecode.h>
#import <EaseWebImage/NSData+EaseImageContentType.h>
#import <EaseWebImage/EaseWebImageDefine.h>
#import <EaseWebImage/EaseWebImageError.h>
#import <EaseWebImage/EaseWebImageOptionsProcessor.h>
#import <EaseWebImage/EaseImageIOAnimatedCoder.h>
#import <EaseWebImage/EaseImageHEICCoder.h>
#import <EaseWebImage/EaseImageAWebPCoder.h>

// Mac
#if __has_include(<EaseWebImage/NSImage+EaseCompatibility.h>)
#import <EaseWebImage/NSImage+EaseCompatibility.h>
#endif
#if __has_include(<EaseWebImage/NSButton+EaseWebCache.h>)
#import <EaseWebImage/NSButton+EaseWebCache.h>
#endif
#if __has_include(<EaseWebImage/EaseAnimatedImageRep.h>)
#import <EaseWebImage/EaseAnimatedImageRep.h>
#endif

// MapKit
#if __has_include(<EaseWebImage/MKAnnotationView+WebCache.h>)
#import <EaseWebImage/MKAnnotationView+WebCache.h>
#endif
