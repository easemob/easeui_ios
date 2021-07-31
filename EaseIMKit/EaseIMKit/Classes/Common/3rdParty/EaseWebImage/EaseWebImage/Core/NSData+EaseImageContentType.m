/*
 * This file is part of the EaseWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 * (c) Fabrice Aneche
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "NSData+EaseImageContentType.h"
#if Ease_MAC
#import <CoreServices/CoreServices.h>
#else
#import <MobileCoreServices/MobileCoreServices.h>
#endif
#import "EaseImageIOAnimatedCoderInternal.h"

#define kSVGTagEnd @"</svg>"

@implementation NSData (EaseImageContentType)

+ (EaseImageFormat)Ease_imageFormatForImageData:(nullable NSData *)data {
    if (!data) {
        return EaseImageFormatUndefined;
    }
    
    // File signatures table: http://www.garykessler.net/library/file_sigs.html
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return EaseImageFormatJPEG;
        case 0x89:
            return EaseImageFormatPNG;
        case 0x47:
            return EaseImageFormatGIF;
        case 0x49:
        case 0x4D:
            return EaseImageFormatTIFF;
        case 0x52: {
            if (data.length >= 12) {
                //RIFF....WEBP
                NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
                if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) {
                    return EaseImageFormatWebP;
                }
            }
            break;
        }
        case 0x00: {
            if (data.length >= 12) {
                //....ftypheic ....ftypheix ....ftyphevc ....ftyphevx
                NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(4, 8)] encoding:NSASCIIStringEncoding];
                if ([testString isEqualToString:@"ftypheic"]
                    || [testString isEqualToString:@"ftypheix"]
                    || [testString isEqualToString:@"ftyphevc"]
                    || [testString isEqualToString:@"ftyphevx"]) {
                    return EaseImageFormatHEIC;
                }
                //....ftypmif1 ....ftypmsf1
                if ([testString isEqualToString:@"ftypmif1"] || [testString isEqualToString:@"ftypmsf1"]) {
                    return EaseImageFormatHEIF;
                }
            }
            break;
        }
        case 0x25: {
            if (data.length >= 4) {
                //%PDF
                NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(1, 3)] encoding:NSASCIIStringEncoding];
                if ([testString isEqualToString:@"PDF"]) {
                    return EaseImageFormatPDF;
                }
            }
        }
        case 0x3C: {
            // Check end with SVG tag
            if ([data rangeOfData:[kSVGTagEnd dataUsingEncoding:NSUTF8StringEncoding] options:NSDataSearchBackwards range: NSMakeRange(data.length - MIN(100, data.length), MIN(100, data.length))].location != NSNotFound) {
                return EaseImageFormatSVG;
            }
        }
    }
    return EaseImageFormatUndefined;
}

+ (nonnull CFStringRef)Ease_UTTypeFromImageFormat:(EaseImageFormat)format {
    CFStringRef UTType;
    switch (format) {
        case EaseImageFormatJPEG:
            UTType = kUTTypeJPEG;
            break;
        case EaseImageFormatPNG:
            UTType = kUTTypePNG;
            break;
        case EaseImageFormatGIF:
            UTType = kUTTypeGIF;
            break;
        case EaseImageFormatTIFF:
            UTType = kUTTypeTIFF;
            break;
        case EaseImageFormatWebP:
            UTType = kSDUTTypeWebP;
            break;
        case EaseImageFormatHEIC:
            UTType = kSDUTTypeHEIC;
            break;
        case EaseImageFormatHEIF:
            UTType = kSDUTTypeHEIF;
            break;
        case EaseImageFormatPDF:
            UTType = kUTTypePDF;
            break;
        case EaseImageFormatSVG:
            UTType = kUTTypeScalableVectorGraphics;
            break;
        default:
            // default is kUTTypeImage abstract type
            UTType = kUTTypeImage;
            break;
    }
    return UTType;
}

+ (EaseImageFormat)Ease_imageFormatFromUTType:(CFStringRef)uttype {
    if (!uttype) {
        return EaseImageFormatUndefined;
    }
    EaseImageFormat imageFormat;
    if (CFStringCompare(uttype, kUTTypeJPEG, 0) == kCFCompareEqualTo) {
        imageFormat = EaseImageFormatJPEG;
    } else if (CFStringCompare(uttype, kUTTypePNG, 0) == kCFCompareEqualTo) {
        imageFormat = EaseImageFormatPNG;
    } else if (CFStringCompare(uttype, kUTTypeGIF, 0) == kCFCompareEqualTo) {
        imageFormat = EaseImageFormatGIF;
    } else if (CFStringCompare(uttype, kUTTypeTIFF, 0) == kCFCompareEqualTo) {
        imageFormat = EaseImageFormatTIFF;
    } else if (CFStringCompare(uttype, kSDUTTypeWebP, 0) == kCFCompareEqualTo) {
        imageFormat = EaseImageFormatWebP;
    } else if (CFStringCompare(uttype, kSDUTTypeHEIC, 0) == kCFCompareEqualTo) {
        imageFormat = EaseImageFormatHEIC;
    } else if (CFStringCompare(uttype, kSDUTTypeHEIF, 0) == kCFCompareEqualTo) {
        imageFormat = EaseImageFormatHEIF;
    } else if (CFStringCompare(uttype, kUTTypePDF, 0) == kCFCompareEqualTo) {
        imageFormat = EaseImageFormatPDF;
    } else if (CFStringCompare(uttype, kUTTypeScalableVectorGraphics, 0) == kCFCompareEqualTo) {
        imageFormat = EaseImageFormatSVG;
    } else {
        imageFormat = EaseImageFormatUndefined;
    }
    return imageFormat;
}

@end
