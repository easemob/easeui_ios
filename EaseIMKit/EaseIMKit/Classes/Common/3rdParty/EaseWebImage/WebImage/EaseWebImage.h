/*
 * This file is part of the EaseWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 * (c) Florent Vilmart
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "EaseWebImageCompat.h"

//! Project version number for EaseWebImage.
FOUNDATION_EXPORT double EaseWebImageVersionNumber;

//! Project version string for EaseWebImage.
FOUNDATION_EXPORT const unsigned char EaseWebImageVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import "PublicHeader.h"

#import "EaseWebImageManager.h"
#import "EaseWebImageCacheKeyFilter.h"
#import "EaseWebImageCacheSerializer.h"
#import "EaseImageCacheConfig.h"
#import "EaseImageCache.h"
#import "EaseMemoryCache.h"
#import "EaseDiskCache.h"
#import "EaseImageCacheDefine.h"
#import "EaseImageCachesManager.h"
#import "UIView+EaseWebCache.h"
#import "UIImageView+EaseWebCache.h"
#import "UIImageView+EaseHighlightedWebCache.h"
#import "EaseWebImageDownloaderConfig.h"
#import "EaseWebImageDownloaderOperation.h"
#import "EaseWebImageDownloaderRequestModifier.h"
#import "EaseWebImageDownloaderResponseModifier.h"
#import "EaseWebImageDownloaderDecryptor.h"
#import "EaseImageLoader.h"
#import "EaseImageLoadersManager.h"
#import "UIButton+EaseWebCache.h"
#import "EaseWebImagePrefetcher.h"
#import "UIView+EaseWebCacheOperation.h"
#import "UIImage+EaseMetadata.h"
#import "UIImage+EaseMultiFormat.h"
#import "UIImage+EaseMemoryCacheCost.h"
#import "UIImage+EaseExtendedCacheData.h"
#import "EaseWebImageOperation.h"
#import "EaseWebImageDownloader.h"
#import "EaseWebImageTransition.h"
#import "EaseWebImageIndicator.h"
#import "EaseImageTransformer.h"
#import "UIImage+EaseTransform.h"
#import "EaseAnimatedImage.h"
#import "EaseAnimatedImageView.h"
#import "EaseAnimatedImageView+WebCache.h"
#import "EaseAnimatedImagePlayer.h"
#import "EaseImageCodersManager.h"
#import "EaseImageCoder.h"
#import "EaseImageAPNGCoder.h"
#import "EaseImageGIFCoder.h"
#import "EaseImageIOCoder.h"
#import "EaseImageFrame.h"
#import "EaseImageCoderHelper.h"
#import "EaseImageGraphics.h"
#import "EaseGraphicsImageRenderer.h"
#import "UIImage+EaseGIF.h"
#import "UIImage+EaseForceDecode.h"
#import "NSData+EaseImageContentType.h"
#import "EaseWebImageDefine.h"
#import "EaseWebImageError.h"
#import "EaseWebImageOptionsProcessor.h"
#import "EaseImageIOAnimatedCoder.h"
#import "EaseImageHEICCoder.h"
#import "EaseImageAWebPCoder.h"

// Mac
#if __has_include("NSImage+EaseCompatibility.h")
#import "NSImage+EaseCompatibility.h"
#endif
#if __has_include("NSButton+EaseWebCache.h")
#import "NSButton+EaseWebCache.h"
#endif
#if __has_include("EaseAnimatedImageRep.h")
#import "EaseAnimatedImageRep.h"
#endif

// MapKit
#if __has_include("MKAnnotationView+WebCache.h")
#import "MKAnnotationView+WebCache.h"
#endif
