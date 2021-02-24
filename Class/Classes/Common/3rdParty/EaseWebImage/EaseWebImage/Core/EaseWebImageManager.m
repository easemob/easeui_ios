/*
 * This file is part of the EaseWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "EaseWebImageManager.h"
#import "EaseImageCache.h"
#import "EaseWebImageDownloader.h"
#import "UIImage+EaseMetadata.h"
#import "EaseAssociatedObject.h"
#import "EaseWebImageError.h"
#import "EaseInternalMacros.h"

static id<EaseImageCache> _defaultImageCache;
static id<EaseImageLoader> _defaultImageLoader;

@interface EaseWebImageCombinedOperation ()

@property (assign, nonatomic, getter = isCancelled) BOOL cancelled;
@property (strong, nonatomic, readwrite, nullable) id<EaseWebImageOperation> loaderOperation;
@property (strong, nonatomic, readwrite, nullable) id<EaseWebImageOperation> cacheOperation;
@property (weak, nonatomic, nullable) EaseWebImageManager *manager;

@end

@interface EaseWebImageManager () {
    Ease_LOCK_DECLARE(_failedURLsLock); // a lock to keep the access to `failedURLs` thread-safe
    Ease_LOCK_DECLARE(_runningOperationsLock); // a lock to keep the access to `runningOperations` thread-safe
}

@property (strong, nonatomic, readwrite, nonnull) EaseImageCache *imageCache;
@property (strong, nonatomic, readwrite, nonnull) id<EaseImageLoader> imageLoader;
@property (strong, nonatomic, nonnull) NSMutableSet<NSURL *> *failedURLs;
@property (strong, nonatomic, nonnull) NSMutableSet<EaseWebImageCombinedOperation *> *runningOperations;

@end

@implementation EaseWebImageManager

+ (id<EaseImageCache>)defaultImageCache {
    return _defaultImageCache;
}

+ (void)setDefaultImageCache:(id<EaseImageCache>)defaultImageCache {
    if (defaultImageCache && ![defaultImageCache conformsToProtocol:@protocol(EaseImageCache)]) {
        return;
    }
    _defaultImageCache = defaultImageCache;
}

+ (id<EaseImageLoader>)defaultImageLoader {
    return _defaultImageLoader;
}

+ (void)setDefaultImageLoader:(id<EaseImageLoader>)defaultImageLoader {
    if (defaultImageLoader && ![defaultImageLoader conformsToProtocol:@protocol(EaseImageLoader)]) {
        return;
    }
    _defaultImageLoader = defaultImageLoader;
}

+ (nonnull instancetype)sharedManager {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (nonnull instancetype)init {
    id<EaseImageCache> cache = [[self class] defaultImageCache];
    if (!cache) {
        cache = [EaseImageCache sharedImageCache];
    }
    id<EaseImageLoader> loader = [[self class] defaultImageLoader];
    if (!loader) {
        loader = [EaseWebImageDownloader sharedDownloader];
    }
    return [self initWithCache:cache loader:loader];
}

- (nonnull instancetype)initWithCache:(nonnull id<EaseImageCache>)cache loader:(nonnull id<EaseImageLoader>)loader {
    if ((self = [super init])) {
        _imageCache = cache;
        _imageLoader = loader;
        _failedURLs = [NSMutableSet new];
        Ease_LOCK_INIT(_failedURLsLock);
        _runningOperations = [NSMutableSet new];
        Ease_LOCK_INIT(_runningOperationsLock);
    }
    return self;
}

- (nullable NSString *)cacheKeyForURL:(nullable NSURL *)url {
    if (!url) {
        return @"";
    }
    
    NSString *key;
    // Cache Key Filter
    id<EaseWebImageCacheKeyFilter> cacheKeyFilter = self.cacheKeyFilter;
    if (cacheKeyFilter) {
        key = [cacheKeyFilter cacheKeyForURL:url];
    } else {
        key = url.absoluteString;
    }
    
    return key;
}

- (nullable NSString *)cacheKeyForURL:(nullable NSURL *)url context:(nullable EaseWebImageContext *)context {
    if (!url) {
        return @"";
    }
    
    NSString *key;
    // Cache Key Filter
    id<EaseWebImageCacheKeyFilter> cacheKeyFilter = self.cacheKeyFilter;
    if (context[EaseWebImageContextCacheKeyFilter]) {
        cacheKeyFilter = context[EaseWebImageContextCacheKeyFilter];
    }
    if (cacheKeyFilter) {
        key = [cacheKeyFilter cacheKeyForURL:url];
    } else {
        key = url.absoluteString;
    }
    
    // Thumbnail Key Appending
    NSValue *thumbnailSizeValue = context[EaseWebImageContextImageThumbnailPixelSize];
    if (thumbnailSizeValue != nil) {
        CGSize thumbnailSize = CGSizeZero;
#if Ease_MAC
        thumbnailSize = thumbnailSizeValue.sizeValue;
#else
        thumbnailSize = thumbnailSizeValue.CGSizeValue;
#endif
        BOOL preserveAspectRatio = YES;
        NSNumber *preserveAspectRatioValue = context[EaseWebImageContextImagePreserveAspectRatio];
        if (preserveAspectRatioValue != nil) {
            preserveAspectRatio = preserveAspectRatioValue.boolValue;
        }
        key = EaseThumbnailedKeyForKey(key, thumbnailSize, preserveAspectRatio);
    }
    
    // Transformer Key Appending
    id<EaseImageTransformer> transformer = self.transformer;
    if (context[EaseWebImageContextImageTransformer]) {
        transformer = context[EaseWebImageContextImageTransformer];
        if (![transformer conformsToProtocol:@protocol(EaseImageTransformer)]) {
            transformer = nil;
        }
    }
    if (transformer) {
        key = EaseTransformedKeyForKey(key, transformer.transformerKey);
    }
    
    return key;
}

- (EaseWebImageCombinedOperation *)loadImageWithURL:(NSURL *)url options:(EaseWebImageOptions)options progress:(EaseImageLoaderProgressBlock)progressBlock completed:(EaseInternalCompletionBlock)completedBlock {
    return [self loadImageWithURL:url options:options context:nil progress:progressBlock completed:completedBlock];
}

- (EaseWebImageCombinedOperation *)loadImageWithURL:(nullable NSURL *)url
                                          options:(EaseWebImageOptions)options
                                          context:(nullable EaseWebImageContext *)context
                                         progress:(nullable EaseImageLoaderProgressBlock)progressBlock
                                        completed:(nonnull EaseInternalCompletionBlock)completedBlock {
    // Invoking this method without a completedBlock is pointless
    NSAssert(completedBlock != nil, @"If you mean to prefetch the image, use -[EaseWebImagePrefetcher prefetchURLs] instead");

    // Very common mistake is to send the URL using NSString object instead of NSURL. For some strange reason, Xcode won't
    // throw any warning for this type mismatch. Here we failsafe this error by allowing URLs to be passed as NSString.
    if ([url isKindOfClass:NSString.class]) {
        url = [NSURL URLWithString:(NSString *)url];
    }

    // Prevents app crashing on argument type error like sending NSNull instead of NSURL
    if (![url isKindOfClass:NSURL.class]) {
        url = nil;
    }

    EaseWebImageCombinedOperation *operation = [EaseWebImageCombinedOperation new];
    operation.manager = self;

    BOOL isFailedUrl = NO;
    if (url) {
        Ease_LOCK(_failedURLsLock);
        isFailedUrl = [self.failedURLs containsObject:url];
        Ease_UNLOCK(_failedURLsLock);
    }

    if (url.absoluteString.length == 0 || (!(options & EaseWebImageRetryFailed) && isFailedUrl)) {
        NSString *description = isFailedUrl ? @"Image url is blacklisted" : @"Image url is nil";
        NSInteger code = isFailedUrl ? EaseWebImageErrorBlackListed : EaseWebImageErrorInvalidURL;
        [self callCompletionBlockForOperation:operation completion:completedBlock error:[NSError errorWithDomain:EaseWebImageErrorDomain code:code userInfo:@{NSLocalizedDescriptionKey : description}] url:url];
        return operation;
    }

    Ease_LOCK(_runningOperationsLock);
    [self.runningOperations addObject:operation];
    Ease_UNLOCK(_runningOperationsLock);
    
    // Preprocess the options and context arg to decide the final the result for manager
    EaseWebImageOptionsResult *result = [self processedResultForURL:url options:options context:context];
    
    // Start the entry to load image from cache
    [self callCacheProcessForOperation:operation url:url options:result.options context:result.context progress:progressBlock completed:completedBlock];

    return operation;
}

- (void)cancelAll {
    Ease_LOCK(_runningOperationsLock);
    NSSet<EaseWebImageCombinedOperation *> *copiedOperations = [self.runningOperations copy];
    Ease_UNLOCK(_runningOperationsLock);
    [copiedOperations makeObjectsPerformSelector:@selector(cancel)]; // This will call `safelyRemoveOperationFromRunning:` and remove from the array
}

- (BOOL)isRunning {
    BOOL isRunning = NO;
    Ease_LOCK(_runningOperationsLock);
    isRunning = (self.runningOperations.count > 0);
    Ease_UNLOCK(_runningOperationsLock);
    return isRunning;
}

- (void)removeFailedURL:(NSURL *)url {
    if (!url) {
        return;
    }
    Ease_LOCK(_failedURLsLock);
    [self.failedURLs removeObject:url];
    Ease_UNLOCK(_failedURLsLock);
}

- (void)removeAllFailedURLs {
    Ease_LOCK(_failedURLsLock);
    [self.failedURLs removeAllObjects];
    Ease_UNLOCK(_failedURLsLock);
}

#pragma mark - Private

// Query normal cache process
- (void)callCacheProcessForOperation:(nonnull EaseWebImageCombinedOperation *)operation
                                 url:(nonnull NSURL *)url
                             options:(EaseWebImageOptions)options
                             context:(nullable EaseWebImageContext *)context
                            progress:(nullable EaseImageLoaderProgressBlock)progressBlock
                           completed:(nullable EaseInternalCompletionBlock)completedBlock {
    // Grab the image cache to use
    id<EaseImageCache> imageCache;
    if ([context[EaseWebImageContextImageCache] conformsToProtocol:@protocol(EaseImageCache)]) {
        imageCache = context[EaseWebImageContextImageCache];
    } else {
        imageCache = self.imageCache;
    }
    
    // Get the query cache type
    EaseImageCacheType queryCacheType = EaseImageCacheTypeAll;
    if (context[EaseWebImageContextQueryCacheType]) {
        queryCacheType = [context[EaseWebImageContextQueryCacheType] integerValue];
    }
    
    // Check whether we should query cache
    BOOL shouldQueryCache = !Ease_OPTIONS_CONTAINS(options, EaseWebImageFromLoaderOnly);
    if (shouldQueryCache) {
        NSString *key = [self cacheKeyForURL:url context:context];
        @weakify(operation);
        operation.cacheOperation = [imageCache queryImageForKey:key options:options context:context cacheType:queryCacheType completion:^(UIImage * _Nullable cachedImage, NSData * _Nullable cachedData, EaseImageCacheType cacheType) {
            @strongify(operation);
            if (!operation || operation.isCancelled) {
                // Image combined operation cancelled by user
                [self callCompletionBlockForOperation:operation completion:completedBlock error:[NSError errorWithDomain:EaseWebImageErrorDomain code:EaseWebImageErrorCancelled userInfo:@{NSLocalizedDescriptionKey : @"Operation cancelled by user during querying the cache"}] url:url];
                [self safelyRemoveOperationFromRunning:operation];
                return;
            } else if (context[EaseWebImageContextImageTransformer] && !cachedImage) {
                // Have a chance to query original cache instead of downloading
                [self callOriginalCacheProcessForOperation:operation url:url options:options context:context progress:progressBlock completed:completedBlock];
                return;
            }
            
            // Continue download process
            [self callDownloadProcessForOperation:operation url:url options:options context:context cachedImage:cachedImage cachedData:cachedData cacheType:cacheType progress:progressBlock completed:completedBlock];
        }];
    } else {
        // Continue download process
        [self callDownloadProcessForOperation:operation url:url options:options context:context cachedImage:nil cachedData:nil cacheType:EaseImageCacheTypeNone progress:progressBlock completed:completedBlock];
    }
}

// Query original cache process
- (void)callOriginalCacheProcessForOperation:(nonnull EaseWebImageCombinedOperation *)operation
                                         url:(nonnull NSURL *)url
                                     options:(EaseWebImageOptions)options
                                     context:(nullable EaseWebImageContext *)context
                                    progress:(nullable EaseImageLoaderProgressBlock)progressBlock
                                   completed:(nullable EaseInternalCompletionBlock)completedBlock {
    // Grab the image cache to use
    id<EaseImageCache> imageCache;
    if ([context[EaseWebImageContextImageCache] conformsToProtocol:@protocol(EaseImageCache)]) {
        imageCache = context[EaseWebImageContextImageCache];
    } else {
        imageCache = self.imageCache;
    }
    
    // Get the original query cache type
    EaseImageCacheType originalQueryCacheType = EaseImageCacheTypeNone;
    if (context[EaseWebImageContextOriginalQueryCacheType]) {
        originalQueryCacheType = [context[EaseWebImageContextOriginalQueryCacheType] integerValue];
    }
    
    // Check whether we should query original cache
    BOOL shouldQueryOriginalCache = (originalQueryCacheType != EaseImageCacheTypeNone);
    if (shouldQueryOriginalCache) {
        // Change originContext to mutable
        EaseWebImageMutableContext * __block originContext;
        if (context) {
            originContext = [context mutableCopy];
        } else {
            originContext = [NSMutableDictionary dictionary];
        }
        
        // Disable transformer for cache key generation
        id<EaseImageTransformer> transformer = originContext[EaseWebImageContextImageTransformer];
        originContext[EaseWebImageContextImageTransformer] = [NSNull null];
        
        NSString *key = [self cacheKeyForURL:url context:originContext];
        @weakify(operation);
        operation.cacheOperation = [imageCache queryImageForKey:key options:options context:context cacheType:originalQueryCacheType completion:^(UIImage * _Nullable cachedImage, NSData * _Nullable cachedData, EaseImageCacheType cacheType) {
            @strongify(operation);
            if (!operation || operation.isCancelled) {
                // Image combined operation cancelled by user
                [self callCompletionBlockForOperation:operation completion:completedBlock error:[NSError errorWithDomain:EaseWebImageErrorDomain code:EaseWebImageErrorCancelled userInfo:@{NSLocalizedDescriptionKey : @"Operation cancelled by user during querying the cache"}] url:url];
                [self safelyRemoveOperationFromRunning:operation];
                return;
            }
            
            // Add original transformer
            if (transformer) {
                originContext[EaseWebImageContextImageTransformer] = transformer;
            }
            
            // Use the store cache process instead of downloading, and ignore .refreshCached option for now
            [self callStoreCacheProcessForOperation:operation url:url options:options context:context downloadedImage:cachedImage downloadedData:cachedData finished:YES progress:progressBlock completed:completedBlock];
            
            [self safelyRemoveOperationFromRunning:operation];
        }];
    } else {
        // Continue download process
        [self callDownloadProcessForOperation:operation url:url options:options context:context cachedImage:nil cachedData:nil cacheType:originalQueryCacheType progress:progressBlock completed:completedBlock];
    }
}

// Download process
- (void)callDownloadProcessForOperation:(nonnull EaseWebImageCombinedOperation *)operation
                                    url:(nonnull NSURL *)url
                                options:(EaseWebImageOptions)options
                                context:(EaseWebImageContext *)context
                            cachedImage:(nullable UIImage *)cachedImage
                             cachedData:(nullable NSData *)cachedData
                              cacheType:(EaseImageCacheType)cacheType
                               progress:(nullable EaseImageLoaderProgressBlock)progressBlock
                              completed:(nullable EaseInternalCompletionBlock)completedBlock {
    // Grab the image loader to use
    id<EaseImageLoader> imageLoader;
    if ([context[EaseWebImageContextImageLoader] conformsToProtocol:@protocol(EaseImageLoader)]) {
        imageLoader = context[EaseWebImageContextImageLoader];
    } else {
        imageLoader = self.imageLoader;
    }
    
    // Check whether we should download image from network
    BOOL shouldDownload = !Ease_OPTIONS_CONTAINS(options, EaseWebImageFromCacheOnly);
    shouldDownload &= (!cachedImage || options & EaseWebImageRefreshCached);
    shouldDownload &= (![self.delegate respondsToSelector:@selector(imageManager:shouldDownloadImageForURL:)] || [self.delegate imageManager:self shouldDownloadImageForURL:url]);
    if ([imageLoader respondsToSelector:@selector(canRequestImageForURL:options:context:)]) {
        shouldDownload &= [imageLoader canRequestImageForURL:url options:options context:context];
    } else {
        shouldDownload &= [imageLoader canRequestImageForURL:url];
    }
    if (shouldDownload) {
        if (cachedImage && options & EaseWebImageRefreshCached) {
            // If image was found in the cache but EaseWebImageRefreshCached is provided, notify about the cached image
            // AND try to re-download it in order to let a chance to NSURLCache to refresh it from server.
            [self callCompletionBlockForOperation:operation completion:completedBlock image:cachedImage data:cachedData error:nil cacheType:cacheType finished:YES url:url];
            // Pass the cached image to the image loader. The image loader should check whether the remote image is equal to the cached image.
            EaseWebImageMutableContext *mutableContext;
            if (context) {
                mutableContext = [context mutableCopy];
            } else {
                mutableContext = [NSMutableDictionary dictionary];
            }
            mutableContext[EaseWebImageContextLoaderCachedImage] = cachedImage;
            context = [mutableContext copy];
        }
        
        @weakify(operation);
        operation.loaderOperation = [imageLoader requestImageWithURL:url options:options context:context progress:progressBlock completed:^(UIImage *downloadedImage, NSData *downloadedData, NSError *error, BOOL finished) {
            @strongify(operation);
            if (!operation || operation.isCancelled) {
                // Image combined operation cancelled by user
                [self callCompletionBlockForOperation:operation completion:completedBlock error:[NSError errorWithDomain:EaseWebImageErrorDomain code:EaseWebImageErrorCancelled userInfo:@{NSLocalizedDescriptionKey : @"Operation cancelled by user during sending the request"}] url:url];
            } else if (cachedImage && options & EaseWebImageRefreshCached && [error.domain isEqualToString:EaseWebImageErrorDomain] && error.code == EaseWebImageErrorCacheNotModified) {
                // Image refresh hit the NSURLCache cache, do not call the completion block
            } else if ([error.domain isEqualToString:EaseWebImageErrorDomain] && error.code == EaseWebImageErrorCancelled) {
                // Download operation cancelled by user before sending the request, don't block failed URL
                [self callCompletionBlockForOperation:operation completion:completedBlock error:error url:url];
            } else if (error) {
                [self callCompletionBlockForOperation:operation completion:completedBlock error:error url:url];
                BOOL shouldBlockFailedURL = [self shouldBlockFailedURLWithURL:url error:error options:options context:context];
                
                if (shouldBlockFailedURL) {
                    Ease_LOCK(self->_failedURLsLock);
                    [self.failedURLs addObject:url];
                    Ease_UNLOCK(self->_failedURLsLock);
                }
            } else {
                if ((options & EaseWebImageRetryFailed)) {
                    Ease_LOCK(self->_failedURLsLock);
                    [self.failedURLs removeObject:url];
                    Ease_UNLOCK(self->_failedURLsLock);
                }
                // Continue store cache process
                [self callStoreCacheProcessForOperation:operation url:url options:options context:context downloadedImage:downloadedImage downloadedData:downloadedData finished:finished progress:progressBlock completed:completedBlock];
            }
            
            if (finished) {
                [self safelyRemoveOperationFromRunning:operation];
            }
        }];
    } else if (cachedImage) {
        [self callCompletionBlockForOperation:operation completion:completedBlock image:cachedImage data:cachedData error:nil cacheType:cacheType finished:YES url:url];
        [self safelyRemoveOperationFromRunning:operation];
    } else {
        // Image not in cache and download disallowed by delegate
        [self callCompletionBlockForOperation:operation completion:completedBlock image:nil data:nil error:nil cacheType:EaseImageCacheTypeNone finished:YES url:url];
        [self safelyRemoveOperationFromRunning:operation];
    }
}

// Store cache process
- (void)callStoreCacheProcessForOperation:(nonnull EaseWebImageCombinedOperation *)operation
                                      url:(nonnull NSURL *)url
                                  options:(EaseWebImageOptions)options
                                  context:(EaseWebImageContext *)context
                          downloadedImage:(nullable UIImage *)downloadedImage
                           downloadedData:(nullable NSData *)downloadedData
                                 finished:(BOOL)finished
                                 progress:(nullable EaseImageLoaderProgressBlock)progressBlock
                                completed:(nullable EaseInternalCompletionBlock)completedBlock {
    // the target image store cache type
    EaseImageCacheType storeCacheType = EaseImageCacheTypeAll;
    if (context[EaseWebImageContextStoreCacheType]) {
        storeCacheType = [context[EaseWebImageContextStoreCacheType] integerValue];
    }
    // the original store image cache type
    EaseImageCacheType originalStoreCacheType = EaseImageCacheTypeNone;
    if (context[EaseWebImageContextOriginalStoreCacheType]) {
        originalStoreCacheType = [context[EaseWebImageContextOriginalStoreCacheType] integerValue];
    }
    // origin cache key
    EaseWebImageMutableContext *originContext = [context mutableCopy];
    // disable transformer for cache key generation
    originContext[EaseWebImageContextImageTransformer] = [NSNull null];
    NSString *key = [self cacheKeyForURL:url context:originContext];
    id<EaseImageTransformer> transformer = context[EaseWebImageContextImageTransformer];
    if (![transformer conformsToProtocol:@protocol(EaseImageTransformer)]) {
        transformer = nil;
    }
    id<EaseWebImageCacheSerializer> cacheSerializer = context[EaseWebImageContextCacheSerializer];
    
    BOOL shouldTransformImage = downloadedImage && transformer;
    shouldTransformImage = shouldTransformImage && (!downloadedImage.ease_isAnimated || (options & EaseWebImageTransformAnimatedImage));
    shouldTransformImage = shouldTransformImage && (!downloadedImage.ease_isVector || (options & EaseWebImageTransformVectorImage));
    BOOL shouldCacheOriginal = downloadedImage && finished;
    
    // if available, store original image to cache
    if (shouldCacheOriginal) {
        // normally use the store cache type, but if target image is transformed, use original store cache type instead
        EaseImageCacheType targetStoreCacheType = shouldTransformImage ? originalStoreCacheType : storeCacheType;
        if (cacheSerializer && (targetStoreCacheType == EaseImageCacheTypeDisk || targetStoreCacheType == EaseImageCacheTypeAll)) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                @autoreleasepool {
                    NSData *cacheData = [cacheSerializer cacheDataWithImage:downloadedImage originalData:downloadedData imageURL:url];
                    [self storeImage:downloadedImage imageData:cacheData forKey:key cacheType:targetStoreCacheType options:options context:context completion:^{
                        // Continue transform process
                        [self callTransformProcessForOperation:operation url:url options:options context:context originalImage:downloadedImage originalData:downloadedData finished:finished progress:progressBlock completed:completedBlock];
                    }];
                }
            });
        } else {
            [self storeImage:downloadedImage imageData:downloadedData forKey:key cacheType:targetStoreCacheType options:options context:context completion:^{
                // Continue transform process
                [self callTransformProcessForOperation:operation url:url options:options context:context originalImage:downloadedImage originalData:downloadedData finished:finished progress:progressBlock completed:completedBlock];
            }];
        }
    } else {
        // Continue transform process
        [self callTransformProcessForOperation:operation url:url options:options context:context originalImage:downloadedImage originalData:downloadedData finished:finished progress:progressBlock completed:completedBlock];
    }
}

// Transform process
- (void)callTransformProcessForOperation:(nonnull EaseWebImageCombinedOperation *)operation
                                     url:(nonnull NSURL *)url
                                 options:(EaseWebImageOptions)options
                                 context:(EaseWebImageContext *)context
                           originalImage:(nullable UIImage *)originalImage
                            originalData:(nullable NSData *)originalData
                                finished:(BOOL)finished
                                progress:(nullable EaseImageLoaderProgressBlock)progressBlock
                               completed:(nullable EaseInternalCompletionBlock)completedBlock {
    // the target image store cache type
    EaseImageCacheType storeCacheType = EaseImageCacheTypeAll;
    if (context[EaseWebImageContextStoreCacheType]) {
        storeCacheType = [context[EaseWebImageContextStoreCacheType] integerValue];
    }
    // transformed cache key
    NSString *key = [self cacheKeyForURL:url context:context];
    id<EaseImageTransformer> transformer = context[EaseWebImageContextImageTransformer];
    if (![transformer conformsToProtocol:@protocol(EaseImageTransformer)]) {
        transformer = nil;
    }
    id<EaseWebImageCacheSerializer> cacheSerializer = context[EaseWebImageContextCacheSerializer];
    
    BOOL shouldTransformImage = originalImage && transformer;
    shouldTransformImage = shouldTransformImage && (!originalImage.ease_isAnimated || (options & EaseWebImageTransformAnimatedImage));
    shouldTransformImage = shouldTransformImage && (!originalImage.ease_isVector || (options & EaseWebImageTransformVectorImage));
    // if available, store transformed image to cache
    if (shouldTransformImage) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            @autoreleasepool {
                UIImage *transformedImage = [transformer transformedImageWithImage:originalImage forKey:key];
                if (transformedImage && finished) {
                    BOOL imageWasTransformed = ![transformedImage isEqual:originalImage];
                    NSData *cacheData;
                    // pass nil if the image was transformed, so we can recalculate the data from the image
                    if (cacheSerializer && (storeCacheType == EaseImageCacheTypeDisk || storeCacheType == EaseImageCacheTypeAll)) {
                        cacheData = [cacheSerializer cacheDataWithImage:transformedImage originalData:(imageWasTransformed ? nil : originalData) imageURL:url];
                    } else {
                        cacheData = (imageWasTransformed ? nil : originalData);
                    }
                    [self storeImage:transformedImage imageData:cacheData forKey:key cacheType:storeCacheType options:options context:context completion:^{
                        [self callCompletionBlockForOperation:operation completion:completedBlock image:transformedImage data:originalData error:nil cacheType:EaseImageCacheTypeNone finished:finished url:url];
                    }];
                } else {
                    [self callCompletionBlockForOperation:operation completion:completedBlock image:transformedImage data:originalData error:nil cacheType:EaseImageCacheTypeNone finished:finished url:url];
                }
            }
        });
    } else {
        [self callCompletionBlockForOperation:operation completion:completedBlock image:originalImage data:originalData error:nil cacheType:EaseImageCacheTypeNone finished:finished url:url];
    }
}

#pragma mark - Helper

- (void)safelyRemoveOperationFromRunning:(nullable EaseWebImageCombinedOperation*)operation {
    if (!operation) {
        return;
    }
    Ease_LOCK(_runningOperationsLock);
    [self.runningOperations removeObject:operation];
    Ease_UNLOCK(_runningOperationsLock);
}

- (void)storeImage:(nullable UIImage *)image
         imageData:(nullable NSData *)data
            forKey:(nullable NSString *)key
         cacheType:(EaseImageCacheType)cacheType
           options:(EaseWebImageOptions)options
           context:(nullable EaseWebImageContext *)context
        completion:(nullable EaseWebImageNoParamsBlock)completion {
    id<EaseImageCache> imageCache;
    if ([context[EaseWebImageContextImageCache] conformsToProtocol:@protocol(EaseImageCache)]) {
        imageCache = context[EaseWebImageContextImageCache];
    } else {
        imageCache = self.imageCache;
    }
    BOOL waitStoreCache = Ease_OPTIONS_CONTAINS(options, EaseWebImageWaitStoreCache);
    // Check whether we should wait the store cache finished. If not, callback immediately
    [imageCache storeImage:image imageData:data forKey:key cacheType:cacheType completion:^{
        if (waitStoreCache) {
            if (completion) {
                completion();
            }
        }
    }];
    if (!waitStoreCache) {
        if (completion) {
            completion();
        }
    }
}

- (void)callCompletionBlockForOperation:(nullable EaseWebImageCombinedOperation*)operation
                             completion:(nullable EaseInternalCompletionBlock)completionBlock
                                  error:(nullable NSError *)error
                                    url:(nullable NSURL *)url {
    [self callCompletionBlockForOperation:operation completion:completionBlock image:nil data:nil error:error cacheType:EaseImageCacheTypeNone finished:YES url:url];
}

- (void)callCompletionBlockForOperation:(nullable EaseWebImageCombinedOperation*)operation
                             completion:(nullable EaseInternalCompletionBlock)completionBlock
                                  image:(nullable UIImage *)image
                                   data:(nullable NSData *)data
                                  error:(nullable NSError *)error
                              cacheType:(EaseImageCacheType)cacheType
                               finished:(BOOL)finished
                                    url:(nullable NSURL *)url {
    dispatch_main_async_safe(^{
        if (completionBlock) {
            completionBlock(image, data, error, cacheType, finished, url);
        }
    });
}

- (BOOL)shouldBlockFailedURLWithURL:(nonnull NSURL *)url
                              error:(nonnull NSError *)error
                            options:(EaseWebImageOptions)options
                            context:(nullable EaseWebImageContext *)context {
    id<EaseImageLoader> imageLoader;
    if ([context[EaseWebImageContextImageLoader] conformsToProtocol:@protocol(EaseImageLoader)]) {
        imageLoader = context[EaseWebImageContextImageLoader];
    } else {
        imageLoader = self.imageLoader;
    }
    // Check whether we should block failed url
    BOOL shouldBlockFailedURL;
    if ([self.delegate respondsToSelector:@selector(imageManager:shouldBlockFailedURL:withError:)]) {
        shouldBlockFailedURL = [self.delegate imageManager:self shouldBlockFailedURL:url withError:error];
    } else {
        if ([imageLoader respondsToSelector:@selector(shouldBlockFailedURLWithURL:error:options:context:)]) {
            shouldBlockFailedURL = [imageLoader shouldBlockFailedURLWithURL:url error:error options:options context:context];
        } else {
            shouldBlockFailedURL = [imageLoader shouldBlockFailedURLWithURL:url error:error];
        }
    }
    
    return shouldBlockFailedURL;
}

- (EaseWebImageOptionsResult *)processedResultForURL:(NSURL *)url options:(EaseWebImageOptions)options context:(EaseWebImageContext *)context {
    EaseWebImageOptionsResult *result;
    EaseWebImageMutableContext *mutableContext = [EaseWebImageMutableContext dictionary];
    
    // Image Transformer from manager
    if (!context[EaseWebImageContextImageTransformer]) {
        id<EaseImageTransformer> transformer = self.transformer;
        [mutableContext setValue:transformer forKey:EaseWebImageContextImageTransformer];
    }
    // Cache key filter from manager
    if (!context[EaseWebImageContextCacheKeyFilter]) {
        id<EaseWebImageCacheKeyFilter> cacheKeyFilter = self.cacheKeyFilter;
        [mutableContext setValue:cacheKeyFilter forKey:EaseWebImageContextCacheKeyFilter];
    }
    // Cache serializer from manager
    if (!context[EaseWebImageContextCacheSerializer]) {
        id<EaseWebImageCacheSerializer> cacheSerializer = self.cacheSerializer;
        [mutableContext setValue:cacheSerializer forKey:EaseWebImageContextCacheSerializer];
    }
    
    if (mutableContext.count > 0) {
        if (context) {
            [mutableContext addEntriesFromDictionary:context];
        }
        context = [mutableContext copy];
    }
    
    // Apply options processor
    if (self.optionsProcessor) {
        result = [self.optionsProcessor processedResultForURL:url options:options context:context];
    }
    if (!result) {
        // Use default options result
        result = [[EaseWebImageOptionsResult alloc] initWithOptions:options context:context];
    }
    
    return result;
}

@end


@implementation EaseWebImageCombinedOperation

- (void)cancel {
    @synchronized(self) {
        if (self.isCancelled) {
            return;
        }
        self.cancelled = YES;
        if (self.cacheOperation) {
            [self.cacheOperation cancel];
            self.cacheOperation = nil;
        }
        if (self.loaderOperation) {
            [self.loaderOperation cancel];
            self.loaderOperation = nil;
        }
        [self.manager safelyRemoveOperationFromRunning:self];
    }
}

@end
