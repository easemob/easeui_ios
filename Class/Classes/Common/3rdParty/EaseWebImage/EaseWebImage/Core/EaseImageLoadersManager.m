/*
 * This file is part of the EaseWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "EaseImageLoadersManager.h"
#import "EaseWebImageDownloader.h"
#import "EaseInternalMacros.h"

@interface EaseImageLoadersManager ()

@property (nonatomic, strong, nonnull) NSMutableArray<id<EaseImageLoader>> *imageLoaders;

@end

@implementation EaseImageLoadersManager {
    Ease_LOCK_DECLARE(_loadersLock);
}

+ (EaseImageLoadersManager *)sharedManager {
    static dispatch_once_t onceToken;
    static EaseImageLoadersManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[EaseImageLoadersManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // initialize with default image loaders
        _imageLoaders = [NSMutableArray arrayWithObject:[EaseWebImageDownloader sharedDownloader]];
        Ease_LOCK_INIT(_loadersLock);
    }
    return self;
}

- (NSArray<id<EaseImageLoader>> *)loaders {
    Ease_LOCK(_loadersLock);
    NSArray<id<EaseImageLoader>>* loaders = [_imageLoaders copy];
    Ease_UNLOCK(_loadersLock);
    return loaders;
}

- (void)setLoaders:(NSArray<id<EaseImageLoader>> *)loaders {
    Ease_LOCK(_loadersLock);
    [_imageLoaders removeAllObjects];
    if (loaders.count) {
        [_imageLoaders addObjectsFromArray:loaders];
    }
    Ease_UNLOCK(_loadersLock);
}

#pragma mark - Loader Property

- (void)addLoader:(id<EaseImageLoader>)loader {
    if (![loader conformsToProtocol:@protocol(EaseImageLoader)]) {
        return;
    }
    Ease_LOCK(_loadersLock);
    [_imageLoaders addObject:loader];
    Ease_UNLOCK(_loadersLock);
}

- (void)removeLoader:(id<EaseImageLoader>)loader {
    if (![loader conformsToProtocol:@protocol(EaseImageLoader)]) {
        return;
    }
    Ease_LOCK(_loadersLock);
    [_imageLoaders removeObject:loader];
    Ease_UNLOCK(_loadersLock);
}

#pragma mark - EaseImageLoader

- (BOOL)canRequestImageForURL:(nullable NSURL *)url {
    NSArray<id<EaseImageLoader>> *loaders = self.loaders;
    for (id<EaseImageLoader> loader in loaders.reverseObjectEnumerator) {
        if ([loader canRequestImageForURL:url]) {
            return YES;
        }
    }
    return NO;
}

- (id<EaseWebImageOperation>)requestImageWithURL:(NSURL *)url options:(EaseWebImageOptions)options context:(EaseWebImageContext *)context progress:(EaseImageLoaderProgressBlock)progressBlock completed:(EaseImageLoaderCompletedBlock)completedBlock {
    if (!url) {
        return nil;
    }
    NSArray<id<EaseImageLoader>> *loaders = self.loaders;
    for (id<EaseImageLoader> loader in loaders.reverseObjectEnumerator) {
        if ([loader canRequestImageForURL:url]) {
            return [loader requestImageWithURL:url options:options context:context progress:progressBlock completed:completedBlock];
        }
    }
    return nil;
}

- (BOOL)shouldBlockFailedURLWithURL:(NSURL *)url error:(NSError *)error {
    NSArray<id<EaseImageLoader>> *loaders = self.loaders;
    for (id<EaseImageLoader> loader in loaders.reverseObjectEnumerator) {
        if ([loader canRequestImageForURL:url]) {
            return [loader shouldBlockFailedURLWithURL:url error:error];
        }
    }
    return NO;
}

@end
