/*
 * This file is part of the EaseWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <Foundation/Foundation.h>
#import "EaseImageIOAnimatedCoder.h"

/**
 This coder is used for Google WebP and Animated WebP(AWebP) image format.
 Image/IO provide the WebP decoding support in iOS 14/macOS 11/tvOS 14/watchOS 7+.
 @note Currently Image/IO seems does not supports WebP encoding, if you need WebP encoding, use the custom codec below.
 @note If you need to support lower firmware version for WebP, you can have a try at https://github.com/EaseWebImage/EaseWebImageWebPCoder
 */
API_AVAILABLE(ios(14.0), tvos(14.0), macos(11.0), watchos(7.0))
@interface EaseImageAWebPCoder : EaseImageIOAnimatedCoder <EaseProgressiveImageCoder, EaseAnimatedImageCoder>

@property (nonatomic, class, readonly, nonnull) EaseImageAWebPCoder *sharedCoder;

@end
