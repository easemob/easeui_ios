/*
 * This file is part of the EaseWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "EaseWebImageCompat.h"

#if Ease_UIKIT || Ease_MAC

/**
 A protocol to custom the indicator during the image loading.
 All of these methods are called from main queue.
 */
@protocol EaseWebImageIndicator <NSObject>

@required
/**
 The view associate to the indicator.

 @return The indicator view
 */
@property (nonatomic, strong, readonly, nonnull) UIView *indicatorView;

/**
 Start the animating for indicator.
 */
- (void)startAnimatingIndicator;

/**
 Stop the animating for indicator.
 */
- (void)stopAnimatingIndicator;

@optional
/**
 Update the loading progress (0-1.0) for indicator. Optional
 
 @param progress The progress, value between 0 and 1.0
 */
- (void)updateIndicatorProgress:(double)progress;

@end

#pragma mark - Activity Indicator

/**
 Activity indicator class.
 for UIKit(macOS), it use a `UIActivityIndicatorView`.
 for AppKit(macOS), it use a `NSProgressIndicator` with the spinning style.
 */
@interface EaseWebImageActivityIndicator : NSObject <EaseWebImageIndicator>

#if Ease_UIKIT
@property (nonatomic, strong, readonly, nonnull) UIActivityIndicatorView *indicatorView;
#else
@property (nonatomic, strong, readonly, nonnull) NSProgressIndicator *indicatorView;
#endif

@end

/**
 Convenience way to use activity indicator.
 */
@interface EaseWebImageActivityIndicator (Conveniences)

/// These indicator use the fixed color without dark mode support
/// gray-style activity indicator
@property (nonatomic, class, nonnull, readonly) EaseWebImageActivityIndicator *grayIndicator;
/// large gray-style activity indicator
@property (nonatomic, class, nonnull, readonly) EaseWebImageActivityIndicator *grayLargeIndicator;
/// white-style activity indicator
@property (nonatomic, class, nonnull, readonly) EaseWebImageActivityIndicator *whiteIndicator;
/// large white-style activity indicator
@property (nonatomic, class, nonnull, readonly) EaseWebImageActivityIndicator *whiteLargeIndicator;
/// These indicator use the system style, supports dark mode if available (iOS 13+/macOS 10.14+)
/// large activity indicator
@property (nonatomic, class, nonnull, readonly) EaseWebImageActivityIndicator *largeIndicator;
/// medium activity indicator
@property (nonatomic, class, nonnull, readonly) EaseWebImageActivityIndicator *mediumIndicator;

@end

#pragma mark - Progress Indicator

/**
 Progress indicator class.
 for UIKit(macOS), it use a `UIProgressView`.
 for AppKit(macOS), it use a `NSProgressIndicator` with the bar style.
 */
@interface EaseWebImageProgressIndicator : NSObject <EaseWebImageIndicator>

#if Ease_UIKIT
@property (nonatomic, strong, readonly, nonnull) UIProgressView *indicatorView;
#else
@property (nonatomic, strong, readonly, nonnull) NSProgressIndicator *indicatorView;
#endif

@end

/**
 Convenience way to create progress indicator. Remember to specify the indicator width or use layout constraint if need.
 */
@interface EaseWebImageProgressIndicator (Conveniences)

/// default-style progress indicator
@property (nonatomic, class, nonnull, readonly) EaseWebImageProgressIndicator *defaultIndicator;
/// bar-style progress indicator
@property (nonatomic, class, nonnull, readonly) EaseWebImageProgressIndicator *barIndicator API_UNAVAILABLE(macos, tvos);

@end

#endif
