/*
 * This file is part of the EaseWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "EaseImageCacheConfig.h"
#import "EaseMemoryCache.h"
#import "EaseDiskCache.h"

static EaseImageCacheConfig *_defaultCacheConfig;
static const NSInteger kDefaultCacheMaxDiskAge = 60 * 60 * 24 * 7; // 1 week

@implementation EaseImageCacheConfig

+ (EaseImageCacheConfig *)defaultCacheConfig {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultCacheConfig = [EaseImageCacheConfig new];
    });
    return _defaultCacheConfig;
}

- (instancetype)init {
    if (self = [super init]) {
        _shouldDisableiCloud = YES;
        _shouldCacheImagesInMemory = YES;
        _shouldUseWeakMemoryCache = YES;
        _shouldRemoveExpiredDataWhenEnterBackground = YES;
        _diskCacheReadingOptions = 0;
        _diskCacheWritingOptions = NSDataWritingAtomic;
        _maxDiskAge = kDefaultCacheMaxDiskAge;
        _maxDiskSize = 0;
        _diskCacheExpireType = EaseImageCacheConfigExpireTypeModificationDate;
        _memoryCacheClass = [EaseMemoryCache class];
        _diskCacheClass = [EaseDiskCache class];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    EaseImageCacheConfig *config = [[[self class] allocWithZone:zone] init];
    config.shouldDisableiCloud = self.shouldDisableiCloud;
    config.shouldCacheImagesInMemory = self.shouldCacheImagesInMemory;
    config.shouldUseWeakMemoryCache = self.shouldUseWeakMemoryCache;
    config.shouldRemoveExpiredDataWhenEnterBackground = self.shouldRemoveExpiredDataWhenEnterBackground;
    config.diskCacheReadingOptions = self.diskCacheReadingOptions;
    config.diskCacheWritingOptions = self.diskCacheWritingOptions;
    config.maxDiskAge = self.maxDiskAge;
    config.maxDiskSize = self.maxDiskSize;
    config.maxMemoryCost = self.maxMemoryCost;
    config.maxMemoryCount = self.maxMemoryCount;
    config.diskCacheExpireType = self.diskCacheExpireType;
    config.fileManager = self.fileManager; // NSFileManager does not conform to NSCopying, just pass the reference
    config.memoryCacheClass = self.memoryCacheClass;
    config.diskCacheClass = self.diskCacheClass;
    
    return config;
}

@end
