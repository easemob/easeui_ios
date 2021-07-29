/*
 * This file is part of the EaseWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "NSButton+EaseWebCache.h"

#if Ease_MAC

#import "objc/runtime.h"
#import "UIView+EaseWebCacheOperation.h"
#import "UIView+EaseWebCache.h"
#import "EaseInternalMacros.h"

static NSString * const EaseAlternateImageOperationKey = @"NSButtonAlternateImageOperation";

@implementation NSButton (EaseWebCache)

#pragma mark - Image

- (void)Ease_setImageWithURL:(nullable NSURL *)url {
    [self Ease_setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:nil];
}

- (void)Ease_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder {
    [self Ease_setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:nil];
}

- (void)Ease_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(EaseWebImageOptions)options {
    [self Ease_setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:nil];
}

- (void)Ease_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(EaseWebImageOptions)options context:(nullable EaseWebImageContext *)context {
    [self Ease_setImageWithURL:url placeholderImage:placeholder options:options context:context progress:nil completed:nil];
}

- (void)Ease_setImageWithURL:(nullable NSURL *)url completed:(nullable EaseExternalCompletionBlock)completedBlock {
    [self Ease_setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:completedBlock];
}

- (void)Ease_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder completed:(nullable EaseExternalCompletionBlock)completedBlock {
    [self Ease_setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:completedBlock];
}

- (void)Ease_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(EaseWebImageOptions)options completed:(nullable EaseExternalCompletionBlock)completedBlock {
    [self Ease_setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:completedBlock];
}

- (void)Ease_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(EaseWebImageOptions)options progress:(nullable EaseImageLoaderProgressBlock)progressBlock completed:(nullable EaseExternalCompletionBlock)completedBlock {
    [self Ease_setImageWithURL:url placeholderImage:placeholder options:options context:nil progress:progressBlock completed:completedBlock];
}

- (void)Ease_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder
                   options:(EaseWebImageOptions)options
                   context:(nullable EaseWebImageContext *)context
                  progress:(nullable EaseImageLoaderProgressBlock)progressBlock
                 completed:(nullable EaseExternalCompletionBlock)completedBlock {
    self.ease_currentImageURL = url;
    [self Ease_internalSetImageWithURL:url
                    placeholderImage:placeholder
                             options:options
                             context:context
                       setImageBlock:nil
                            progress:progressBlock
                           completed:^(NSImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, EaseImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                               if (completedBlock) {
                                   completedBlock(image, error, cacheType, imageURL);
                               }
                           }];
}

#pragma mark - Alternate Image

- (void)Ease_setAlternateImageWithURL:(nullable NSURL *)url {
    [self Ease_setAlternateImageWithURL:url placeholderImage:nil options:0 progress:nil completed:nil];
}

- (void)Ease_setAlternateImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder {
    [self Ease_setAlternateImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:nil];
}

- (void)Ease_setAlternateImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(EaseWebImageOptions)options {
    [self Ease_setAlternateImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:nil];
}

- (void)Ease_setAlternateImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(EaseWebImageOptions)options context:(nullable EaseWebImageContext *)context {
    [self Ease_setAlternateImageWithURL:url placeholderImage:placeholder options:options context:context progress:nil completed:nil];
}

- (void)Ease_setAlternateImageWithURL:(nullable NSURL *)url completed:(nullable EaseExternalCompletionBlock)completedBlock {
    [self Ease_setAlternateImageWithURL:url placeholderImage:nil options:0 progress:nil completed:completedBlock];
}

- (void)Ease_setAlternateImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder completed:(nullable EaseExternalCompletionBlock)completedBlock {
    [self Ease_setAlternateImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:completedBlock];
}

- (void)Ease_setAlternateImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(EaseWebImageOptions)options completed:(nullable EaseExternalCompletionBlock)completedBlock {
    [self Ease_setAlternateImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:completedBlock];
}

- (void)Ease_setAlternateImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(EaseWebImageOptions)options progress:(nullable EaseImageLoaderProgressBlock)progressBlock completed:(nullable EaseExternalCompletionBlock)completedBlock {
    [self Ease_setAlternateImageWithURL:url placeholderImage:placeholder options:options context:nil progress:progressBlock completed:completedBlock];
}

- (void)Ease_setAlternateImageWithURL:(nullable NSURL *)url
                   placeholderImage:(nullable UIImage *)placeholder
                            options:(EaseWebImageOptions)options
                            context:(nullable EaseWebImageContext *)context
                           progress:(nullable EaseImageLoaderProgressBlock)progressBlock
                          completed:(nullable EaseExternalCompletionBlock)completedBlock {
    self.Ease_currentAlternateImageURL = url;
    
    EaseWebImageMutableContext *mutableContext;
    if (context) {
        mutableContext = [context mutableCopy];
    } else {
        mutableContext = [NSMutableDictionary dictionary];
    }
    mutableContext[EaseWebImageContextSetImageOperationKey] = EaseAlternateImageOperationKey;
    @weakify(self);
    [self Ease_internalSetImageWithURL:url
                    placeholderImage:placeholder
                             options:options
                             context:mutableContext
                       setImageBlock:^(NSImage * _Nullable image, NSData * _Nullable imageData, EaseImageCacheType cacheType, NSURL * _Nullable imageURL) {
                           @strongify(self);
                           self.alternateImage = image;
                       }
                            progress:progressBlock
                           completed:^(NSImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, EaseImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                               if (completedBlock) {
                                   completedBlock(image, error, cacheType, imageURL);
                               }
                           }];
}

#pragma mark - Cancel

- (void)Ease_cancelCurrentImageLoad {
    [self Ease_cancelImageLoadOperationWithKey:NSStringFromClass([self class])];
}

- (void)Ease_cancelCurrentAlternateImageLoad {
    [self Ease_cancelImageLoadOperationWithKey:EaseAlternateImageOperationKey];
}

#pragma mar - Private

- (NSURL *)ease_currentImageURL {
    return objc_getAssociatedObject(self, @selector(ease_currentImageURL));
}

- (void)setEase_currentImageURL:(NSURL *)Ease_currentImageURL {
    objc_setAssociatedObject(self, @selector(Ease_currentImageURL), ease_currentImageURL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSURL *)ease_currentAlternateImageURL {
    return objc_getAssociatedObject(self, @selector(ease_currentAlternateImageURL));
}

- (void)setEase_currentAlternateImageURL:(NSURL *)ease_currentAlternateImageURL {
    objc_setAssociatedObject(self, @selector(ease_currentAlternateImageURL), ease_currentAlternateImageURL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

#endif
