/*
 * This file is part of the EaseWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIView+EaseWebCacheOperation.h"
#import "objc/runtime.h"

static char loadOperationKey;

// key is strong, value is weak because operation instance is retained by EaseWebImageManager's runningOperations property
// we should use lock to keep thread-safe because these method may not be accessed from main queue
typedef NSMapTable<NSString *, id<EaseWebImageOperation>> EaseOperationsDictionary;

@implementation UIView (EaseWebCacheOperation)

- (EaseOperationsDictionary *)Ease_operationDictionary {
    @synchronized(self) {
        EaseOperationsDictionary *operations = objc_getAssociatedObject(self, &loadOperationKey);
        if (operations) {
            return operations;
        }
        operations = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory capacity:0];
        objc_setAssociatedObject(self, &loadOperationKey, operations, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return operations;
    }
}

- (nullable id<EaseWebImageOperation>)Ease_imageLoadOperationForKey:(nullable NSString *)key  {
    id<EaseWebImageOperation> operation;
    if (key) {
        EaseOperationsDictionary *operationDictionary = [self Ease_operationDictionary];
        @synchronized (self) {
            operation = [operationDictionary objectForKey:key];
        }
    }
    return operation;
}

- (void)Ease_setImageLoadOperation:(nullable id<EaseWebImageOperation>)operation forKey:(nullable NSString *)key {
    if (key) {
        [self Ease_cancelImageLoadOperationWithKey:key];
        if (operation) {
            EaseOperationsDictionary *operationDictionary = [self Ease_operationDictionary];
            @synchronized (self) {
                [operationDictionary setObject:operation forKey:key];
            }
        }
    }
}

- (void)Ease_cancelImageLoadOperationWithKey:(nullable NSString *)key {
    if (key) {
        // Cancel in progress downloader from queue
        EaseOperationsDictionary *operationDictionary = [self Ease_operationDictionary];
        id<EaseWebImageOperation> operation;
        
        @synchronized (self) {
            operation = [operationDictionary objectForKey:key];
        }
        if (operation) {
            if ([operation conformsToProtocol:@protocol(EaseWebImageOperation)]) {
                [operation cancel];
            }
            @synchronized (self) {
                [operationDictionary removeObjectForKey:key];
            }
        }
    }
}

- (void)Ease_removeImageLoadOperationWithKey:(nullable NSString *)key {
    if (key) {
        EaseOperationsDictionary *operationDictionary = [self Ease_operationDictionary];
        @synchronized (self) {
            [operationDictionary removeObjectForKey:key];
        }
    }
}

@end
