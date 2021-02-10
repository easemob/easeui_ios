/*
* This file is part of the EaseWebImage package.
* (c) Olivier Poitrey <rs@dailymotion.com>
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/

#import "EaseGraphicsImageRenderer.h"
#import "EaseImageGraphics.h"

@interface EaseGraphicsImageRendererFormat ()
#if Ease_UIKIT
@property (nonatomic, strong) UIGraphicsImageRendererFormat *uiformat API_AVAILABLE(ios(10.0), tvos(10.0));
#endif
@end

@implementation EaseGraphicsImageRendererFormat
@synthesize scale = _scale;
@synthesize opaque = _opaque;
@synthesize preferredRange = _preferredRange;

#pragma mark - Property
- (CGFloat)scale {
#if Ease_UIKIT
    if (@available(iOS 10.0, tvOS 10.10, *)) {
        return self.uiformat.scale;
    } else {
        return _scale;
    }
#else
    return _scale;
#endif
}

- (void)setScale:(CGFloat)scale {
#if Ease_UIKIT
    if (@available(iOS 10.0, tvOS 10.10, *)) {
        self.uiformat.scale = scale;
    } else {
        _scale = scale;
    }
#else
    _scale = scale;
#endif
}

- (BOOL)opaque {
#if Ease_UIKIT
    if (@available(iOS 10.0, tvOS 10.10, *)) {
        return self.uiformat.opaque;
    } else {
        return _opaque;
    }
#else
    return _opaque;
#endif
}

- (void)setOpaque:(BOOL)opaque {
#if Ease_UIKIT
    if (@available(iOS 10.0, tvOS 10.10, *)) {
        self.uiformat.opaque = opaque;
    } else {
        _opaque = opaque;
    }
#else
    _opaque = opaque;
#endif
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (EaseGraphicsImageRendererFormatRange)preferredRange {
#if Ease_UIKIT
    if (@available(iOS 10.0, tvOS 10.10, *)) {
        if (@available(iOS 12.0, tvOS 12.0, *)) {
            return (EaseGraphicsImageRendererFormatRange)self.uiformat.preferredRange;
        } else {
            BOOL prefersExtendedRange = self.uiformat.prefersExtendedRange;
            if (prefersExtendedRange) {
                return EaseGraphicsImageRendererFormatRangeExtended;
            } else {
                return EaseGraphicsImageRendererFormatRangeStandard;
            }
        }
    } else {
        return _preferredRange;
    }
#else
    return _preferredRange;
#endif
}

- (void)setPreferredRange:(EaseGraphicsImageRendererFormatRange)preferredRange {
#if Ease_UIKIT
    if (@available(iOS 10.0, tvOS 10.10, *)) {
        if (@available(iOS 12.0, tvOS 12.0, *)) {
            self.uiformat.preferredRange = (UIGraphicsImageRendererFormatRange)preferredRange;
        } else {
            switch (preferredRange) {
                case EaseGraphicsImageRendererFormatRangeExtended:
                    self.uiformat.prefersExtendedRange = YES;
                    break;
                case EaseGraphicsImageRendererFormatRangeStandard:
                    self.uiformat.prefersExtendedRange = NO;
                default:
                    // Automatic means default
                    break;
            }
        }
    } else {
        _preferredRange = preferredRange;
    }
#else
    _preferredRange = preferredRange;
#endif
}
#pragma clang diagnostic pop

- (instancetype)init {
    self = [super init];
    if (self) {
#if Ease_UIKIT
        if (@available(iOS 10.0, tvOS 10.10, *)) {
            UIGraphicsImageRendererFormat *uiformat = [[UIGraphicsImageRendererFormat alloc] init];
            self.uiformat = uiformat;
        } else {
#endif
#if Ease_WATCH
            CGFloat screenScale = [WKInterfaceDevice currentDevice].screenScale;
#elif Ease_UIKIT
            CGFloat screenScale = [UIScreen mainScreen].scale;
#elif Ease_MAC
            CGFloat screenScale = [NSScreen mainScreen].backingScaleFactor;
#endif
            self.scale = screenScale;
            self.opaque = NO;
            self.preferredRange = EaseGraphicsImageRendererFormatRangeStandard;
#if Ease_UIKIT
        }
#endif
    }
    return self;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
- (instancetype)initForMainScreen {
    self = [super init];
    if (self) {
#if Ease_UIKIT
        if (@available(iOS 10.0, tvOS 10.0, *)) {
            UIGraphicsImageRendererFormat *uiformat;
            // iOS 11.0.0 GM does have `preferredFormat`, but iOS 11 betas did not (argh!)
            if ([UIGraphicsImageRenderer respondsToSelector:@selector(preferredFormat)]) {
                uiformat = [UIGraphicsImageRendererFormat preferredFormat];
            } else {
                uiformat = [UIGraphicsImageRendererFormat defaultFormat];
            }
            self.uiformat = uiformat;
        } else {
#endif
#if Ease_WATCH
            CGFloat screenScale = [WKInterfaceDevice currentDevice].screenScale;
#elif Ease_UIKIT
            CGFloat screenScale = [UIScreen mainScreen].scale;
#elif Ease_MAC
            CGFloat screenScale = [NSScreen mainScreen].backingScaleFactor;
#endif
            self.scale = screenScale;
            self.opaque = NO;
            self.preferredRange = EaseGraphicsImageRendererFormatRangeStandard;
#if Ease_UIKIT
        }
#endif
    }
    return self;
}
#pragma clang diagnostic pop

+ (instancetype)preferredFormat {
    EaseGraphicsImageRendererFormat *format = [[EaseGraphicsImageRendererFormat alloc] initForMainScreen];
    return format;
}

@end

@interface EaseGraphicsImageRenderer ()
@property (nonatomic, assign) CGSize size;
@property (nonatomic, strong) EaseGraphicsImageRendererFormat *format;
#if Ease_UIKIT
@property (nonatomic, strong) UIGraphicsImageRenderer *uirenderer API_AVAILABLE(ios(10.0), tvos(10.0));
#endif
@end

@implementation EaseGraphicsImageRenderer

- (instancetype)initWithSize:(CGSize)size {
    return [self initWithSize:size format:EaseGraphicsImageRendererFormat.preferredFormat];
}

- (instancetype)initWithSize:(CGSize)size format:(EaseGraphicsImageRendererFormat *)format {
    NSParameterAssert(format);
    self = [super init];
    if (self) {
        self.size = size;
        self.format = format;
#if Ease_UIKIT
        if (@available(iOS 10.0, tvOS 10.0, *)) {
            UIGraphicsImageRendererFormat *uiformat = format.uiformat;
            self.uirenderer = [[UIGraphicsImageRenderer alloc] initWithSize:size format:uiformat];
        }
#endif
    }
    return self;
}

- (UIImage *)imageWithActions:(NS_NOESCAPE EaseGraphicsImageDrawingActions)actions {
    NSParameterAssert(actions);
#if Ease_UIKIT
    if (@available(iOS 10.0, tvOS 10.0, *)) {
        UIGraphicsImageDrawingActions uiactions = ^(UIGraphicsImageRendererContext *rendererContext) {
            if (actions) {
                actions(rendererContext.CGContext);
            }
        };
        return [self.uirenderer imageWithActions:uiactions];
    } else {
#endif
        EaseGraphicsBeginImageContextWithOptions(self.size, self.format.opaque, self.format.scale);
        CGContextRef context = EaseGraphicsGetCurrentContext();
        if (actions) {
            actions(context);
        }
        UIImage *image = EaseGraphicsGetImageFromCurrentImageContext();
        EaseGraphicsEndImageContext();
        return image;
#if Ease_UIKIT
    }
#endif
}

@end
