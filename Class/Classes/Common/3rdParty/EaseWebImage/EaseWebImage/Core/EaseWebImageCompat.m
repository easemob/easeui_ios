/*
 * This file is part of the EaseWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "EaseWebImageCompat.h"

#if !__has_feature(objc_arc)
    #error EaseWebImage is ARC only. Either turn on ARC for the project or use -fobjc-arc flag
#endif

#if !OS_OBJECT_USE_OBJC
    #error EaseWebImage need ARC for dispatch object
#endif
