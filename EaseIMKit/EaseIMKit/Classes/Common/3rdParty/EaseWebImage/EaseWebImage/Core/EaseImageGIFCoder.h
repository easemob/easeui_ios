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
 Built in coder using ImageIO that supports animated GIF encoding/decoding
 @note `EaseImageIOCoder` supports GIF but only as static (will use the 1st frame).
 @note Use `EaseImageGIFCoder` for fully animated GIFs. For `UIImageView`, it will produce animated `UIImage`(`NSImage` on macOS) for rendering. For `EaseAnimatedImageView`, it will use `EaseAnimatedImage` for rendering.
 @note The recommended approach for animated GIFs is using `EaseAnimatedImage` with `EaseAnimatedImageView`. It's more performant than `UIImageView` for GIF displaying(especially on memory usage)
 */
@interface EaseImageGIFCoder : EaseImageIOAnimatedCoder <EaseProgressiveImageCoder, EaseAnimatedImageCoder>

@property (nonatomic, class, readonly, nonnull) EaseImageGIFCoder *sharedCoder;

@end
