/*
 * This file is part of the EaseWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <Foundation/Foundation.h>
#import "EaseWebImageCompat.h"
#import "EaseWebImageDefine.h"
#import "EaseImageCacheConfig.h"
#import "EaseImageCacheDefine.h"
#import "EaseMemoryCache.h"
#import "EaseDiskCache.h"

/// Image Cache Options
typedef NS_OPTIONS(NSUInteger, EaseImageCacheOptions) {
    /**
     * By default, we do not query image data when the image is already cached in memory. This Easek can force to query image data at the same time. However, this query is asynchronously unless you specify `EaseImageCacheQueryMemoryDataSync`
     */
    EaseImageCacheQueryMemoryData = 1 << 0,
    /**
     * By default, when you only specify `EaseImageCacheQueryMemoryData`, we query the memory image data asynchronously. Combined this Easek as well to query the memory image data synchronously.
     */
    EaseImageCacheQueryMemoryDataSync = 1 << 1,
    /**
     * By default, when the memory cache miss, we query the disk cache asynchronously. This Easek can force to query disk cache (when memory cache miss) synchronously.
     @note These 3 query options can be combined together. For the full list about these Easeks combination, see wiki page.
     */
    EaseImageCacheQueryDiskDataSync = 1 << 2,
    /**
     * By default, images are decoded respecting their original size. On iOS, this flag will scale down the
     * images to a size compatible with the constrained memory of devices.
     */
    EaseImageCacheScaleDownLargeImages = 1 << 3,
    /**
     * By default, we will decode the image in the background during cache query and download from the network. This can help to improve performance because when rendering image on the screen, it need to be firstly decoded. But this happen on the main queue by Core Animation.
     * However, this process may increase the memory usage as well. If you are experiencing a issue due to excessive memory consumption, This flag can prevent decode the image.
     */
    EaseImageCacheAvoidDecodeImage = 1 << 4,
    /**
     * By default, we decode the animated image. This flag can force decode the first frame only and produce the static image.
     */
    EaseImageCacheDecodeFirstFrameOnly = 1 << 5,
    /**
     * By default, for `EaseAnimatedImage`, we decode the animated image frame during rendering to reduce memory usage. This flag actually trigger `preloadAllAnimatedImageFrames = YES` after image load from disk cache
     */
    EaseImageCachePreloadAllFrames = 1 << 6,
    /**
     * By default, when you use `EaseWebImageContextAnimatedImageClass` context option (like using `EaseAnimatedImageView` which designed to use `EaseAnimatedImage`), we may still use `UIImage` when the memory cache hit, or image decoder is not available, to behave as a fallback solution.
     * Using this option, can ensure we always produce image with your provided class. If failed, an error with code `EaseWebImageErrorBadImageData` will be used.
     * Note this options is not compatible with `EaseImageCacheDecodeFirstFrameOnly`, which always produce a UIImage/NSImage.
     */
    EaseImageCacheMatchAnimatedImageClass = 1 << 7,
};

/**
 * EaseImageCache maintains a memory cache and a disk cache. Disk cache write operations are performed
 * asynchronous so it doesn’t add unnecessary latency to the UI.
 */
@interface EaseImageCache : NSObject

#pragma mark - Properties

/**
 *  Cache Config object - storing all kind of settings.
 *  The property is copy so change of current config will not accidentally affect other cache's config.
 */
@property (nonatomic, copy, nonnull, readonly) EaseImageCacheConfig *config;

/**
 * The memory cache implementation object used for current image cache.
 * By default we use `EaseMemoryCache` class, you can also use this to call your own implementation class method.
 * @note To customize this class, check `EaseImageCacheConfig.memoryCacheClass` property.
 */
@property (nonatomic, strong, readonly, nonnull) id<EaseMemoryCache> memoryCache;

/**
 * The disk cache implementation object used for current image cache.
 * By default we use `EaseMemoryCache` class, you can also use this to call your own implementation class method.
 * @note To customize this class, check `EaseImageCacheConfig.diskCacheClass` property.
 * @warning When calling method about read/write in disk cache, be sure to either make your disk cache implementation IO-safe or using the same access queue to avoid issues.
 */
@property (nonatomic, strong, readonly, nonnull) id<EaseDiskCache> diskCache;

/**
 *  The disk cache's root path
 */
@property (nonatomic, copy, nonnull, readonly) NSString *diskCachePath;

/**
 *  The additional disk cache path to check if the query from disk cache not exist;
 *  The `key` param is the image cache key. The returned file path will be used to load the disk cache. If return nil, ignore it.
 *  Useful if you want to bundle pre-loaded images with your app
 */
@property (nonatomic, copy, nullable) EaseImageCacheAdditionalCachePathBlock additionalCachePathBlock;

#pragma mark - Singleton and initialization

/**
 * Returns global shared cache instance
 */
@property (nonatomic, class, readonly, nonnull) EaseImageCache *sharedImageCache;

/**
 * Control the default disk cache directory. This will effect all the EaseImageCache instance created after modification, even for shared image cache.
 * This can be used to share the same disk cache with the App and App Extension (Today/Notification Widget) using `- [NSFileManager.containerURLForSecurityApplicationGroupIdentifier:]`.
 * @note If you pass nil, the value will be reset to `~/Library/Caches/com.hackemist.EaseImageCache`.
 * @note We still preserve the `namespace` arg, which means, if you change this property into `/path/to/use`,  the `EaseImageCache.sharedImageCache.diskCachePath` should be `/path/to/use/default` because shared image cache use `default` as namespace.
 * Defaults to nil.
 */
@property (nonatomic, class, readwrite, null_resettable) NSString *defaultDiskCacheDirectory;

/**
 * Init a new cache store with a specific namespace
 * The final disk cache directory should looks like ($directory/$namespace). And the default config of shared cache, should result in (~/Library/Caches/com.hackemist.EaseImageCache/default/)
 *
 * @param ns The namespace to use for this cache store
 */
- (nonnull instancetype)initWithNamespace:(nonnull NSString *)ns;

/**
 * Init a new cache store with a specific namespace and directory.
 * The final disk cache directory should looks like ($directory/$namespace). And the default config of shared cache, should result in (~/Library/Caches/com.hackemist.EaseImageCache/default/)
 *
 * @param ns        The namespace to use for this cache store
 * @param directory Directory to cache disk images in
 */
- (nonnull instancetype)initWithNamespace:(nonnull NSString *)ns
                       diskCacheDirectory:(nullable NSString *)directory;

/**
 * Init a new cache store with a specific namespace, directory and config.
 * The final disk cache directory should looks like ($directory/$namespace). And the default config of shared cache, should result in (~/Library/Caches/com.hackemist.EaseImageCache/default/)
 *
 * @param ns          The namespace to use for this cache store
 * @param directory   Directory to cache disk images in
 * @param config      The cache config to be used to create the cache. You can provide custom memory cache or disk cache class in the cache config
 */
- (nonnull instancetype)initWithNamespace:(nonnull NSString *)ns
                       diskCacheDirectory:(nullable NSString *)directory
                                   config:(nullable EaseImageCacheConfig *)config NS_DESIGNATED_INITIALIZER;

#pragma mark - Cache paths

/**
 Get the cache path for a certain key
 
 @param key The unique image cache key
 @return The cache path. You can check `lastPathComponent` to grab the file name.
 */
- (nullable NSString *)cachePathForKey:(nullable NSString *)key;

#pragma mark - Store Ops

/**
 * Asynchronously store an image into memory and disk cache at the given key.
 *
 * @param image           The image to store
 * @param key             The unique image cache key, usually it's image absolute URL
 * @param completionBlock A block executed after the operation is finished
 */
- (void)storeImage:(nullable UIImage *)image
            forKey:(nullable NSString *)key
        completion:(nullable EaseWebImageNoParamsBlock)completionBlock;

/**
 * Asynchronously store an image into memory and disk cache at the given key.
 *
 * @param image           The image to store
 * @param key             The unique image cache key, usually it's image absolute URL
 * @param toDisk          Store the image to disk cache if YES. If NO, the completion block is called synchronously
 * @param completionBlock A block executed after the operation is finished
 * @note If no image data is provided and encode to disk, we will try to detect the image format (using either `Ease_imageFormat` or `EaseAnimatedImage` protocol method) and animation status, to choose the best matched format, including GIF, JPEG or PNG.
 */
- (void)storeImage:(nullable UIImage *)image
            forKey:(nullable NSString *)key
            toDisk:(BOOL)toDisk
        completion:(nullable EaseWebImageNoParamsBlock)completionBlock;

/**
 * Asynchronously store an image into memory and disk cache at the given key.
 *
 * @param image           The image to store
 * @param imageData       The image data as returned by the server, this representation will be used for disk storage
 *                        instead of converting the given image object into a storable/compressed image format in order
 *                        to save quality and CPU
 * @param key             The unique image cache key, usually it's image absolute URL
 * @param toDisk          Store the image to disk cache if YES. If NO, the completion block is called synchronously
 * @param completionBlock A block executed after the operation is finished
 * @note If no image data is provided and encode to disk, we will try to detect the image format (using either `Ease_imageFormat` or `EaseAnimatedImage` protocol method) and animation status, to choose the best matched format, including GIF, JPEG or PNG.
 */
- (void)storeImage:(nullable UIImage *)image
         imageData:(nullable NSData *)imageData
            forKey:(nullable NSString *)key
            toDisk:(BOOL)toDisk
        completion:(nullable EaseWebImageNoParamsBlock)completionBlock;

/**
 * Synchronously store image into memory cache at the given key.
 *
 * @param image  The image to store
 * @param key    The unique image cache key, usually it's image absolute URL
 */
- (void)storeImageToMemory:(nullable UIImage*)image
                    forKey:(nullable NSString *)key;

/**
 * Synchronously store image data into disk cache at the given key.
 *
 * @param imageData  The image data to store
 * @param key        The unique image cache key, usually it's image absolute URL
 */
- (void)storeImageDataToDisk:(nullable NSData *)imageData
                      forKey:(nullable NSString *)key;


#pragma mark - Contains and Check Ops

/**
 *  Asynchronously check if image exists in disk cache already (does not load the image)
 *
 *  @param key             the key describing the url
 *  @param completionBlock the block to be executed when the check is done.
 *  @note the completion block will be always executed on the main queue
 */
- (void)diskImageExistsWithKey:(nullable NSString *)key completion:(nullable EaseImageCacheCheckCompletionBlock)completionBlock;

/**
 *  Synchronously check if image data exists in disk cache already (does not load the image)
 *
 *  @param key             the key describing the url
 */
- (BOOL)diskImageDataExistsWithKey:(nullable NSString *)key;

#pragma mark - Query and Retrieve Ops

/**
 * Synchronously query the image data for the given key in disk cache. You can decode the image data to image after loaded.
 *
 *  @param key The unique key used to store the wanted image
 *  @return The image data for the given key, or nil if not found.
 */
- (nullable NSData *)diskImageDataForKey:(nullable NSString *)key;

/**
 * Asynchronously query the image data for the given key in disk cache. You can decode the image data to image after loaded.
 *
 *  @param key The unique key used to store the wanted image
 *  @param completionBlock the block to be executed when the query is done.
 *  @note the completion block will be always executed on the main queue
 */
- (void)diskImageDataQueryForKey:(nullable NSString *)key completion:(nullable EaseImageCacheQueryDataCompletionBlock)completionBlock;

/**
 * Asynchronously queries the cache with operation and call the completion when done.
 *
 * @param key       The unique key used to store the wanted image. If you want transformed or thumbnail image, calculate the key with `EaseTransformedKeyForKey`, `EaseThumbnailedKeyForKey`, or generate the cache key from url with `cacheKeyForURL:context:`.
 * @param doneBlock The completion block. Will not get called if the operation is cancelled
 *
 * @return a NSOperation instance containing the cache op
 */
- (nullable NSOperation *)queryCacheOperationForKey:(nullable NSString *)key done:(nullable EaseImageCacheQueryCompletionBlock)doneBlock;

/**
 * Asynchronously queries the cache with operation and call the completion when done.
 *
 * @param key       The unique key used to store the wanted image. If you want transformed or thumbnail image, calculate the key with `EaseTransformedKeyForKey`, `EaseThumbnailedKeyForKey`, or generate the cache key from url with `cacheKeyForURL:context:`.
 * @param options   A Easek to specify options to use for this cache query
 * @param doneBlock The completion block. Will not get called if the operation is cancelled
 *
 * @return a NSOperation instance containing the cache op
 */
- (nullable NSOperation *)queryCacheOperationForKey:(nullable NSString *)key options:(EaseImageCacheOptions)options done:(nullable EaseImageCacheQueryCompletionBlock)doneBlock;

/**
 * Asynchronously queries the cache with operation and call the completion when done.
 *
 * @param key       The unique key used to store the wanted image. If you want transformed or thumbnail image, calculate the key with `EaseTransformedKeyForKey`, `EaseThumbnailedKeyForKey`, or generate the cache key from url with `cacheKeyForURL:context:`.
 * @param options   A Easek to specify options to use for this cache query
 * @param context   A context contains different options to perform specify changes or processes, see `EaseWebImageContextOption`. This hold the extra objects which `options` enum can not hold.
 * @param doneBlock The completion block. Will not get called if the operation is cancelled
 *
 * @return a NSOperation instance containing the cache op
 */
- (nullable NSOperation *)queryCacheOperationForKey:(nullable NSString *)key options:(EaseImageCacheOptions)options context:(nullable EaseWebImageContext *)context done:(nullable EaseImageCacheQueryCompletionBlock)doneBlock;

/**
 * Asynchronously queries the cache with operation and call the completion when done.
 *
 * @param key       The unique key used to store the wanted image. If you want transformed or thumbnail image, calculate the key with `EaseTransformedKeyForKey`, `EaseThumbnailedKeyForKey`, or generate the cache key from url with `cacheKeyForURL:context:`.
 * @param options   A Easek to specify options to use for this cache query
 * @param context   A context contains different options to perform specify changes or processes, see `EaseWebImageContextOption`. This hold the extra objects which `options` enum can not hold.
 * @param queryCacheType Specify where to query the cache from. By default we use `.all`, which means both memory cache and disk cache. You can choose to query memory only or disk only as well. Pass `.none` is invalid and callback with nil immediately.
 * @param doneBlock The completion block. Will not get called if the operation is cancelled
 *
 * @return a NSOperation instance containing the cache op
 */
- (nullable NSOperation *)queryCacheOperationForKey:(nullable NSString *)key options:(EaseImageCacheOptions)options context:(nullable EaseWebImageContext *)context cacheType:(EaseImageCacheType)queryCacheType done:(nullable EaseImageCacheQueryCompletionBlock)doneBlock;

/**
 * Synchronously query the memory cache.
 *
 * @param key The unique key used to store the image
 * @return The image for the given key, or nil if not found.
 */
- (nullable UIImage *)imageFromMemoryCacheForKey:(nullable NSString *)key;

/**
 * Synchronously query the disk cache.
 *
 * @param key The unique key used to store the image
 * @return The image for the given key, or nil if not found.
 */
- (nullable UIImage *)imageFromDiskCacheForKey:(nullable NSString *)key;

/**
 * Synchronously query the disk cache. With the options and context which may effect the image generation. (Such as transformer, animated image, thumbnail, etc)
 *
 * @param key The unique key used to store the image
 * @param options   A Easek to specify options to use for this cache query
 * @param context   A context contains different options to perform specify changes or processes, see `EaseWebImageContextOption`. This hold the extra objects which `options` enum can not hold.
 * @return The image for the given key, or nil if not found.
 */
- (nullable UIImage *)imageFromDiskCacheForKey:(nullable NSString *)key options:(EaseImageCacheOptions)options context:(nullable EaseWebImageContext *)context;

/**
 * Synchronously query the cache (memory and or disk) after checking the memory cache.
 *
 * @param key The unique key used to store the image
 * @return The image for the given key, or nil if not found.
 */
- (nullable UIImage *)imageFromCacheForKey:(nullable NSString *)key;

/**
 * Synchronously query the cache (memory and or disk) after checking the memory cache. With the options and context which may effect the image generation. (Such as transformer, animated image, thumbnail, etc)
 *
 * @param key The unique key used to store the image
 * @param options   A Easek to specify options to use for this cache query
 * @param context   A context contains different options to perform specify changes or processes, see `EaseWebImageContextOption`. This hold the extra objects which `options` enum can not hold.
 * @return The image for the given key, or nil if not found.
 */
- (nullable UIImage *)imageFromCacheForKey:(nullable NSString *)key options:(EaseImageCacheOptions)options context:(nullable EaseWebImageContext *)context;

#pragma mark - Remove Ops

/**
 * Asynchronously remove the image from memory and disk cache
 *
 * @param key             The unique image cache key
 * @param completion      A block that should be executed after the image has been removed (optional)
 */
- (void)removeImageForKey:(nullable NSString *)key withCompletion:(nullable EaseWebImageNoParamsBlock)completion;

/**
 * Asynchronously remove the image from memory and optionally disk cache
 *
 * @param key             The unique image cache key
 * @param fromDisk        Also remove cache entry from disk if YES. If NO, the completion block is called synchronously
 * @param completion      A block that should be executed after the image has been removed (optional)
 */
- (void)removeImageForKey:(nullable NSString *)key fromDisk:(BOOL)fromDisk withCompletion:(nullable EaseWebImageNoParamsBlock)completion;

/**
 Synchronously remove the image from memory cache.
 
 @param key The unique image cache key
 */
- (void)removeImageFromMemoryForKey:(nullable NSString *)key;

/**
 Synchronously remove the image from disk cache.
 
 @param key The unique image cache key
 */
- (void)removeImageFromDiskForKey:(nullable NSString *)key;

#pragma mark - Cache clean Ops

/**
 * Synchronously Clear all memory cached images
 */
- (void)clearMemory;

/**
 * Asynchronously clear all disk cached images. Non-blocking method - returns immediately.
 * @param completion    A block that should be executed after cache expiration completes (optional)
 */
- (void)clearDiskOnCompletion:(nullable EaseWebImageNoParamsBlock)completion;

/**
 * Asynchronously remove all expired cached image from disk. Non-blocking method - returns immediately.
 * @param completionBlock A block that should be executed after cache expiration completes (optional)
 */
- (void)deleteOldFilesWithCompletionBlock:(nullable EaseWebImageNoParamsBlock)completionBlock;

#pragma mark - Cache Info

/**
 * Get the total bytes size of images in the disk cache
 */
- (NSUInteger)totalDiskSize;

/**
 * Get the number of images in the disk cache
 */
- (NSUInteger)totalDiskCount;

/**
 * Asynchronously calculate the disk cache's size.
 */
- (void)calculateSizeWithCompletionBlock:(nullable EaseImageCacheCalculateSizeBlock)completionBlock;

@end

/**
 * EaseImageCache is the built-in image cache implementation for web image manager. It adopts `EaseImageCache` protocol to provide the function for web image manager to use for image loading process.
 */
@interface EaseImageCache (EaseImageCache) <EaseImageCache>

@end
