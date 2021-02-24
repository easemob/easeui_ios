/*
* This file is part of the EaseWebImage package.
* (c) Olivier Poitrey <rs@dailymotion.com>
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/

#import "EaseWebImageCompat.h"

#if Ease_MAC

#import <QuartzCore/QuartzCore.h>

/// Helper method for Core Animation transition
FOUNDATION_EXPORT CAMediaTimingFunction * _Nullable EaseTimingFunctionFromAnimationOptions(EaseWebImageAnimationOptions options);
FOUNDATION_EXPORT CATransition * _Nullable EaseTransitionFromAnimationOptions(EaseWebImageAnimationOptions options);

#endif
