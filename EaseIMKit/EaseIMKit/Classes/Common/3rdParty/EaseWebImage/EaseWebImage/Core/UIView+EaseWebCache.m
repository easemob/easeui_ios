/*
 * This file is part of the EaseWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIView+EaseWebCache.h"
#import "objc/runtime.h"
#import "UIView+EaseWebCacheOperation.h"
#import "EaseWebImageError.h"
#import "EaseInternalMacros.h"
#import "EaseWebImageTransitionInternal.h"

const int64_t EaseWebImageProgressUnitCountUnknown = 1LL;

@implementation UIView (EaseWebCache)

- (nullable NSURL *)ease_imageURL {
    return objc_getAssociatedObject(self, @selector(ease_imageURL));
}

- (void)setEase_imageProgress:(NSProgress *)ease_imageProgress
{
    objc_setAssociatedObject(self, @selector(ease_imageProgress), ease_imageProgress, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setEase_imageURL:(NSURL * _Nullable)ease_imageURL {
    objc_setAssociatedObject(self, @selector(ease_imageURL), ease_imageURL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (nullable NSString *)ease_latestOperationKey {
    return objc_getAssociatedObject(self, @selector(ease_latestOperationKey));
}

- (void)setEase_latestOperationKey:(NSString * _Nullable)ease_latestOperationKey {
    objc_setAssociatedObject(self, @selector(ease_latestOperationKey), ease_latestOperationKey, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSProgress *)ease_imageProgress {
    NSProgress *progress = objc_getAssociatedObject(self, @selector(ease_imageProgress));
    if (!progress) {
        progress = [[NSProgress alloc] initWithParent:nil userInfo:nil];
        self.ease_imageProgress = progress;
    }
    return progress;
}

- (void)ease_internalSetImageWithURL:(nullable NSURL *)url
                  placeholderImage:(nullable UIImage *)placeholder
                           options:(EaseWebImageOptions)options
                           context:(nullable EaseWebImageContext *)context
                     setImageBlock:(nullable EaseSetImageBlock)setImageBlock
                          progress:(nullable EaseImageLoaderProgressBlock)progressBlock
                         completed:(nullable EaseInternalCompletionBlock)completedBlock {
    if (context) {
        // copy to avoid mutable object
        context = [context copy];
    } else {
        context = [NSDictionary dictionary];
    }
    NSString *validOperationKey = context[EaseWebImageContextSetImageOperationKey];
    if (!validOperationKey) {
        // pass through the operation key to downstream, which can used for tracing operation or image view class
        validOperationKey = NSStringFromClass([self class]);
        EaseWebImageMutableContext *mutableContext = [context mutableCopy];
        mutableContext[EaseWebImageContextSetImageOperationKey] = validOperationKey;
        context = [mutableContext copy];
    }
    self.ease_latestOperationKey = validOperationKey;
    [self Ease_cancelImageLoadOperationWithKey:validOperationKey];
    self.ease_imageURL = url;
    
    if (!(options & EaseWebImageDelayPlaceholder)) {
        dispatch_main_async_safe(^{
            [self Ease_setImage:placeholder imageData:nil basedOnClassOrViaCustomSetImageBlock:setImageBlock cacheType:EaseImageCacheTypeNone imageURL:url];
        });
    }
    
    if (url) {
        // reset the progress
        NSProgress *imageProgress = objc_getAssociatedObject(self, @selector(ease_imageProgress));
        if (imageProgress) {
            imageProgress.totalUnitCount = 0;
            imageProgress.completedUnitCount = 0;
        }
        
#if Ease_UIKIT || Ease_MAC
        // check and start image indicator
        [self ease_startImageIndicator];
        id<EaseWebImageIndicator> imageIndicator = self.ease_imageIndicator;
#endif
        EaseWebImageManager *manager = context[EaseWebImageContextCustomManager];
        if (!manager) {
            manager = [EaseWebImageManager sharedManager];
        } else {
            // remove this manager to avoid retain cycle (manger -> loader -> operation -> context -> manager)
            EaseWebImageMutableContext *mutableContext = [context mutableCopy];
            mutableContext[EaseWebImageContextCustomManager] = nil;
            context = [mutableContext copy];
        }
        
        EaseImageLoaderProgressBlock combinedProgressBlock = ^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            if (imageProgress) {
                imageProgress.totalUnitCount = expectedSize;
                imageProgress.completedUnitCount = receivedSize;
            }
#if Ease_UIKIT || Ease_MAC
            if ([imageIndicator respondsToSelector:@selector(updateIndicatorProgress:)]) {
                double progress = 0;
                if (expectedSize != 0) {
                    progress = (double)receivedSize / expectedSize;
                }
                progress = MAX(MIN(progress, 1), 0); // 0.0 - 1.0
                dispatch_async(dispatch_get_main_queue(), ^{
                    [imageIndicator updateIndicatorProgress:progress];
                });
            }
#endif
            if (progressBlock) {
                progressBlock(receivedSize, expectedSize, targetURL);
            }
        };
        @weakify(self);
        id <EaseWebImageOperation> operation = [manager loadImageWithURL:url options:options context:context progress:combinedProgressBlock completed:^(UIImage *image, NSData *data, NSError *error, EaseImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            @strongify(self);
            if (!self) { return; }
            // if the progress not been updated, mark it to complete state
            if (imageProgress && finished && !error && imageProgress.totalUnitCount == 0 && imageProgress.completedUnitCount == 0) {
                imageProgress.totalUnitCount = EaseWebImageProgressUnitCountUnknown;
                imageProgress.completedUnitCount = EaseWebImageProgressUnitCountUnknown;
            }
            
#if Ease_UIKIT || Ease_MAC
            // check and stop image indicator
            if (finished) {
                [self Ease_stopImageIndicator];
            }
#endif
            
            BOOL shouldCallCompletedBlock = finished || (options & EaseWebImageAvoidAutoSetImage);
            BOOL shouldNotSetImage = ((image && (options & EaseWebImageAvoidAutoSetImage)) ||
                                      (!image && !(options & EaseWebImageDelayPlaceholder)));
            EaseWebImageNoParamsBlock callCompletedBlockClojure = ^{
                if (!self) { return; }
                if (!shouldNotSetImage) {
                    [self Ease_setNeedsLayout];
                }
                if (completedBlock && shouldCallCompletedBlock) {
                    completedBlock(image, data, error, cacheType, finished, url);
                }
            };
            
            // case 1a: we got an image, but the EaseWebImageAvoidAutoSetImage flag is set
            // OR
            // case 1b: we got no image and the EaseWebImageDelayPlaceholder is not set
            if (shouldNotSetImage) {
                dispatch_main_async_safe(callCompletedBlockClojure);
                return;
            }
            
            UIImage *targetImage = nil;
            NSData *targetData = nil;
            if (image) {
                // case 2a: we got an image and the EaseWebImageAvoidAutoSetImage is not set
                targetImage = image;
                targetData = data;
            } else if (options & EaseWebImageDelayPlaceholder) {
                // case 2b: we got no image and the EaseWebImageDelayPlaceholder flag is set
                targetImage = placeholder;
                targetData = nil;
            }
            
#if Ease_UIKIT || Ease_MAC
            // check whether we should use the image transition
            EaseWebImageTransition *transition = nil;
            BOOL shouldUseTransition = NO;
            if (options & EaseWebImageForceTransition) {
                // Always
                shouldUseTransition = YES;
            } else if (cacheType == EaseImageCacheTypeNone) {
                // From network
                shouldUseTransition = YES;
            } else {
                // From disk (and, user don't use sync query)
                if (cacheType == EaseImageCacheTypeMemory) {
                    shouldUseTransition = NO;
                } else if (cacheType == EaseImageCacheTypeDisk) {
                    if (options & EaseWebImageQueryMemoryDataSync || options & EaseWebImageQueryDiskDataSync) {
                        shouldUseTransition = NO;
                    } else {
                        shouldUseTransition = YES;
                    }
                } else {
                    // Not valid cache type, fallback
                    shouldUseTransition = NO;
                }
            }
            if (finished && shouldUseTransition) {
                transition = self.ease_imageTransition;
            }
#endif
            dispatch_main_async_safe(^{
#if Ease_UIKIT || Ease_MAC
                [self Ease_setImage:targetImage imageData:targetData basedOnClassOrViaCustomSetImageBlock:setImageBlock transition:transition cacheType:cacheType imageURL:imageURL];
#else
                [self Ease_setImage:targetImage imageData:targetData basedOnClassOrViaCustomSetImageBlock:setImageBlock cacheType:cacheType imageURL:imageURL];
#endif
                callCompletedBlockClojure();
            });
        }];
        [self Ease_setImageLoadOperation:operation forKey:validOperationKey];
    } else {
#if Ease_UIKIT || Ease_MAC
        [self Ease_stopImageIndicator];
#endif
        dispatch_main_async_safe(^{
            if (completedBlock) {
                NSError *error = [NSError errorWithDomain:EaseWebImageErrorDomain code:EaseWebImageErrorInvalidURL userInfo:@{NSLocalizedDescriptionKey : @"Image url is nil"}];
                completedBlock(nil, nil, error, EaseImageCacheTypeNone, YES, url);
            }
        });
    }
}

- (void)Ease_cancelCurrentImageLoad {
    [self Ease_cancelImageLoadOperationWithKey:self.ease_latestOperationKey];
    self.Ease_latestOperationKey = nil;
}

- (void)Ease_setImage:(UIImage *)image imageData:(NSData *)imageData basedOnClassOrViaCustomSetImageBlock:(EaseSetImageBlock)setImageBlock cacheType:(EaseImageCacheType)cacheType imageURL:(NSURL *)imageURL {
#if Ease_UIKIT || Ease_MAC
    [self Ease_setImage:image imageData:imageData basedOnClassOrViaCustomSetImageBlock:setImageBlock transition:nil cacheType:cacheType imageURL:imageURL];
#else
    // watchOS does not support view transition. Simplify the logic
    if (setImageBlock) {
        setImageBlock(image, imageData, cacheType, imageURL);
    } else if ([self isKindOfClass:[UIImageView class]]) {
        UIImageView *imageView = (UIImageView *)self;
        [imageView setImage:image];
    }
#endif
}

#if Ease_UIKIT || Ease_MAC
- (void)Ease_setImage:(UIImage *)image imageData:(NSData *)imageData basedOnClassOrViaCustomSetImageBlock:(EaseSetImageBlock)setImageBlock transition:(EaseWebImageTransition *)transition cacheType:(EaseImageCacheType)cacheType imageURL:(NSURL *)imageURL {
    UIView *view = self;
    EaseSetImageBlock finalSetImageBlock;
    if (setImageBlock) {
        finalSetImageBlock = setImageBlock;
    } else if ([view isKindOfClass:[UIImageView class]]) {
        UIImageView *imageView = (UIImageView *)view;
        finalSetImageBlock = ^(UIImage *setImage, NSData *setImageData, EaseImageCacheType setCacheType, NSURL *setImageURL) {
            imageView.image = setImage;
        };
    }
#if Ease_UIKIT
    else if ([view isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)view;
        finalSetImageBlock = ^(UIImage *setImage, NSData *setImageData, EaseImageCacheType setCacheType, NSURL *setImageURL) {
            [button setImage:setImage forState:UIControlStateNormal];
        };
    }
#endif
#if Ease_MAC
    else if ([view isKindOfClass:[NSButton class]]) {
        NSButton *button = (NSButton *)view;
        finalSetImageBlock = ^(UIImage *setImage, NSData *setImageData, EaseImageCacheType setCacheType, NSURL *setImageURL) {
            button.image = setImage;
        };
    }
#endif
    
    if (transition) {
        NSString *originalOperationKey = view.ease_latestOperationKey;

#if Ease_UIKIT
        [UIView transitionWithView:view duration:0 options:0 animations:^{
            if (!view.ease_latestOperationKey || ![originalOperationKey isEqualToString:view.ease_latestOperationKey]) {
                return;
            }
            // 0 duration to let UIKit render placeholder and prepares block
            if (transition.prepares) {
                transition.prepares(view, image, imageData, cacheType, imageURL);
            }
        } completion:^(BOOL finished) {
            [UIView transitionWithView:view duration:transition.duration options:transition.animationOptions animations:^{
                if (!view.ease_latestOperationKey || ![originalOperationKey isEqualToString:view.ease_latestOperationKey]) {
                    return;
                }
                if (finalSetImageBlock && !transition.avoidAutoSetImage) {
                    finalSetImageBlock(image, imageData, cacheType, imageURL);
                }
                if (transition.animations) {
                    transition.animations(view, image);
                }
            } completion:^(BOOL finished) {
                if (!view.ease_latestOperationKey || ![originalOperationKey isEqualToString:view.ease_latestOperationKey]) {
                    return;
                }
                if (transition.completion) {
                    transition.completion(finished);
                }
            }];
        }];
#elif Ease_MAC
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull prepareContext) {
            if (!view.Ease_latestOperationKey || ![originalOperationKey isEqualToString:view.Ease_latestOperationKey]) {
                return;
            }
            // 0 duration to let AppKit render placeholder and prepares block
            prepareContext.duration = 0;
            if (transition.prepares) {
                transition.prepares(view, image, imageData, cacheType, imageURL);
            }
        } completionHandler:^{
            [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
                if (!view.Ease_latestOperationKey || ![originalOperationKey isEqualToString:view.Ease_latestOperationKey]) {
                    return;
                }
                context.duration = transition.duration;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                CAMediaTimingFunction *timingFunction = transition.timingFunction;
#pragma clang diagnostic pop
                if (!timingFunction) {
                    timingFunction = EaseTimingFunctionFromAnimationOptions(transition.animationOptions);
                }
                context.timingFunction = timingFunction;
                context.allowsImplicitAnimation = Ease_OPTIONS_CONTAINS(transition.animationOptions, EaseWebImageAnimationOptionAllowsImplicitAnimation);
                if (finalSetImageBlock && !transition.avoidAutoSetImage) {
                    finalSetImageBlock(image, imageData, cacheType, imageURL);
                }
                CATransition *trans = EaseTransitionFromAnimationOptions(transition.animationOptions);
                if (trans) {
                    [view.layer addAnimation:trans forKey:kCATransition];
                }
                if (transition.animations) {
                    transition.animations(view, image);
                }
            } completionHandler:^{
                if (!view.Ease_latestOperationKey || ![originalOperationKey isEqualToString:view.Ease_latestOperationKey]) {
                    return;
                }
                if (transition.completion) {
                    transition.completion(YES);
                }
            }];
        }];
#endif
    } else {
        if (finalSetImageBlock) {
            finalSetImageBlock(image, imageData, cacheType, imageURL);
        }
    }
}
#endif

- (void)Ease_setNeedsLayout {
#if Ease_UIKIT
    [self setNeedsLayout];
#elif Ease_MAC
    [self setNeedsLayout:YES];
#elif Ease_WATCH
    // Do nothing because WatchKit automatically layout the view after property change
#endif
}

#if Ease_UIKIT || Ease_MAC

#pragma mark - Image Transition
- (EaseWebImageTransition *)ease_imageTransition {
    return objc_getAssociatedObject(self, @selector(ease_imageTransition));
}

- (void)setEase_imageTransition:(EaseWebImageTransition *)ease_imageTransition {
    objc_setAssociatedObject(self, @selector(ease_imageTransition), ease_imageTransition, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Indicator
- (id<EaseWebImageIndicator>)ease_imageIndicator {
    return objc_getAssociatedObject(self, @selector(ease_imageIndicator));
}

- (void)setEase_imageIndicator:(id<EaseWebImageIndicator>)ease_imageIndicator {
    // Remove the old indicator view
    id<EaseWebImageIndicator> previousIndicator = self.ease_imageIndicator;
    [previousIndicator.indicatorView removeFromSuperview];
    
    objc_setAssociatedObject(self, @selector(ease_imageIndicator), ease_imageIndicator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // Add the new indicator view
    UIView *view = ease_imageIndicator.indicatorView;
    if (CGRectEqualToRect(view.frame, CGRectZero)) {
        view.frame = self.bounds;
    }
    // Center the indicator view
#if Ease_MAC
    [view setFrameOrigin:CGPointMake(round((NSWidth(self.bounds) - NSWidth(view.frame)) / 2), round((NSHeight(self.bounds) - NSHeight(view.frame)) / 2))];
#else
    view.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
#endif
    view.hidden = NO;
    [self addSubview:view];
}

- (void)ease_startImageIndicator {
    id<EaseWebImageIndicator> imageIndicator = self.ease_imageIndicator;
    if (!imageIndicator) {
        return;
    }
    dispatch_main_async_safe(^{
        [imageIndicator startAnimatingIndicator];
    });
}

- (void)Ease_stopImageIndicator {
    id<EaseWebImageIndicator> imageIndicator = self.ease_imageIndicator;
    if (!imageIndicator) {
        return;
    }
    dispatch_main_async_safe(^{
        [imageIndicator stopAnimatingIndicator];
    });
}

#endif

@end
