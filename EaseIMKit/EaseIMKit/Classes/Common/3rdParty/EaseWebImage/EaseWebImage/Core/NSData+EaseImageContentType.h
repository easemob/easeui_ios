/*
 * This file is part of the EaseWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 * (c) Fabrice Aneche
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <Foundation/Foundation.h>
#import "EaseWebImageCompat.h"

/**
 You can use switch case like normal enum. It's also recommended to add a default case. You should not assume anything about the raw value.
 For custom coder plugin, it can also extern the enum for supported format. See `EaseImageCoder` for more detailed information.
 */
typedef NSInteger EaseImageFormat NS_TYPED_EXTENSIBLE_ENUM;
static const EaseImageFormat EaseImageFormatUndefined = -1;
static const EaseImageFormat EaseImageFormatJPEG      = 0;
static const EaseImageFormat EaseImageFormatPNG       = 1;
static const EaseImageFormat EaseImageFormatGIF       = 2;
static const EaseImageFormat EaseImageFormatTIFF      = 3;
static const EaseImageFormat EaseImageFormatWebP      = 4;
static const EaseImageFormat EaseImageFormatHEIC      = 5;
static const EaseImageFormat EaseImageFormatHEIF      = 6;
static const EaseImageFormat EaseImageFormatPDF       = 7;
static const EaseImageFormat EaseImageFormatSVG       = 8;

/**
 NSData category about the image content type and UTI.
 */
@interface NSData (EaseImageContentType)

/**
 *  Return image format
 *
 *  @param data the input image data
 *
 *  @return the image format as `EaseImageFormat` (enum)
 */
+ (EaseImageFormat)Ease_imageFormatForImageData:(nullable NSData *)data;

/**
 *  Convert EaseImageFormat to UTType
 *
 *  @param format Format as EaseImageFormat
 *  @return The UTType as CFStringRef
 *  @note For unknown format, `kUTTypeImage` abstract type will return
 */
+ (nonnull CFStringRef)Ease_UTTypeFromImageFormat:(EaseImageFormat)format CF_RETURNS_NOT_RETAINED NS_SWIFT_NAME(Ease_UTType(from:));

/**
 *  Convert UTType to EaseImageFormat
 *
 *  @param uttype The UTType as CFStringRef
 *  @return The Format as EaseImageFormat
 *  @note For unknown type, `EaseImageFormatUndefined` will return
 */
+ (EaseImageFormat)Ease_imageFormatFromUTType:(nonnull CFStringRef)uttype;

@end
