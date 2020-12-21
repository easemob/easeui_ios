/*
 * This file is part of the EaseWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "EaseImageCachesManager.h"
#import "EaseImageCachesManagerOperation.h"
#import "EaseImageCache.h"
#import "EaseInternalMacros.h"

@interface EaseImageCachesManager ()

@property (nonatomic, strong, nonnull) NSMutableArray<id<EaseImageCache>> *imageCaches;

@end

@implementation EaseImageCachesManager {
    Ease_LOCK_DECLARE(_cachesLock);
}

+ (EaseImageCachesManager *)sharedManager {
    static dispatch_once_t onceToken;
    static EaseImageCachesManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[EaseImageCachesManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.queryOperationPolicy = EaseImageCachesManagerOperationPolicySerial;
        self.storeOperationPolicy = EaseImageCachesManagerOperationPolicyHighestOnly;
        self.removeOperationPolicy = EaseImageCachesManagerOperationPolicyConcurrent;
        self.containsOperationPolicy = EaseImageCachesManagerOperationPolicySerial;
        self.clearOperationPolicy = EaseImageCachesManagerOperationPolicyConcurrent;
        // initialize with default image caches
        _imageCaches = [NSMutableArray arrayWithObject:[EaseImageCache sharedImageCache]];
        Ease_LOCK_INIT(_cachesLock);
    }
    return self;
}

- (NSArray<id<EaseImageCache>> *)caches {
    Ease_LOCK(_cachesLock);
    NSArray<id<EaseImageCache>> *caches = [_imageCaches copy];
    Ease_UNLOCK(_cachesLock);
    return caches;
}

- (void)setCaches:(NSArray<id<EaseImageCache>> *)caches {
    Ease_LOCK(_cachesLock);
    [_imageCaches removeAllObjects];
    if (caches.count) {
        [_imageCaches addObjectsFromArray:caches];
    }
    Ease_UNLOCK(_cachesLock);
}

#pragma mark - Cache IO operations

- (void)addCache:(id<EaseImageCache>)cache {
    if (![cache conformsToProtocol:@protocol(EaseImageCache)]) {
        return;
    }
    Ease_LOCK(_cachesLock);
    [_imageCaches addObject:cache];
    Ease_UNLOCK(_cachesLock);
}

- (void)removeCache:(id<EaseImageCache>)cache {
    if (![cache conformsToProtocol:@protocol(EaseImageCache)]) {
        return;
    }
    Ease_LOCK(_cachesLock);
    [_imageCaches removeObject:cache];
    Ease_UNLOCK(_cachesLock);
}

#pragma mark - EaseImageCache

- (id<EaseWebImageOperation>)queryImageForKey:(NSString *)key options:(EaseWebImageOptions)options context:(EaseWebImageContext *)context completion:(EaseImageCacheQueryCompletionBlock)completionBlock {
    return [self queryImageForKey:key options:options context:context cacheType:EaseImageCacheTypeAll completion:completionBlock];
}

- (id<EaseWebImageOperation>)queryImageForKey:(NSString *)key options:(EaseWebImageOptions)options context:(EaseWebImageContext *)context cacheType:(EaseImageCacheType)cacheType completion:(EaseImageCacheQueryCompletionBlock)completionBlock {
    if (!key) {
        return nil;
    }
    NSArray<id<EaseImageCache>> *caches = self.caches;
    NSUInteger count = caches.count;
    if (count == 0) {
        return nil;
    } else if (count == 1) {
        return [caches.firstObject queryImageForKey:key options:options context:context cacheType:cacheType completion:completionBlock];
    }
    switch (self.queryOperationPolicy) {
        case EaseImageCachesManagerOperationPolicyHighestOnly: {
            id<EaseImageCache> cache = caches.lastObject;
            return [cache queryImageForKey:key options:options context:context cacheType:cacheType completion:completionBlock];
        }
            break;
        case EaseImageCachesManagerOperationPolicyLowestOnly: {
            id<EaseImageCache> cache = caches.firstObject;
            return [cache queryImageForKey:key options:options context:context cacheType:cacheType completion:completionBlock];
        }
            break;
        case EaseImageCachesManagerOperationPolicyConcurrent: {
            EaseImageCachesManagerOperation *operation = [EaseImageCachesManagerOperation new];
            [operation beginWithTotalCount:caches.count];
            [self concurrentQueryImageForKey:key options:options context:context cacheType:cacheType completion:completionBlock enumerator:caches.reverseObjectEnumerator operation:operation];
            return operation;
        }
            break;
        case EaseImageCachesManagerOperationPolicySerial: {
            EaseImageCachesManagerOperation *operation = [EaseImageCachesManagerOperation new];
            [operation beginWithTotalCount:caches.count];
            [self serialQueryImageForKey:key options:options context:context cacheType:cacheType completion:completionBlock enumerator:caches.reverseObjectEnumerator operation:operation];
            return operation;
        }
            break;
        default:
            return nil;
            break;
    }
}

- (void)storeImage:(UIImage *)image imageData:(NSData *)imageData forKey:(NSString *)key cacheType:(EaseImageCacheType)cacheType completion:(EaseWebImageNoParamsBlock)completionBlock {
    if (!key) {
        return;
    }
    NSArray<id<EaseImageCache>> *caches = self.caches;
    NSUInteger count = caches.count;
    if (count == 0) {
        return;
    } else if (count == 1) {
        [caches.firstObject storeImage:image imageData:imageData forKey:key cacheType:cacheType completion:completionBlock];
        return;
    }
    switch (self.storeOperationPolicy) {
        case EaseImageCachesManagerOperationPolicyHighestOnly: {
            id<EaseImageCache> cache = caches.lastObject;
            [cache storeImage:image imageData:imageData forKey:key cacheType:cacheType completion:completionBlock];
        }
            break;
        case EaseImageCachesManagerOperationPolicyLowestOnly: {
            id<EaseImageCache> cache = caches.firstObject;
            [cache storeImage:image imageData:imageData forKey:key cacheType:cacheType completion:completionBlock];
        }
            break;
        case EaseImageCachesManagerOperationPolicyConcurrent: {
            EaseImageCachesManagerOperation *operation = [EaseImageCachesManagerOperation new];
            [operation beginWithTotalCount:caches.count];
            [self concurrentStoreImage:image imageData:imageData forKey:key cacheType:cacheType completion:completionBlock enumerator:caches.reverseObjectEnumerator operation:operation];
        }
            break;
        case EaseImageCachesManagerOperationPolicySerial: {
            [self serialStoreImage:image imageData:imageData forKey:key cacheType:cacheType completion:completionBlock enumerator:caches.reverseObjectEnumerator];
        }
            break;
        default:
            break;
    }
}

- (void)removeImageForKey:(NSString *)key cacheType:(EaseImageCacheType)cacheType completion:(EaseWebImageNoParamsBlock)completionBlock {
    if (!key) {
        return;
    }
    NSArray<id<EaseImageCache>> *caches = self.caches;
    NSUInteger count = caches.count;
    if (count == 0) {
        return;
    } else if (count == 1) {
        [caches.firstObject removeImageForKey:key cacheType:cacheType completion:completionBlock];
        return;
    }
    switch (self.removeOperationPolicy) {
        case EaseImageCachesManagerOperationPolicyHighestOnly: {
            id<EaseImageCache> cache = caches.lastObject;
            [cache removeImageForKey:key cacheType:cacheType completion:completionBlock];
        }
            break;
        case EaseImageCachesManagerOperationPolicyLowestOnly: {
            id<EaseImageCache> cache = caches.firstObject;
            [cache removeImageForKey:key cacheType:cacheType completion:completionBlock];
        }
            break;
        case EaseImageCachesManagerOperationPolicyConcurrent: {
            EaseImageCachesManagerOperation *operation = [EaseImageCachesManagerOperation new];
            [operation beginWithTotalCount:caches.count];
            [self concurrentRemoveImageForKey:key cacheType:cacheType completion:completionBlock enumerator:caches.reverseObjectEnumerator operation:operation];
        }
            break;
        case EaseImageCachesManagerOperationPolicySerial: {
            [self serialRemoveImageForKey:key cacheType:cacheType completion:completionBlock enumerator:caches.reverseObjectEnumerator];
        }
            break;
        default:
            break;
    }
}

- (void)containsImageForKey:(NSString *)key cacheType:(EaseImageCacheType)cacheType completion:(EaseImageCacheContainsCompletionBlock)completionBlock {
    if (!key) {
        return;
    }
    NSArray<id<EaseImageCache>> *caches = self.caches;
    NSUInteger count = caches.count;
    if (count == 0) {
        return;
    } else if (count == 1) {
        [caches.firstObject containsImageForKey:key cacheType:cacheType completion:completionBlock];
        return;
    }
    switch (self.clearOperationPolicy) {
        case EaseImageCachesManagerOperationPolicyHighestOnly: {
            id<EaseImageCache> cache = caches.lastObject;
            [cache containsImageForKey:key cacheType:cacheType completion:completionBlock];
        }
            break;
        case EaseImageCachesManagerOperationPolicyLowestOnly: {
            id<EaseImageCache> cache = caches.firstObject;
            [cache containsImageForKey:key cacheType:cacheType completion:completionBlock];
        }
            break;
        case EaseImageCachesManagerOperationPolicyConcurrent: {
            EaseImageCachesManagerOperation *operation = [EaseImageCachesManagerOperation new];
            [operation beginWithTotalCount:caches.count];
            [self concurrentContainsImageForKey:key cacheType:cacheType completion:completionBlock enumerator:caches.reverseObjectEnumerator operation:operation];
        }
            break;
        case EaseImageCachesManagerOperationPolicySerial: {
            EaseImageCachesManagerOperation *operation = [EaseImageCachesManagerOperation new];
            [operation beginWithTotalCount:caches.count];
            [self serialContainsImageForKey:key cacheType:cacheType completion:completionBlock enumerator:caches.reverseObjectEnumerator operation:operation];
        }
            break;
        default:
            break;
    }
}

- (void)clearWithCacheType:(EaseImageCacheType)cacheType completion:(EaseWebImageNoParamsBlock)completionBlock {
    NSArray<id<EaseImageCache>> *caches = self.caches;
    NSUInteger count = caches.count;
    if (count == 0) {
        return;
    } else if (count == 1) {
        [caches.firstObject clearWithCacheType:cacheType completion:completionBlock];
        return;
    }
    switch (self.clearOperationPolicy) {
        case EaseImageCachesManagerOperationPolicyHighestOnly: {
            id<EaseImageCache> cache = caches.lastObject;
            [cache clearWithCacheType:cacheType completion:completionBlock];
        }
            break;
        case EaseImageCachesManagerOperationPolicyLowestOnly: {
            id<EaseImageCache> cache = caches.firstObject;
            [cache clearWithCacheType:cacheType completion:completionBlock];
        }
            break;
        case EaseImageCachesManagerOperationPolicyConcurrent: {
            EaseImageCachesManagerOperation *operation = [EaseImageCachesManagerOperation new];
            [operation beginWithTotalCount:caches.count];
            [self concurrentClearWithCacheType:cacheType completion:completionBlock enumerator:caches.reverseObjectEnumerator operation:operation];
        }
            break;
        case EaseImageCachesManagerOperationPolicySerial: {
            [self serialClearWithCacheType:cacheType completion:completionBlock enumerator:caches.reverseObjectEnumerator];
        }
            break;
        default:
            break;
    }
}

#pragma mark - Concurrent Operation

- (void)concurrentQueryImageForKey:(NSString *)key options:(EaseWebImageOptions)options context:(EaseWebImageContext *)context cacheType:(EaseImageCacheType)queryCacheType completion:(EaseImageCacheQueryCompletionBlock)completionBlock enumerator:(NSEnumerator<id<EaseImageCache>> *)enumerator operation:(EaseImageCachesManagerOperation *)operation {
    NSParameterAssert(enumerator);
    NSParameterAssert(operation);
    for (id<EaseImageCache> cache in enumerator) {
        [cache queryImageForKey:key options:options context:context cacheType:queryCacheType completion:^(UIImage * _Nullable image, NSData * _Nullable data, EaseImageCacheType cacheType) {
            if (operation.isCancelled) {
                // Cancelled
                return;
            }
            if (operation.isFinished) {
                // Finished
                return;
            }
            [operation completeOne];
            if (image) {
                // Success
                [operation done];
                if (completionBlock) {
                    completionBlock(image, data, cacheType);
                }
                return;
            }
            if (operation.pendingCount == 0) {
                // Complete
                [operation done];
                if (completionBlock) {
                    completionBlock(nil, nil, EaseImageCacheTypeNone);
                }
            }
        }];
    }
}

- (void)concurrentStoreImage:(UIImage *)image imageData:(NSData *)imageData forKey:(NSString *)key cacheType:(EaseImageCacheType)cacheType completion:(EaseWebImageNoParamsBlock)completionBlock enumerator:(NSEnumerator<id<EaseImageCache>> *)enumerator operation:(EaseImageCachesManagerOperation *)operation {
    NSParameterAssert(enumerator);
    NSParameterAssert(operation);
    for (id<EaseImageCache> cache in enumerator) {
        [cache storeImage:image imageData:imageData forKey:key cacheType:cacheType completion:^{
            if (operation.isCancelled) {
                // Cancelled
                return;
            }
            if (operation.isFinished) {
                // Finished
                return;
            }
            [operation completeOne];
            if (operation.pendingCount == 0) {
                // Complete
                [operation done];
                if (completionBlock) {
                    completionBlock();
                }
            }
        }];
    }
}

- (void)concurrentRemoveImageForKey:(NSString *)key cacheType:(EaseImageCacheType)cacheType completion:(EaseWebImageNoParamsBlock)completionBlock enumerator:(NSEnumerator<id<EaseImageCache>> *)enumerator operation:(EaseImageCachesManagerOperation *)operation {
    NSParameterAssert(enumerator);
    NSParameterAssert(operation);
    for (id<EaseImageCache> cache in enumerator) {
        [cache removeImageForKey:key cacheType:cacheType completion:^{
            if (operation.isCancelled) {
                // Cancelled
                return;
            }
            if (operation.isFinished) {
                // Finished
                return;
            }
            [operation completeOne];
            if (operation.pendingCount == 0) {
                // Complete
                [operation done];
                if (completionBlock) {
                    completionBlock();
                }
            }
        }];
    }
}

- (void)concurrentContainsImageForKey:(NSString *)key cacheType:(EaseImageCacheType)cacheType completion:(EaseImageCacheContainsCompletionBlock)completionBlock enumerator:(NSEnumerator<id<EaseImageCache>> *)enumerator operation:(EaseImageCachesManagerOperation *)operation {
    NSParameterAssert(enumerator);
    NSParameterAssert(operation);
    for (id<EaseImageCache> cache in enumerator) {
        [cache containsImageForKey:key cacheType:cacheType completion:^(EaseImageCacheType containsCacheType) {
            if (operation.isCancelled) {
                // Cancelled
                return;
            }
            if (operation.isFinished) {
                // Finished
                return;
            }
            [operation completeOne];
            if (containsCacheType != EaseImageCacheTypeNone) {
                // Success
                [operation done];
                if (completionBlock) {
                    completionBlock(containsCacheType);
                }
                return;
            }
            if (operation.pendingCount == 0) {
                // Complete
                [operation done];
                if (completionBlock) {
                    completionBlock(EaseImageCacheTypeNone);
                }
            }
        }];
    }
}

- (void)concurrentClearWithCacheType:(EaseImageCacheType)cacheType completion:(EaseWebImageNoParamsBlock)completionBlock enumerator:(NSEnumerator<id<EaseImageCache>> *)enumerator operation:(EaseImageCachesManagerOperation *)operation {
    NSParameterAssert(enumerator);
    NSParameterAssert(operation);
    for (id<EaseImageCache> cache in enumerator) {
        [cache clearWithCacheType:cacheType completion:^{
            if (operation.isCancelled) {
                // Cancelled
                return;
            }
            if (operation.isFinished) {
                // Finished
                return;
            }
            [operation completeOne];
            if (operation.pendingCount == 0) {
                // Complete
                [operation done];
                if (completionBlock) {
                    completionBlock();
                }
            }
        }];
    }
}

#pragma mark - Serial Operation

- (void)serialQueryImageForKey:(NSString *)key options:(EaseWebImageOptions)options context:(EaseWebImageContext *)context cacheType:(EaseImageCacheType)queryCacheType completion:(EaseImageCacheQueryCompletionBlock)completionBlock enumerator:(NSEnumerator<id<EaseImageCache>> *)enumerator operation:(EaseImageCachesManagerOperation *)operation {
    NSParameterAssert(enumerator);
    NSParameterAssert(operation);
    id<EaseImageCache> cache = enumerator.nextObject;
    if (!cache) {
        // Complete
        [operation done];
        if (completionBlock) {
            completionBlock(nil, nil, EaseImageCacheTypeNone);
        }
        return;
    }
    @weakify(self);
    [cache queryImageForKey:key options:options context:context cacheType:queryCacheType completion:^(UIImage * _Nullable image, NSData * _Nullable data, EaseImageCacheType cacheType) {
        @strongify(self);
        if (operation.isCancelled) {
            // Cancelled
            return;
        }
        if (operation.isFinished) {
            // Finished
            return;
        }
        [operation completeOne];
        if (image) {
            // Success
            [operation done];
            if (completionBlock) {
                completionBlock(image, data, cacheType);
            }
            return;
        }
        // Next
        [self serialQueryImageForKey:key options:options context:context cacheType:queryCacheType completion:completionBlock enumerator:enumerator operation:operation];
    }];
}

- (void)serialStoreImage:(UIImage *)image imageData:(NSData *)imageData forKey:(NSString *)key cacheType:(EaseImageCacheType)cacheType completion:(EaseWebImageNoParamsBlock)completionBlock enumerator:(NSEnumerator<id<EaseImageCache>> *)enumerator {
    NSParameterAssert(enumerator);
    id<EaseImageCache> cache = enumerator.nextObject;
    if (!cache) {
        // Complete
        if (completionBlock) {
            completionBlock();
        }
        return;
    }
    @weakify(self);
    [cache storeImage:image imageData:imageData forKey:key cacheType:cacheType completion:^{
        @strongify(self);
        // Next
        [self serialStoreImage:image imageData:imageData forKey:key cacheType:cacheType completion:completionBlock enumerator:enumerator];
    }];
}

- (void)serialRemoveImageForKey:(NSString *)key cacheType:(EaseImageCacheType)cacheType completion:(EaseWebImageNoParamsBlock)completionBlock enumerator:(NSEnumerator<id<EaseImageCache>> *)enumerator {
    NSParameterAssert(enumerator);
    id<EaseImageCache> cache = enumerator.nextObject;
    if (!cache) {
        // Complete
        if (completionBlock) {
            completionBlock();
        }
        return;
    }
    @weakify(self);
    [cache removeImageForKey:key cacheType:cacheType completion:^{
        @strongify(self);
        // Next
        [self serialRemoveImageForKey:key cacheType:cacheType completion:completionBlock enumerator:enumerator];
    }];
}

- (void)serialContainsImageForKey:(NSString *)key cacheType:(EaseImageCacheType)cacheType completion:(EaseImageCacheContainsCompletionBlock)completionBlock enumerator:(NSEnumerator<id<EaseImageCache>> *)enumerator operation:(EaseImageCachesManagerOperation *)operation {
    NSParameterAssert(enumerator);
    NSParameterAssert(operation);
    id<EaseImageCache> cache = enumerator.nextObject;
    if (!cache) {
        // Complete
        [operation done];
        if (completionBlock) {
            completionBlock(EaseImageCacheTypeNone);
        }
        return;
    }
    @weakify(self);
    [cache containsImageForKey:key cacheType:cacheType completion:^(EaseImageCacheType containsCacheType) {
        @strongify(self);
        if (operation.isCancelled) {
            // Cancelled
            return;
        }
        if (operation.isFinished) {
            // Finished
            return;
        }
        [operation completeOne];
        if (containsCacheType != EaseImageCacheTypeNone) {
            // Success
            [operation done];
            if (completionBlock) {
                completionBlock(containsCacheType);
            }
            return;
        }
        // Next
        [self serialContainsImageForKey:key cacheType:cacheType completion:completionBlock enumerator:enumerator operation:operation];
    }];
}

- (void)serialClearWithCacheType:(EaseImageCacheType)cacheType completion:(EaseWebImageNoParamsBlock)completionBlock enumerator:(NSEnumerator<id<EaseImageCache>> *)enumerator {
    NSParameterAssert(enumerator);
    id<EaseImageCache> cache = enumerator.nextObject;
    if (!cache) {
        // Complete
        if (completionBlock) {
            completionBlock();
        }
        return;
    }
    @weakify(self);
    [cache clearWithCacheType:cacheType completion:^{
        @strongify(self);
        // Next
        [self serialClearWithCacheType:cacheType completion:completionBlock enumerator:enumerator];
    }];
}

@end
