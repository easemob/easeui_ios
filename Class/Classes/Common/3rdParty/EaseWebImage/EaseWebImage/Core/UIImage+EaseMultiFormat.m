/*
 * This file is part of the EaseWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImage+EaseMultiFormat.h"
#import "EaseImageCodersManager.h"

@implementation UIImage (EaseMultiFormat)

+ (nullable UIImage *)Ease_imageWithData:(nullable NSData *)data {
    return [self Ease_imageWithData:data scale:1];
}

+ (nullable UIImage *)Ease_imageWithData:(nullable NSData *)data scale:(CGFloat)scale {
    return [self Ease_imageWithData:data scale:scale firstFrameOnly:NO];
}

+ (nullable UIImage *)Ease_imageWithData:(nullable NSData *)data scale:(CGFloat)scale firstFrameOnly:(BOOL)firstFrameOnly {
    if (!data) {
        return nil;
    }
    EaseImageCoderOptions *options = @{EaseImageCoderDecodeScaleFactor : @(MAX(scale, 1)), EaseImageCoderDecodeFirstFrameOnly : @(firstFrameOnly)};
    return [[EaseImageCodersManager sharedManager] decodedImageWithData:data options:options];
}

- (nullable NSData *)Ease_imageData {
    return [self Ease_imageDataAsFormat:EaseImageFormatUndefined];
}

- (nullable NSData *)Ease_imageDataAsFormat:(EaseImageFormat)imageFormat {
    return [self Ease_imageDataAsFormat:imageFormat compressionQuality:1];
}

- (nullable NSData *)Ease_imageDataAsFormat:(EaseImageFormat)imageFormat compressionQuality:(double)compressionQuality {
    return [self Ease_imageDataAsFormat:imageFormat compressionQuality:compressionQuality firstFrameOnly:NO];
}

- (nullable NSData *)Ease_imageDataAsFormat:(EaseImageFormat)imageFormat compressionQuality:(double)compressionQuality firstFrameOnly:(BOOL)firstFrameOnly {
    EaseImageCoderOptions *options = @{EaseImageCoderEncodeCompressionQuality : @(compressionQuality), EaseImageCoderEncodeFirstFrameOnly : @(firstFrameOnly)};
    return [[EaseImageCodersManager sharedManager] encodedDataWithImage:self format:imageFormat options:options];
}

@end
