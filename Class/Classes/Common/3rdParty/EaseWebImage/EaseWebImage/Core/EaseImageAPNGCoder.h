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
 Built in coder using ImageIO that supports APNG encoding/decoding
 */
@interface EaseImageAPNGCoder : EaseImageIOAnimatedCoder <EaseProgressiveImageCoder, EaseAnimatedImageCoder>

@property (nonatomic, class, readonly, nonnull) EaseImageAPNGCoder *sharedCoder;

@end
