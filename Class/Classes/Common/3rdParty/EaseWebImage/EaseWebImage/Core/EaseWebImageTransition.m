/*
 * This file is part of the EaseWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "EaseWebImageTransition.h"

#if Ease_UIKIT || Ease_MAC

#if Ease_MAC
#import "EaseWebImageTransitionInternal.h"
#import "EaseInternalMacros.h"

CAMediaTimingFunction * EaseTimingFunctionFromAnimationOptions(EaseWebImageAnimationOptions options) {
    if (Ease_OPTIONS_CONTAINS(EaseWebImageAnimationOptionCurveLinear, options)) {
        return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    } else if (Ease_OPTIONS_CONTAINS(EaseWebImageAnimationOptionCurveEaseIn, options)) {
        return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    } else if (Ease_OPTIONS_CONTAINS(EaseWebImageAnimationOptionCurveEaseOut, options)) {
        return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    } else if (Ease_OPTIONS_CONTAINS(EaseWebImageAnimationOptionCurveEaseInOut, options)) {
        return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    } else {
        return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    }
}

CATransition * EaseTransitionFromAnimationOptions(EaseWebImageAnimationOptions options) {
    if (Ease_OPTIONS_CONTAINS(options, EaseWebImageAnimationOptionTransitionCrossDissolve)) {
        CATransition *trans = [CATransition animation];
        trans.type = kCATransitionFade;
        return trans;
    } else if (Ease_OPTIONS_CONTAINS(options, EaseWebImageAnimationOptionTransitionFlipFromLeft)) {
        CATransition *trans = [CATransition animation];
        trans.type = kCATransitionPush;
        trans.subtype = kCATransitionFromLeft;
        return trans;
    } else if (Ease_OPTIONS_CONTAINS(options, EaseWebImageAnimationOptionTransitionFlipFromRight)) {
        CATransition *trans = [CATransition animation];
        trans.type = kCATransitionPush;
        trans.subtype = kCATransitionFromRight;
        return trans;
    } else if (Ease_OPTIONS_CONTAINS(options, EaseWebImageAnimationOptionTransitionFlipFromTop)) {
        CATransition *trans = [CATransition animation];
        trans.type = kCATransitionPush;
        trans.subtype = kCATransitionFromTop;
        return trans;
    } else if (Ease_OPTIONS_CONTAINS(options, EaseWebImageAnimationOptionTransitionFlipFromBottom)) {
        CATransition *trans = [CATransition animation];
        trans.type = kCATransitionPush;
        trans.subtype = kCATransitionFromBottom;
        return trans;
    } else if (Ease_OPTIONS_CONTAINS(options, EaseWebImageAnimationOptionTransitionCurlUp)) {
        CATransition *trans = [CATransition animation];
        trans.type = kCATransitionReveal;
        trans.subtype = kCATransitionFromTop;
        return trans;
    } else if (Ease_OPTIONS_CONTAINS(options, EaseWebImageAnimationOptionTransitionCurlDown)) {
        CATransition *trans = [CATransition animation];
        trans.type = kCATransitionReveal;
        trans.subtype = kCATransitionFromBottom;
        return trans;
    } else {
        return nil;
    }
}
#endif

@implementation EaseWebImageTransition

- (instancetype)init {
    self = [super init];
    if (self) {
        self.duration = 0.5;
    }
    return self;
}

@end

@implementation EaseWebImageTransition (Conveniences)

+ (EaseWebImageTransition *)fadeTransition {
    return [self fadeTransitionWithDuration:0.5];
}

+ (EaseWebImageTransition *)fadeTransitionWithDuration:(NSTimeInterval)duration {
    EaseWebImageTransition *transition = [EaseWebImageTransition new];
    transition.duration = duration;
#if Ease_UIKIT
    transition.animationOptions = UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionAllowUserInteraction;
#else
    transition.animationOptions = EaseWebImageAnimationOptionTransitionCrossDissolve;
#endif
    return transition;
}

+ (EaseWebImageTransition *)flipFromLeftTransition {
    return [self flipFromLeftTransitionWithDuration:0.5];
}

+ (EaseWebImageTransition *)flipFromLeftTransitionWithDuration:(NSTimeInterval)duration {
    EaseWebImageTransition *transition = [EaseWebImageTransition new];
    transition.duration = duration;
#if Ease_UIKIT
    transition.animationOptions = UIViewAnimationOptionTransitionFlipFromLeft | UIViewAnimationOptionAllowUserInteraction;
#else
    transition.animationOptions = EaseWebImageAnimationOptionTransitionFlipFromLeft;
#endif
    return transition;
}

+ (EaseWebImageTransition *)flipFromRightTransition {
    return [self flipFromRightTransitionWithDuration:0.5];
}

+ (EaseWebImageTransition *)flipFromRightTransitionWithDuration:(NSTimeInterval)duration {
    EaseWebImageTransition *transition = [EaseWebImageTransition new];
    transition.duration = duration;
#if Ease_UIKIT
    transition.animationOptions = UIViewAnimationOptionTransitionFlipFromRight | UIViewAnimationOptionAllowUserInteraction;
#else
    transition.animationOptions = EaseWebImageAnimationOptionTransitionFlipFromRight;
#endif
    return transition;
}

+ (EaseWebImageTransition *)flipFromTopTransition {
    return [self flipFromTopTransitionWithDuration:0.5];
}

+ (EaseWebImageTransition *)flipFromTopTransitionWithDuration:(NSTimeInterval)duration {
    EaseWebImageTransition *transition = [EaseWebImageTransition new];
    transition.duration = duration;
#if Ease_UIKIT
    transition.animationOptions = UIViewAnimationOptionTransitionFlipFromTop | UIViewAnimationOptionAllowUserInteraction;
#else
    transition.animationOptions = EaseWebImageAnimationOptionTransitionFlipFromTop;
#endif
    return transition;
}

+ (EaseWebImageTransition *)flipFromBottomTransition {
    return [self flipFromBottomTransitionWithDuration:0.5];
}

+ (EaseWebImageTransition *)flipFromBottomTransitionWithDuration:(NSTimeInterval)duration {
    EaseWebImageTransition *transition = [EaseWebImageTransition new];
    transition.duration = duration;
#if Ease_UIKIT
    transition.animationOptions = UIViewAnimationOptionTransitionFlipFromBottom | UIViewAnimationOptionAllowUserInteraction;
#else
    transition.animationOptions = EaseWebImageAnimationOptionTransitionFlipFromBottom;
#endif
    return transition;
}

+ (EaseWebImageTransition *)curlUpTransition {
    return [self curlUpTransitionWithDuration:0.5];
}

+ (EaseWebImageTransition *)curlUpTransitionWithDuration:(NSTimeInterval)duration {
    EaseWebImageTransition *transition = [EaseWebImageTransition new];
    transition.duration = duration;
#if Ease_UIKIT
    transition.animationOptions = UIViewAnimationOptionTransitionCurlUp | UIViewAnimationOptionAllowUserInteraction;
#else
    transition.animationOptions = EaseWebImageAnimationOptionTransitionCurlUp;
#endif
    return transition;
}

+ (EaseWebImageTransition *)curlDownTransition {
    return [self curlDownTransitionWithDuration:0.5];
}

+ (EaseWebImageTransition *)curlDownTransitionWithDuration:(NSTimeInterval)duration {
    EaseWebImageTransition *transition = [EaseWebImageTransition new];
    transition.duration = duration;
#if Ease_UIKIT
    transition.animationOptions = UIViewAnimationOptionTransitionCurlDown | UIViewAnimationOptionAllowUserInteraction;
#else
    transition.animationOptions = EaseWebImageAnimationOptionTransitionCurlDown;
#endif
    transition.duration = duration;
    return transition;
}

@end

#endif
