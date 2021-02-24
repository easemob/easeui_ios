/*
 * This file is part of the EaseWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "EaseImageCodersManager.h"
#import "EaseImageIOCoder.h"
#import "EaseImageGIFCoder.h"
#import "EaseImageAPNGCoder.h"
#import "EaseImageHEICCoder.h"
#import "EaseInternalMacros.h"

@interface EaseImageCodersManager ()

@property (nonatomic, strong, nonnull) NSMutableArray<id<EaseImageCoder>> *imageCoders;

@end

@implementation EaseImageCodersManager {
    Ease_LOCK_DECLARE(_codersLock);
}

+ (nonnull instancetype)sharedManager {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        // initialize with default coders
        _imageCoders = [NSMutableArray arrayWithArray:@[[EaseImageIOCoder sharedCoder], [EaseImageGIFCoder sharedCoder], [EaseImageAPNGCoder sharedCoder]]];
        Ease_LOCK_INIT(_codersLock);
    }
    return self;
}

- (NSArray<id<EaseImageCoder>> *)coders
{
    Ease_LOCK(_codersLock);
    NSArray<id<EaseImageCoder>> *coders = [_imageCoders copy];
    Ease_UNLOCK(_codersLock);
    return coders;
}

- (void)setCoders:(NSArray<id<EaseImageCoder>> *)coders
{
    Ease_LOCK(_codersLock);
    [_imageCoders removeAllObjects];
    if (coders.count) {
        [_imageCoders addObjectsFromArray:coders];
    }
    Ease_UNLOCK(_codersLock);
}

#pragma mark - Coder IO operations

- (void)addCoder:(nonnull id<EaseImageCoder>)coder {
    if (![coder conformsToProtocol:@protocol(EaseImageCoder)]) {
        return;
    }
    Ease_LOCK(_codersLock);
    [_imageCoders addObject:coder];
    Ease_UNLOCK(_codersLock);
}

- (void)removeCoder:(nonnull id<EaseImageCoder>)coder {
    if (![coder conformsToProtocol:@protocol(EaseImageCoder)]) {
        return;
    }
    Ease_LOCK(_codersLock);
    [_imageCoders removeObject:coder];
    Ease_UNLOCK(_codersLock);
}

#pragma mark - EaseImageCoder
- (BOOL)canDecodeFromData:(NSData *)data {
    NSArray<id<EaseImageCoder>> *coders = self.coders;
    for (id<EaseImageCoder> coder in coders.reverseObjectEnumerator) {
        if ([coder canDecodeFromData:data]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)canEncodeToFormat:(EaseImageFormat)format {
    NSArray<id<EaseImageCoder>> *coders = self.coders;
    for (id<EaseImageCoder> coder in coders.reverseObjectEnumerator) {
        if ([coder canEncodeToFormat:format]) {
            return YES;
        }
    }
    return NO;
}

- (UIImage *)decodedImageWithData:(NSData *)data options:(nullable EaseImageCoderOptions *)options {
    if (!data) {
        return nil;
    }
    UIImage *image;
    NSArray<id<EaseImageCoder>> *coders = self.coders;
    for (id<EaseImageCoder> coder in coders.reverseObjectEnumerator) {
        if ([coder canDecodeFromData:data]) {
            image = [coder decodedImageWithData:data options:options];
            break;
        }
    }
    
    return image;
}

- (NSData *)encodedDataWithImage:(UIImage *)image format:(EaseImageFormat)format options:(nullable EaseImageCoderOptions *)options {
    if (!image) {
        return nil;
    }
    NSArray<id<EaseImageCoder>> *coders = self.coders;
    for (id<EaseImageCoder> coder in coders.reverseObjectEnumerator) {
        if ([coder canEncodeToFormat:format]) {
            return [coder encodedDataWithImage:image format:format options:options];
        }
    }
    return nil;
}

@end
