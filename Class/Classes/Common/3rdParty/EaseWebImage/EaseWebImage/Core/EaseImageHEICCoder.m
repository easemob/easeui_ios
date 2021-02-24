/*
* This file is part of the EaseWebImage package.
* (c) Olivier Poitrey <rs@dailymotion.com>
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/

#import "EaseImageHEICCoder.h"
#import "EaseImageIOAnimatedCoderInternal.h"

// These constants are available from iOS 13+ and Xcode 11. This raw value is used for toolchain and firmware compatibility
static NSString * kSDCGImagePropertyHEICSDictionary = @"{HEICS}";
static NSString * kSDCGImagePropertyHEICSLoopCount = @"LoopCount";
static NSString * kSDCGImagePropertyHEICSDelayTime = @"DelayTime";
static NSString * kSDCGImagePropertyHEICSUnclampedDelayTime = @"UnclampedDelayTime";

@implementation EaseImageHEICCoder

+ (void)initialize {
    if (@available(iOS 13, tvOS 13, macOS 10.15, watchOS 6, *)) {
        // Use EaseK instead of raw value
        kSDCGImagePropertyHEICSDictionary = (__bridge NSString *)kCGImagePropertyHEICSDictionary;
        kSDCGImagePropertyHEICSLoopCount = (__bridge NSString *)kCGImagePropertyHEICSLoopCount;
        kSDCGImagePropertyHEICSDelayTime = (__bridge NSString *)kCGImagePropertyHEICSDelayTime;
        kSDCGImagePropertyHEICSUnclampedDelayTime = (__bridge NSString *)kCGImagePropertyHEICSUnclampedDelayTime;
    }
}

+ (instancetype)sharedCoder {
    static EaseImageHEICCoder *coder;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        coder = [[EaseImageHEICCoder alloc] init];
    });
    return coder;
}

#pragma mark - EaseImageCoder

- (BOOL)canDecodeFromData:(nullable NSData *)data {
    switch ([NSData Ease_imageFormatForImageData:data]) {
        case EaseImageFormatHEIC:
            // Check HEIC decoding compatibility
            return [self.class canDecodeFromFormat:EaseImageFormatHEIC];
        case EaseImageFormatHEIF:
            // Check HEIF decoding compatibility
            return [self.class canDecodeFromFormat:EaseImageFormatHEIF];
        default:
            return NO;
    }
}

- (BOOL)canIncrementalDecodeFromData:(NSData *)data {
    return [self canDecodeFromData:data];
}

- (BOOL)canEncodeToFormat:(EaseImageFormat)format {
    switch (format) {
        case EaseImageFormatHEIC:
            // Check HEIC encoding compatibility
            return [self.class canEncodeToFormat:EaseImageFormatHEIC];
        case EaseImageFormatHEIF:
            // Check HEIF encoding compatibility
            return [self.class canEncodeToFormat:EaseImageFormatHEIF];
        default:
            return NO;
    }
}

#pragma mark - Subclass Override

+ (EaseImageFormat)imageFormat {
    return EaseImageFormatHEIC;
}

+ (NSString *)imageUTType {
    return (__bridge NSString *)kSDUTTypeHEIC;
}

+ (NSString *)dictionaryProperty {
    return kSDCGImagePropertyHEICSDictionary;
}

+ (NSString *)unclampedDelayTimeProperty {
    return kSDCGImagePropertyHEICSUnclampedDelayTime;
}

+ (NSString *)delayTimeProperty {
    return kSDCGImagePropertyHEICSDelayTime;
}

+ (NSString *)loopCountProperty {
    return kSDCGImagePropertyHEICSLoopCount;
}

+ (NSUInteger)defaultLoopCount {
    return 0;
}

@end
