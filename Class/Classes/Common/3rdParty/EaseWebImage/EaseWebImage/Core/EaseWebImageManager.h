/*
 * This file is part of the EaseWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "EaseWebImageCompat.h"
#import "EaseWebImageOperation.h"
#import "EaseImageCacheDefine.h"
#import "EaseImageLoader.h"
#import "EaseImageTransformer.h"
#import "EaseWebImageCacheKeyFilter.h"
#import "EaseWebImageCacheSerializer.h"
#import "EaseWebImageOptionsProcessor.h"

typedef void(^EaseExternalCompletionBlock)(UIImage * _Nullable image, NSError * _Nullable error, EaseImageCacheType cacheType, NSURL * _Nullable imageURL);

typedef void(^EaseInternalCompletionBlock)(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, EaseImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL);

/**
 A combined operation representing the cache and loader operation. You can use it to cancel the load process.
 */
@interface EaseWebImageCombinedOperation : NSObject <EaseWebImageOperation>

/**
 Cancel the current operation, including cache and loader process
 */
- (void)cancel;

/**
 The cache operation from the image cache query
 */
@property (strong, nonatomic, nullable, readonly) id<EaseWebImageOperation> cacheOperation;

/**
 The loader operation from the image loader (such as download operation)
 */
@property (strong, nonatomic, nullable, readonly) id<EaseWebImageOperation> loaderOperation;

@end


@class EaseWebImageManager;

/**
 The manager delegate protocol.
 */
@protocol EaseWebImageManagerDelegate <NSObject>

@optional

/**
 * Controls which image should be downloaded when the image is not found in the cache.
 *
 * @param imageManager The current `EaseWebImageManager`
 * @param imageURL     The url of the image to be downloaded
 *
 * @return Return NO to prevent the downloading of the image on cache misses. If not implemented, YES is implied.
 */
- (BOOL)imageManager:(nonnull EaseWebImageManager *)imageManager shouldDownloadImageForURL:(nonnull NSURL *)imageURL;

/**
 * Controls the complicated logic to mark as failed URLs when download error occur.
 * If the delegate implement this method, we will not use the built-in way to mark URL as failed based on error code;
 @param imageManager The current `EaseWebImageManager`
 @param imageURL The url of the image
 @param error The download error for the url
 @return Whether to block this url or not. Return YES to mark this URL as failed.
 */
- (BOOL)imageManager:(nonnull EaseWebImageManager *)imageManager shouldBlockFailedURL:(nonnull NSURL *)imageURL withError:(nonnull NSError *)error;

@end

/**
 * The EaseWebImageManager is the class behind the UIImageView+EaseWebCache category and likes.
 * It ties the asynchronous downloader (EaseWebImageDownloader) with the image cache store (EaseImageCache).
 * You can use this class directly to benefit from web image downloading with caching in another context than
 * a UIView.
 *
 * Here is a simple example of how to use EaseWebImageManager:
 *
 * @code

EaseWebImageManager *manager = [EaseWebImageManager sharedManager];
[manager loadImageWithURL:imageURL
                  options:0
                 progress:nil
                completed:^(UIImage *image, NSData *data, NSError *error, EaseImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                    if (image) {
                        // do something with image
                    }
                }];

 * @endcode
 */
@interface EaseWebImageManager : NSObject

/**
 * The delegate for manager. Defaults to nil.
 */
@property (weak, nonatomic, nullable) id <EaseWebImageManagerDelegate> delegate;

/**
 * The image cache used by manager to query image cache.
 */
@property (strong, nonatomic, readonly, nonnull) id<EaseImageCache> imageCache;

/**
 * The image loader used by manager to load image.
 */
@property (strong, nonatomic, readonly, nonnull) id<EaseImageLoader> imageLoader;

/**
 The image transformer for manager. It's used for image transform after the image load finished and store the transformed image to cache, see `EaseImageTransformer`.
 Defaults to nil, which means no transform is applied.
 @note This will affect all the load requests for this manager if you provide. However, you can pass `EaseWebImageContextImageTransformer` in context arg to explicitly use that transformer instead.
 */
@property (strong, nonatomic, nullable) id<EaseImageTransformer> transformer;

/**
 * The cache filter is used to convert an URL into a cache key each time EaseWebImageManager need cache key to use image cache.
 *
 * The following example sets a filter in the application delegate that will remove any query-string from the
 * URL before to use it as a cache key:
 *
 * @code
 EaseWebImageManager.sharedManager.cacheKeyFilter =[EaseWebImageCacheKeyFilter cacheKeyFilterWithBlock:^NSString * _Nullable(NSURL * _Nonnull url) {
    url = [[NSURL alloc] initWithScheme:url.scheme host:url.host path:url.path];
    return [url absoluteString];
 }];
 * @endcode
 */
@property (nonatomic, strong, nullable) id<EaseWebImageCacheKeyFilter> cacheKeyFilter;

/**
 * The cache serializer is used to convert the decoded image, the source downloaded data, to the actual data used for storing to the disk cache. If you return nil, means to generate the data from the image instance, see `EaseImageCache`.
 * For example, if you are using WebP images and facing the slow decoding time issue when later retrieving from disk cache again. You can try to encode the decoded image to JPEG/PNG format to disk cache instead of source downloaded data.
 * @note The `image` arg is nonnull, but when you also provide an image transformer and the image is transformed, the `data` arg may be nil, take attention to this case.
 * @note This method is called from a global queue in order to not to block the main thread.
 * @code
 EaseWebImageManager.sharedManager.cacheSerializer = [EaseWebImageCacheSerializer cacheSerializerWithBlock:^NSData * _Nullable(UIImage * _Nonnull image, NSData * _Nullable data, NSURL * _Nullable imageURL) {
    EaseImageFormat format = [NSData Ease_imageFormatForImageData:data];
    switch (format) {
        case EaseImageFormatWebP:
            return image.images ? data : nil;
        default:
            return data;
    }
}];
 * @endcode
 * The default value is nil. Means we just store the source downloaded data to disk cache.
 */
@property (nonatomic, strong, nullable) id<EaseWebImageCacheSerializer> cacheSerializer;

/**
 The options processor is used, to have a global control for all the image request options and context option for current manager.
 @note If you use `transformer`, `cacheKeyFilter` or `cacheSerializer` property of manager, the input context option already apply those properties before passed. This options processor is a better replacement for those property in common usage.
 For example, you can control the global options, based on the URL or original context option like the below code.
 
 @code
 EaseWebImageManager.sharedManager.optionsProcessor = [EaseWebImageOptionsProcessor optionsProcessorWithBlock:^EaseWebImageOptionsResult * _Nullable(NSURL * _Nullable url, EaseWebImageOptions options, EaseWebImageContext * _Nullable context) {
     // Only do animation on `EaseAnimatedImageView`
     if (!context[EaseWebImageContextAnimatedImageClass]) {
        options |= EaseWebImageDecodeFirstFrameOnly;
     }
     // Do not force decode for png url
     if ([url.lastPathComponent isEqualToString:@"png"]) {
        options |= EaseWebImageAvoidDecodeImage;
     }
     // Always use screen scale factor
     EaseWebImageMutableContext *mutableContext = [NSDictionary dictionaryWithDictionary:context];
     mutableContext[EaseWebImageContextImageScaleFactor] = @(UIScreen.mainScreen.scale);
     context = [mutableContext copy];
 
     return [[EaseWebImageOptionsResult alloc] initWithOptions:options context:context];
 }];
 @endcode
 */
@property (nonatomic, strong, nullable) id<EaseWebImageOptionsProcessor> optionsProcessor;

/**
 * Check one or more operations running
 */
@property (nonatomic, assign, readonly, getter=isRunning) BOOL running;

/**
 The default image cache when the manager which is created with no arguments. Such as shared manager or init.
 Defaults to nil. Means using `EaseImageCache.sharedImageCache`
 */
@property (nonatomic, class, nullable) id<EaseImageCache> defaultImageCache;

/**
 The default image loader for manager which is created with no arguments. Such as shared manager or init.
 Defaults to nil. Means using `EaseWebImageDownloader.sharedDownloader`
 */
@property (nonatomic, class, nullable) id<EaseImageLoader> defaultImageLoader;

/**
 * Returns global shared manager instance.
 */
@property (nonatomic, class, readonly, nonnull) EaseWebImageManager *sharedManager;

/**
 * Allows to specify instance of cache and image loader used with image manager.
 * @return new instance of `EaseWebImageManager` with specified cache and loader.
 */
- (nonnull instancetype)initWithCache:(nonnull id<EaseImageCache>)cache loader:(nonnull id<EaseImageLoader>)loader NS_DESIGNATED_INITIALIZER;

/**
 * Downloads the image at the given URL if not present in cache or return the cached version otherwise.
 *
 * @param url            The URL to the image
 * @param options        A Easek to specify options to use for this request
 * @param progressBlock  A block called while image is downloading
 *                       @note the progress block is executed on a background queue
 * @param completedBlock A block called when operation has been completed.
 *
 *   This parameter is required.
 * 
 *   This block has no return value and takes the requested UIImage as first parameter and the NSData representation as second parameter.
 *   In case of error the image parameter is nil and the third parameter may contain an NSError.
 *
 *   The forth parameter is an `EaseImageCacheType` enum indicating if the image was retrieved from the local cache
 *   or from the memory cache or from the network.
 *
 *   The fifth parameter is set to NO when the EaseWebImageProgressiveLoad option is used and the image is
 *   downloading. This block is thus called repeatedly with a partial image. When image is fully downloaded, the
 *   block is called a last time with the full image and the last parameter set to YES.
 *
 *   The last parameter is the original image URL
 *
 * @return Returns an instance of EaseWebImageCombinedOperation, which you can cancel the loading process.
 */
- (nullable EaseWebImageCombinedOperation *)loadImageWithURL:(nullable NSURL *)url
                                                   options:(EaseWebImageOptions)options
                                                  progress:(nullable EaseImageLoaderProgressBlock)progressBlock
                                                 completed:(nonnull EaseInternalCompletionBlock)completedBlock;

/**
 * Downloads the image at the given URL if not present in cache or return the cached version otherwise.
 *
 * @param url            The URL to the image
 * @param options        A Easek to specify options to use for this request
 * @param context        A context contains different options to perform specify changes or processes, see `EaseWebImageContextOption`. This hold the extra objects which `options` enum can not hold.
 * @param progressBlock  A block called while image is downloading
 *                       @note the progress block is executed on a background queue
 * @param completedBlock A block called when operation has been completed.
 *
 * @return Returns an instance of EaseWebImageCombinedOperation, which you can cancel the loading process.
 */
- (nullable EaseWebImageCombinedOperation *)loadImageWithURL:(nullable NSURL *)url
                                                   options:(EaseWebImageOptions)options
                                                   context:(nullable EaseWebImageContext *)context
                                                  progress:(nullable EaseImageLoaderProgressBlock)progressBlock
                                                 completed:(nonnull EaseInternalCompletionBlock)completedBlock;

/**
 * Cancel all current operations
 */
- (void)cancelAll;

/**
 * Remove the specify URL from failed black list.
 * @param url The failed URL.
 */
- (void)removeFailedURL:(nonnull NSURL *)url;

/**
 * Remove all the URL from failed black list.
 */
- (void)removeAllFailedURLs;

/**
 * Return the cache key for a given URL, does not considerate transformer or thumbnail.
 * @note This method does not have context option, only use the url and manager level cacheKeyFilter to generate the cache key.
 */
- (nullable NSString *)cacheKeyForURL:(nullable NSURL *)url;

/**
 * Return the cache key for a given URL and context option.
 * @note The context option like `.thumbnailPixelSize` and `.imageTransformer` will effect the generated cache key, using this if you have those context associated.
*/
- (nullable NSString *)cacheKeyForURL:(nullable NSURL *)url context:(nullable EaseWebImageContext *)context;

@end
