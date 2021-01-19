/*
 * This file is part of the EaseWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "EaseImageTransformer.h"
#import "UIColor+EaseHexString.h"
#if Ease_UIKIT || Ease_MAC
#import <CoreImage/CoreImage.h>
#endif

// Separator for different transformerKey, for example, `image.png` |> flip(YES,NO) |> rotate(pi/4,YES) => 'image-EaseImageFlippingTransformer(1,0)-EaseImageRotationTransformer(0.78539816339,1).png'
static NSString * const EaseImageTransformerKeySeparator = @"-";

NSString * _Nullable EaseTransformedKeyForKey(NSString * _Nullable key, NSString * _Nonnull transformerKey) {
    if (!key || !transformerKey) {
        return nil;
    }
    // Find the file extension
    NSURL *keyURL = [NSURL URLWithString:key];
    NSString *ext = keyURL ? keyURL.pathExtension : key.pathExtension;
    if (ext.length > 0) {
        // For non-file URL
        if (keyURL && !keyURL.isFileURL) {
            // keep anything except path (like URL query)
            NSURLComponents *component = [NSURLComponents componentsWithURL:keyURL resolvingAgainstBaseURL:NO];
            component.path = [[[component.path.stringByDeletingPathExtension stringByAppendingString:EaseImageTransformerKeySeparator] stringByAppendingString:transformerKey] stringByAppendingPathExtension:ext];
            return component.URL.absoluteString;
        } else {
            // file URL
            return [[[key.stringByDeletingPathExtension stringByAppendingString:EaseImageTransformerKeySeparator] stringByAppendingString:transformerKey] stringByAppendingPathExtension:ext];
        }
    } else {
        return [[key stringByAppendingString:EaseImageTransformerKeySeparator] stringByAppendingString:transformerKey];
    }
}

NSString * _Nullable EaseThumbnailedKeyForKey(NSString * _Nullable key, CGSize thumbnailPixelSize, BOOL preserveAspectRatio) {
    NSString *thumbnailKey = [NSString stringWithFormat:@"Thumbnail({%f,%f},%d)", thumbnailPixelSize.width, thumbnailPixelSize.height, preserveAspectRatio];
    return EaseTransformedKeyForKey(key, thumbnailKey);
}

@interface EaseImagePipelineTransformer ()

@property (nonatomic, copy, readwrite, nonnull) NSArray<id<EaseImageTransformer>> *transformers;
@property (nonatomic, copy, readwrite) NSString *transformerKey;

@end

@implementation EaseImagePipelineTransformer

+ (instancetype)transformerWithTransformers:(NSArray<id<EaseImageTransformer>> *)transformers {
    EaseImagePipelineTransformer *transformer = [EaseImagePipelineTransformer new];
    transformer.transformers = transformers;
    transformer.transformerKey = [[self class] cacheKeyForTransformers:transformers];
    
    return transformer;
}

+ (NSString *)cacheKeyForTransformers:(NSArray<id<EaseImageTransformer>> *)transformers {
    if (transformers.count == 0) {
        return @"";
    }
    NSMutableArray<NSString *> *cacheKeys = [NSMutableArray arrayWithCapacity:transformers.count];
    [transformers enumerateObjectsUsingBlock:^(id<EaseImageTransformer>  _Nonnull transformer, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *cacheKey = transformer.transformerKey;
        [cacheKeys addObject:cacheKey];
    }];
    
    return [cacheKeys componentsJoinedByString:EaseImageTransformerKeySeparator];
}

- (UIImage *)transformedImageWithImage:(UIImage *)image forKey:(NSString *)key {
    if (!image) {
        return nil;
    }
    UIImage *transformedImage = image;
    for (id<EaseImageTransformer> transformer in self.transformers) {
        transformedImage = [transformer transformedImageWithImage:transformedImage forKey:key];
    }
    return transformedImage;
}

@end

@interface EaseImageRoundCornerTransformer ()

@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) EaseRectCorner corners;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, strong, nullable) UIColor *borderColor;

@end

@implementation EaseImageRoundCornerTransformer

+ (instancetype)transformerWithRadius:(CGFloat)cornerRadius corners:(EaseRectCorner)corners borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor {
    EaseImageRoundCornerTransformer *transformer = [EaseImageRoundCornerTransformer new];
    transformer.cornerRadius = cornerRadius;
    transformer.corners = corners;
    transformer.borderWidth = borderWidth;
    transformer.borderColor = borderColor;
    
    return transformer;
}

- (NSString *)transformerKey {
    return [NSString stringWithFormat:@"EaseImageRoundCornerTransformer(%f,%lu,%f,%@)", self.cornerRadius, (unsigned long)self.corners, self.borderWidth, self.borderColor.ease_hexString];
}

- (UIImage *)transformedImageWithImage:(UIImage *)image forKey:(NSString *)key {
    if (!image) {
        return nil;
    }
    return [image Ease_roundedCornerImageWithRadius:self.cornerRadius corners:self.corners borderWidth:self.borderWidth borderColor:self.borderColor];
}

@end

@interface EaseImageResizingTransformer ()

@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) EaseImageScaleMode scaleMode;

@end

@implementation EaseImageResizingTransformer

+ (instancetype)transformerWithSize:(CGSize)size scaleMode:(EaseImageScaleMode)scaleMode {
    EaseImageResizingTransformer *transformer = [EaseImageResizingTransformer new];
    transformer.size = size;
    transformer.scaleMode = scaleMode;
    
    return transformer;
}

- (NSString *)transformerKey {
    CGSize size = self.size;
    return [NSString stringWithFormat:@"EaseImageResizingTransformer({%f,%f},%lu)", size.width, size.height, (unsigned long)self.scaleMode];
}

- (UIImage *)transformedImageWithImage:(UIImage *)image forKey:(NSString *)key {
    if (!image) {
        return nil;
    }
    return [image Ease_resizedImageWithSize:self.size scaleMode:self.scaleMode];
}

@end

@interface EaseImageCroppingTransformer ()

@property (nonatomic, assign) CGRect rect;

@end

@implementation EaseImageCroppingTransformer

+ (instancetype)transformerWithRect:(CGRect)rect {
    EaseImageCroppingTransformer *transformer = [EaseImageCroppingTransformer new];
    transformer.rect = rect;
    
    return transformer;
}

- (NSString *)transformerKey {
    CGRect rect = self.rect;
    return [NSString stringWithFormat:@"EaseImageCroppingTransformer({%f,%f,%f,%f})", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height];
}

- (UIImage *)transformedImageWithImage:(UIImage *)image forKey:(NSString *)key {
    if (!image) {
        return nil;
    }
    return [image Ease_croppedImageWithRect:self.rect];
}

@end

@interface EaseImageFlippingTransformer ()

@property (nonatomic, assign) BOOL horizontal;
@property (nonatomic, assign) BOOL vertical;

@end

@implementation EaseImageFlippingTransformer

+ (instancetype)transformerWithHorizontal:(BOOL)horizontal vertical:(BOOL)vertical {
    EaseImageFlippingTransformer *transformer = [EaseImageFlippingTransformer new];
    transformer.horizontal = horizontal;
    transformer.vertical = vertical;
    
    return transformer;
}

- (NSString *)transformerKey {
    return [NSString stringWithFormat:@"EaseImageFlippingTransformer(%d,%d)", self.horizontal, self.vertical];
}

- (UIImage *)transformedImageWithImage:(UIImage *)image forKey:(NSString *)key {
    if (!image) {
        return nil;
    }
    return [image Ease_flippedImageWithHorizontal:self.horizontal vertical:self.vertical];
}

@end

@interface EaseImageRotationTransformer ()

@property (nonatomic, assign) CGFloat angle;
@property (nonatomic, assign) BOOL fitSize;

@end

@implementation EaseImageRotationTransformer

+ (instancetype)transformerWithAngle:(CGFloat)angle fitSize:(BOOL)fitSize {
    EaseImageRotationTransformer *transformer = [EaseImageRotationTransformer new];
    transformer.angle = angle;
    transformer.fitSize = fitSize;
    
    return transformer;
}

- (NSString *)transformerKey {
    return [NSString stringWithFormat:@"EaseImageRotationTransformer(%f,%d)", self.angle, self.fitSize];
}

- (UIImage *)transformedImageWithImage:(UIImage *)image forKey:(NSString *)key {
    if (!image) {
        return nil;
    }
    return [image Ease_rotatedImageWithAngle:self.angle fitSize:self.fitSize];
}

@end

#pragma mark - Image Blending

@interface EaseImageTintTransformer ()

@property (nonatomic, strong, nonnull) UIColor *tintColor;

@end

@implementation EaseImageTintTransformer

+ (instancetype)transformerWithColor:(UIColor *)tintColor {
    EaseImageTintTransformer *transformer = [EaseImageTintTransformer new];
    transformer.tintColor = tintColor;
    
    return transformer;
}

- (NSString *)transformerKey {
    return [NSString stringWithFormat:@"EaseImageTintTransformer(%@)", self.tintColor.ease_hexString];
}

- (UIImage *)transformedImageWithImage:(UIImage *)image forKey:(NSString *)key {
    if (!image) {
        return nil;
    }
    return [image Ease_tintedImageWithColor:self.tintColor];
}

@end

#pragma mark - Image Effect

@interface EaseImageBlurTransformer ()

@property (nonatomic, assign) CGFloat blurRadius;

@end

@implementation EaseImageBlurTransformer

+ (instancetype)transformerWithRadius:(CGFloat)blurRadius {
    EaseImageBlurTransformer *transformer = [EaseImageBlurTransformer new];
    transformer.blurRadius = blurRadius;
    
    return transformer;
}

- (NSString *)transformerKey {
    return [NSString stringWithFormat:@"EaseImageBlurTransformer(%f)", self.blurRadius];
}

- (UIImage *)transformedImageWithImage:(UIImage *)image forKey:(NSString *)key {
    if (!image) {
        return nil;
    }
    return [image Ease_blurredImageWithRadius:self.blurRadius];
}

@end

#if Ease_UIKIT || Ease_MAC
@interface EaseImageFilterTransformer ()

@property (nonatomic, strong, nonnull) CIFilter *filter;

@end

@implementation EaseImageFilterTransformer

+ (instancetype)transformerWithFilter:(CIFilter *)filter {
    EaseImageFilterTransformer *transformer = [EaseImageFilterTransformer new];
    transformer.filter = filter;
    
    return transformer;
}

- (NSString *)transformerKey {
    return [NSString stringWithFormat:@"EaseImageFilterTransformer(%@)", self.filter.name];
}

- (UIImage *)transformedImageWithImage:(UIImage *)image forKey:(NSString *)key {
    if (!image) {
        return nil;
    }
    return [image Ease_filteredImageWithFilter:self.filter];
}

@end
#endif
