/*
* This file is part of the EaseWebImage package.
* (c) Olivier Poitrey <rs@dailymotion.com>
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/

#import "EaseAssociatedObject.h"
#import "UIImage+EaseMetadata.h"
#import "UIImage+EaseExtendedCacheData.h"
#import "UIImage+EaseMemoryCacheCost.h"
#import "UIImage+EaseForceDecode.h"

void EaseImageCopyAssociatedObject(UIImage * _Nullable source, UIImage * _Nullable target) {
    if (!source || !target) {
        return;
    }
    // Image Metadata
    target.ease_isIncremental = source.ease_isIncremental;
    target.ease_imageLoopCount = source.ease_imageLoopCount;
    target.ease_imageFormat = source.ease_imageFormat;
    // Force Decode
    target.ease_isDecoded = source.ease_isDecoded;
    // Extended Cache Data
    target.ease_extendedObject = source.ease_extendedObject;
}
