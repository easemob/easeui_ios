/*
 * This file is part of the EaseWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "EaseWebImageCompat.h"
#import "EaseWebImageDefine.h"
#import "EaseWebImageManager.h"
#import "EaseWebImageTransition.h"
#import "EaseWebImageIndicator.h"

/**
 The value specify that the image progress unit count cannot be determined because the progressBlock is not been called.
 */
FOUNDATION_EXPORT const int64_t EaseWebImageProgressUnitCountUnknown; /* 1LL */

typedef void(^EaseSetImageBlock)(UIImage * _Nullable image, NSData * _Nullable imageData, EaseImageCacheType cacheType, NSURL * _Nullable imageURL);

/**
 Integrates EaseWebImage async downloading and caching of remote images with UIView subclass.
 */
@interface UIView (EaseWebCache)

/**
 * Get the current image URL.
 *
 * @note Note that because of the limitations of categories this property can get out of sync if you use setImage: directly.
 */
@property (nonatomic, strong, readonly, nullable) NSURL *ease_imageURL;

/**
 * Get the current image operation key. Operation key is used to identify the different queries for one view instance (like UIButton).
 * See more about this in `EaseWebImageContextSetImageOperationKey`.
 * If you cancel current image load, the key will be set to nil.
 * @note You can use method `UIView+EaseWebCacheOperation` to investigate different queries' operation.
 */
@property (nonatomic, strong, readonly, nullable) NSString *ease_latestOperationKey;

/**
 * The current image loading progress associated to the view. The unit count is the received size and excepted size of download.
 * The `totalUnitCount` and `completedUnitCount` will be reset to 0 after a new image loading start (change from current queue). And they will be set to `EaseWebImageProgressUnitCountUnknown` if the progressBlock not been called but the image loading success to mark the progress finished (change from main queue).
 * @note You can use Key-Value Observing on the progress, but you should take care that the change to progress is from a background queue during download(the same as progressBlock). If you want to using KVO and update the UI, make sure to dispatch on the main queue. And it's recommend to use some KVO libs like KVOController because it's more safe and easy to use.
 * @note The getter will create a progress instance if the value is nil. But by default, we don't create one. If you need to use Key-Value Observing, you must trigger the getter or set a custom progress instance before the loading start. The default value is nil.
 * @note Note that because of the limitations of categories this property can get out of sync if you update the progress directly.
 */
@property (nonatomic, strong, null_resettable) NSProgress *ease_imageProgress;

/**
 * Set the imageView `image` with an `url` and optionally a placeholder image.
 *
 * The download is asynchronous and cached.
 *
 * @param url            The url for the image.
 * @param placeholder    The image to be set initially, until the image request finishes.
 * @param options        The options to use when downloading the image. @see EaseWebImageOptions for the possible values.
 * @param context        A context contains different options to perform specify changes or processes, see `EaseWebImageContextOption`. This hold the extra objects which `options` enum can not hold.
 * @param setImageBlock  Block used for custom set image code. If not provide, use the built-in set image code (supports `UIImageView/NSImageView` and `UIButton/NSButton` currently)
 * @param progressBlock  A block called while image is downloading
 *                       @note the progress block is executed on a background queue
 * @param completedBlock A block called when operation has been completed.
 *   This block has no return value and takes the requested UIImage as first parameter and the NSData representation as second parameter.
 *   In case of error the image parameter is nil and the third parameter may contain an NSError.
 *
 *   The forth parameter is an `EaseImageCacheType` enum indicating if the image was retrieved from the local cache
 *   or from the memory cache or from the network.
 *
 *   The fifth parameter normally is always YES. However, if you provide EaseWebImageAvoidAutoSetImage with EaseWebImageProgressiveLoad options to enable progressive downloading and set the image yourself. This block is thus called repeatedly with a partial image. When image is fully downloaded, the
 *   block is called a last time with the full image and the last parameter set to YES.
 *
 *   The last parameter is the original image URL
 */
- (void)ease_internalSetImageWithURL:(nullable NSURL *)url
                  placeholderImage:(nullable UIImage *)placeholder
                           options:(EaseWebImageOptions)options
                           context:(nullable EaseWebImageContext *)context
                     setImageBlock:(nullable EaseSetImageBlock)setImageBlock
                          progress:(nullable EaseImageLoaderProgressBlock)progressBlock
                         completed:(nullable EaseInternalCompletionBlock)completedBlock;

/**
 * Cancel the current image load
 */
- (void)Ease_cancelCurrentImageLoad;

#if Ease_UIKIT || Ease_MAC

#pragma mark - Image Transition

/**
 The image transition when image load finished. See `EaseWebImageTransition`.
 If you specify nil, do not do transition. Defaults to nil.
 */
@property (nonatomic, strong, nullable) EaseWebImageTransition *ease_imageTransition;

#pragma mark - Image Indicator

/**
 The image indicator during the image loading. If you do not need indicator, specify nil. Defaults to nil
 The setter will remove the old indicator view and add new indicator view to current view's subview.
 @note Because this is UI related, you should access only from the main queue.
 */
@property (nonatomic, strong, nullable) id<EaseWebImageIndicator> ease_imageIndicator;

#endif

@end
