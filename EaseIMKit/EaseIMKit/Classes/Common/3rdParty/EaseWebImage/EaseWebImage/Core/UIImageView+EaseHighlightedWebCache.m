/*
 * This file is part of the EaseWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImageView+EaseHighlightedWebCache.h"

#if Ease_UIKIT

#import "UIView+EaseWebCacheOperation.h"
#import "UIView+EaseWebCache.h"
#import "EaseInternalMacros.h"

static NSString * const EaseHighlightedImageOperationKey = @"UIImageViewImageOperationHighlighted";

@implementation UIImageView (EaseHighlightedWebCache)

- (void)Ease_setHighlightedImageWithURL:(nullable NSURL *)url {
    [self Ease_setHighlightedImageWithURL:url options:0 progress:nil completed:nil];
}

- (void)Ease_setHighlightedImageWithURL:(nullable NSURL *)url options:(EaseWebImageOptions)options {
    [self Ease_setHighlightedImageWithURL:url options:options progress:nil completed:nil];
}

- (void)Ease_setHighlightedImageWithURL:(nullable NSURL *)url options:(EaseWebImageOptions)options context:(nullable EaseWebImageContext *)context {
    [self Ease_setHighlightedImageWithURL:url options:options context:context progress:nil completed:nil];
}

- (void)Ease_setHighlightedImageWithURL:(nullable NSURL *)url completed:(nullable EaseExternalCompletionBlock)completedBlock {
    [self Ease_setHighlightedImageWithURL:url options:0 progress:nil completed:completedBlock];
}

- (void)Ease_setHighlightedImageWithURL:(nullable NSURL *)url options:(EaseWebImageOptions)options completed:(nullable EaseExternalCompletionBlock)completedBlock {
    [self Ease_setHighlightedImageWithURL:url options:options progress:nil completed:completedBlock];
}

- (void)Ease_setHighlightedImageWithURL:(NSURL *)url options:(EaseWebImageOptions)options progress:(nullable EaseImageLoaderProgressBlock)progressBlock completed:(nullable EaseExternalCompletionBlock)completedBlock {
    [self Ease_setHighlightedImageWithURL:url options:options context:nil progress:progressBlock completed:completedBlock];
}

- (void)Ease_setHighlightedImageWithURL:(nullable NSURL *)url
                              options:(EaseWebImageOptions)options
                              context:(nullable EaseWebImageContext *)context
                             progress:(nullable EaseImageLoaderProgressBlock)progressBlock
                            completed:(nullable EaseExternalCompletionBlock)completedBlock {
    @weakify(self);
    EaseWebImageMutableContext *mutableContext;
    if (context) {
        mutableContext = [context mutableCopy];
    } else {
        mutableContext = [NSMutableDictionary dictionary];
    }
    mutableContext[EaseWebImageContextSetImageOperationKey] = EaseHighlightedImageOperationKey;
    [self ease_internalSetImageWithURL:url
                    placeholderImage:nil
                             options:options
                             context:mutableContext
                       setImageBlock:^(UIImage * _Nullable image, NSData * _Nullable imageData, EaseImageCacheType cacheType, NSURL * _Nullable imageURL) {
                           @strongify(self);
                           self.highlightedImage = image;
                       }
                            progress:progressBlock
                           completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, EaseImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                               if (completedBlock) {
                                   completedBlock(image, error, cacheType, imageURL);
                               }
                           }];
}

@end

#endif
