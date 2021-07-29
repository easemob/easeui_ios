/*
* This file is part of the EaseWebImage package.
* (c) Olivier Poitrey <rs@dailymotion.com>
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/

#import "EaseImageAWebPCoder.h"
#import "EaseImageIOAnimatedCoderInternal.h"

// These constants are available from iOS 14+ and Xcode 12. This raw value is used for toolchain and firmware compatibility
static NSString * kSDCGImagePropertyWebPDictionary = @"{WebP}";
static NSString * kSDCGImagePropertyWebPLoopCount = @"LoopCount";
static NSString * kSDCGImagePropertyWebPDelayTime = @"DelayTime";
static NSString * kSDCGImagePropertyWebPUnclampedDelayTime = @"UnclampedDelayTime";

@implementation EaseImageAWebPCoder

+ (void)initialize {
#if __IPHONE_14_0 || __TVOS_14_0 || __MAC_11_0 || __WATCHOS_7_0
    // Xcode 12
    if (@available(iOS 14, tvOS 14, macOS 11, watchOS 7, *)) {
        // Use EaseK instead of raw value
        kSDCGImagePropertyWebPDictionary = (__bridge NSString *)kCGImagePropertyWebPDictionary;
        kSDCGImagePropertyWebPLoopCount = (__bridge NSString *)kCGImagePropertyWebPLoopCount;
        kSDCGImagePropertyWebPDelayTime = (__bridge NSString *)kCGImagePropertyWebPDelayTime;
        kSDCGImagePropertyWebPUnclampedDelayTime = (__bridge NSString *)kCGImagePropertyWebPUnclampedDelayTime;
    }
#endif
}

+ (instancetype)sharedCoder {
    static EaseImageAWebPCoder *coder;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        coder = [[EaseImageAWebPCoder alloc] init];
    });
    return coder;
}

#pragma mark - EaseImageCoder

- (BOOL)canDecodeFromData:(nullable NSData *)data {
    switch ([NSData Ease_imageFormatForImageData:data]) {
        case EaseImageFormatWebP:
            // Check WebP decoding compatibility
            return [self.class canDecodeFromFormat:EaseImageFormatWebP];
        default:
            return NO;
    }
}

- (BOOL)canIncrementalDecodeFromData:(NSData *)data {
    return [self canDecodeFromData:data];
}

- (BOOL)canEncodeToFormat:(EaseImageFormat)format {
    switch (format) {
        case EaseImageFormatWebP:
            // Check WebP encoding compatibility
            return [self.class canEncodeToFormat:EaseImageFormatWebP];
        default:
            return NO;
    }
}

#pragma mark - Subclass Override

+ (EaseImageFormat)imageFormat {
    return EaseImageFormatWebP;
}

+ (NSString *)imageUTType {
    return (__bridge NSString *)kSDUTTypeWebP;
}

+ (NSString *)dictionaryProperty {
    return kSDCGImagePropertyWebPDictionary;
}

+ (NSString *)unclampedDelayTimeProperty {
    return kSDCGImagePropertyWebPUnclampedDelayTime;
}

+ (NSString *)delayTimeProperty {
    return kSDCGImagePropertyWebPDelayTime;
}

+ (NSString *)loopCountProperty {
    return kSDCGImagePropertyWebPLoopCount;
}

+ (NSUInteger)defaultLoopCount {
    return 0;
}

@end
