/*
 * This file is part of the EaseWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "EaseWebImageCompat.h"

#if Ease_MAC

#import "UIImage+EaseTransform.h"

@interface NSBezierPath (EaseRoundedCorners)

/**
 Convenience way to create a bezier path with the specify rounding corners on macOS. Same as the one on `UIBezierPath`.
 */
+ (nonnull instancetype)Ease_bezierPathWithRoundedRect:(NSRect)rect byRoundingCorners:(EaseRectCorner)corners cornerRadius:(CGFloat)cornerRadius;

@end

#endif
