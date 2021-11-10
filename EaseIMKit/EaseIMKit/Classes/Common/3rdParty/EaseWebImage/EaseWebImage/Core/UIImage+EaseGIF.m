/*
 * This file is part of the EaseWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 * (c) Laurin Brandner
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImage+EaseGIF.h"
#import "EaseImageGIFCoder.h"

@implementation UIImage (EaseGIF)

+ (nullable UIImage *)Ease_imageWithGIFData:(nullable NSData *)data {
    if (!data) {
        return nil;
    }
    return [[EaseImageGIFCoder sharedCoder] decodedImageWithData:data options:0];
}

@end
