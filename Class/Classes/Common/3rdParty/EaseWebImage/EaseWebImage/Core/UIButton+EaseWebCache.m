/*
 * This file is part of the EaseWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIButton+EaseWebCache.h"

#if Ease_UIKIT

#import "objc/runtime.h"
#import "UIView+EaseWebCacheOperation.h"
#import "UIView+EaseWebCache.h"
#import "EaseInternalMacros.h"

static char imageURLStorageKey;

typedef NSMutableDictionary<NSString *, NSURL *> EaseStateImageURLDictionary;

static inline NSString * imageURLKeyForState(UIControlState state) {
    return [NSString stringWithFormat:@"image_%lu", (unsigned long)state];
}

static inline NSString * backgroundImageURLKeyForState(UIControlState state) {
    return [NSString stringWithFormat:@"backgroundImage_%lu", (unsigned long)state];
}

static inline NSString * imageOperationKeyForState(UIControlState state) {
    return [NSString stringWithFormat:@"UIButtonImageOperation%lu", (unsigned long)state];
}

static inline NSString * backgroundImageOperationKeyForState(UIControlState state) {
    return [NSString stringWithFormat:@"UIButtonBackgroundImageOperation%lu", (unsigned long)state];
}

@implementation UIButton (EaseWebCache)

#pragma mark - Image

- (nullable NSURL *)ease_currentImageURL {
    NSURL *url = self.Ease_imageURLStorage[imageURLKeyForState(self.state)];

    if (!url) {
        url = self.Ease_imageURLStorage[imageURLKeyForState(UIControlStateNormal)];
    }

    return url;
}

- (nullable NSURL *)Ease_imageURLForState:(UIControlState)state {
    return self.Ease_imageURLStorage[imageURLKeyForState(state)];
}

- (void)Ease_setImageWithURL:(nullable NSURL *)url forState:(UIControlState)state {
    [self Ease_setImageWithURL:url forState:state placeholderImage:nil options:0 completed:nil];
}

- (void)Ease_setImageWithURL:(nullable NSURL *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder {
    [self Ease_setImageWithURL:url forState:state placeholderImage:placeholder options:0 completed:nil];
}

- (void)Ease_setImageWithURL:(nullable NSURL *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder options:(EaseWebImageOptions)options {
    [self Ease_setImageWithURL:url forState:state placeholderImage:placeholder options:options progress:nil completed:nil];
}

- (void)Ease_setImageWithURL:(nullable NSURL *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder options:(EaseWebImageOptions)options context:(nullable EaseWebImageContext *)context {
    [self Ease_setImageWithURL:url forState:state placeholderImage:placeholder options:options context:context progress:nil completed:nil];
}

- (void)Ease_setImageWithURL:(nullable NSURL *)url forState:(UIControlState)state completed:(nullable EaseExternalCompletionBlock)completedBlock {
    [self Ease_setImageWithURL:url forState:state placeholderImage:nil options:0 completed:completedBlock];
}

- (void)Ease_setImageWithURL:(nullable NSURL *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder completed:(nullable EaseExternalCompletionBlock)completedBlock {
    [self Ease_setImageWithURL:url forState:state placeholderImage:placeholder options:0 completed:completedBlock];
}

- (void)Ease_setImageWithURL:(nullable NSURL *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder options:(EaseWebImageOptions)options completed:(nullable EaseExternalCompletionBlock)completedBlock {
    [self Ease_setImageWithURL:url forState:state placeholderImage:placeholder options:options progress:nil completed:completedBlock];
}

- (void)Ease_setImageWithURL:(nullable NSURL *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder options:(EaseWebImageOptions)options progress:(nullable EaseImageLoaderProgressBlock)progressBlock completed:(nullable EaseExternalCompletionBlock)completedBlock {
    [self Ease_setImageWithURL:url forState:state placeholderImage:placeholder options:options context:nil progress:progressBlock completed:completedBlock];
}

- (void)Ease_setImageWithURL:(nullable NSURL *)url
                  forState:(UIControlState)state
          placeholderImage:(nullable UIImage *)placeholder
                   options:(EaseWebImageOptions)options
                   context:(nullable EaseWebImageContext *)context
                  progress:(nullable EaseImageLoaderProgressBlock)progressBlock
                 completed:(nullable EaseExternalCompletionBlock)completedBlock {
    if (!url) {
        [self.Ease_imageURLStorage removeObjectForKey:imageURLKeyForState(state)];
    } else {
        self.Ease_imageURLStorage[imageURLKeyForState(state)] = url;
    }
    
    EaseWebImageMutableContext *mutableContext;
    if (context) {
        mutableContext = [context mutableCopy];
    } else {
        mutableContext = [NSMutableDictionary dictionary];
    }
    mutableContext[EaseWebImageContextSetImageOperationKey] = imageOperationKeyForState(state);
    @weakify(self);
    [self ease_internalSetImageWithURL:url
                    placeholderImage:placeholder
                             options:options
                             context:mutableContext
                       setImageBlock:^(UIImage * _Nullable image, NSData * _Nullable imageData, EaseImageCacheType cacheType, NSURL * _Nullable imageURL) {
                           @strongify(self);
                           [self setImage:image forState:state];
                       }
                            progress:progressBlock
                           completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, EaseImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                               if (completedBlock) {
                                   completedBlock(image, error, cacheType, imageURL);
                               }
                           }];
}

#pragma mark - Background Image

- (nullable NSURL *)ease_currentBackgroundImageURL {
    NSURL *url = self.Ease_imageURLStorage[backgroundImageURLKeyForState(self.state)];
    
    if (!url) {
        url = self.Ease_imageURLStorage[backgroundImageURLKeyForState(UIControlStateNormal)];
    }
    
    return url;
}

- (nullable NSURL *)Ease_backgroundImageURLForState:(UIControlState)state {
    return self.Ease_imageURLStorage[backgroundImageURLKeyForState(state)];
}

- (void)Ease_setBackgroundImageWithURL:(nullable NSURL *)url forState:(UIControlState)state {
    [self Ease_setBackgroundImageWithURL:url forState:state placeholderImage:nil options:0 completed:nil];
}

- (void)Ease_setBackgroundImageWithURL:(nullable NSURL *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder {
    [self Ease_setBackgroundImageWithURL:url forState:state placeholderImage:placeholder options:0 completed:nil];
}

- (void)Ease_setBackgroundImageWithURL:(nullable NSURL *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder options:(EaseWebImageOptions)options {
    [self Ease_setBackgroundImageWithURL:url forState:state placeholderImage:placeholder options:options progress:nil completed:nil];
}

- (void)Ease_setBackgroundImageWithURL:(nullable NSURL *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder options:(EaseWebImageOptions)options context:(nullable EaseWebImageContext *)context {
    [self Ease_setBackgroundImageWithURL:url forState:state placeholderImage:placeholder options:options context:context progress:nil completed:nil];
}

- (void)Ease_setBackgroundImageWithURL:(nullable NSURL *)url forState:(UIControlState)state completed:(nullable EaseExternalCompletionBlock)completedBlock {
    [self Ease_setBackgroundImageWithURL:url forState:state placeholderImage:nil options:0 completed:completedBlock];
}

- (void)Ease_setBackgroundImageWithURL:(nullable NSURL *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder completed:(nullable EaseExternalCompletionBlock)completedBlock {
    [self Ease_setBackgroundImageWithURL:url forState:state placeholderImage:placeholder options:0 completed:completedBlock];
}

- (void)Ease_setBackgroundImageWithURL:(nullable NSURL *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder options:(EaseWebImageOptions)options completed:(nullable EaseExternalCompletionBlock)completedBlock {
    [self Ease_setBackgroundImageWithURL:url forState:state placeholderImage:placeholder options:options progress:nil completed:completedBlock];
}

- (void)Ease_setBackgroundImageWithURL:(nullable NSURL *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder options:(EaseWebImageOptions)options progress:(nullable EaseImageLoaderProgressBlock)progressBlock completed:(nullable EaseExternalCompletionBlock)completedBlock {
    [self Ease_setBackgroundImageWithURL:url forState:state placeholderImage:placeholder options:options context:nil progress:progressBlock completed:completedBlock];
}

- (void)Ease_setBackgroundImageWithURL:(nullable NSURL *)url
                            forState:(UIControlState)state
                    placeholderImage:(nullable UIImage *)placeholder
                             options:(EaseWebImageOptions)options
                             context:(nullable EaseWebImageContext *)context
                            progress:(nullable EaseImageLoaderProgressBlock)progressBlock
                           completed:(nullable EaseExternalCompletionBlock)completedBlock {
    if (!url) {
        [self.Ease_imageURLStorage removeObjectForKey:backgroundImageURLKeyForState(state)];
    } else {
        self.Ease_imageURLStorage[backgroundImageURLKeyForState(state)] = url;
    }
    
    EaseWebImageMutableContext *mutableContext;
    if (context) {
        mutableContext = [context mutableCopy];
    } else {
        mutableContext = [NSMutableDictionary dictionary];
    }
    mutableContext[EaseWebImageContextSetImageOperationKey] = backgroundImageOperationKeyForState(state);
    @weakify(self);
    [self ease_internalSetImageWithURL:url
                    placeholderImage:placeholder
                             options:options
                             context:mutableContext
                       setImageBlock:^(UIImage * _Nullable image, NSData * _Nullable imageData, EaseImageCacheType cacheType, NSURL * _Nullable imageURL) {
                           @strongify(self);
                           [self setBackgroundImage:image forState:state];
                       }
                            progress:progressBlock
                           completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, EaseImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                               if (completedBlock) {
                                   completedBlock(image, error, cacheType, imageURL);
                               }
                           }];
}

#pragma mark - Cancel

- (void)Ease_cancelImageLoadForState:(UIControlState)state {
    [self Ease_cancelImageLoadOperationWithKey:imageOperationKeyForState(state)];
}

- (void)Ease_cancelBackgroundImageLoadForState:(UIControlState)state {
    [self Ease_cancelImageLoadOperationWithKey:backgroundImageOperationKeyForState(state)];
}

#pragma mark - Private

- (EaseStateImageURLDictionary *)Ease_imageURLStorage {
    EaseStateImageURLDictionary *storage = objc_getAssociatedObject(self, &imageURLStorageKey);
    if (!storage) {
        storage = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, &imageURLStorageKey, storage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    return storage;
}

@end

#endif
