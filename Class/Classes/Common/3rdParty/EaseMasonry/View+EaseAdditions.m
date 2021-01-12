//
//  UIView+EaseAdditions.m
//  Easeonry
//
//  Created by Jonas Budelmann on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "View+EaseAdditions.h"
#import <objc/runtime.h>

@implementation Ease_VIEW (EaseAdditions)

- (NSArray *)Ease_makeConstraints:(void(NS_NOESCAPE ^)(EaseConstraintMaker *))block {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    EaseConstraintMaker *constraintMaker = [[EaseConstraintMaker alloc] initWithView:self];
    block(constraintMaker);
    return [constraintMaker install];
}

- (NSArray *)Ease_updateConstraints:(void(NS_NOESCAPE^)(EaseConstraintMaker *))block {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    EaseConstraintMaker *constraintMaker = [[EaseConstraintMaker alloc] initWithView:self];
    constraintMaker.updateExisting = YES;
    block(constraintMaker);
    return [constraintMaker install];
}

- (NSArray *)Ease_remakeConstraints:(void(NS_NOESCAPE^)(EaseConstraintMaker *make))block {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    EaseConstraintMaker *constraintMaker = [[EaseConstraintMaker alloc] initWithView:self];
    constraintMaker.removeExisting = YES;
    block(constraintMaker);
    return [constraintMaker install];
}

#pragma mark - NSLayoutAttribute properties

- (EaseViewAttribute *)ease_left {
    return [[EaseViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeft];
}

- (EaseViewAttribute *)ease_top {
    return [[EaseViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTop];
}

- (EaseViewAttribute *)ease_right {
    return [[EaseViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeRight];
}

- (EaseViewAttribute *)ease_bottom {
    return [[EaseViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeBottom];
}

- (EaseViewAttribute *)ease_leading {
    return [[EaseViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeading];
}

- (EaseViewAttribute *)ease_trailing {
    return [[EaseViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTrailing];
}

- (EaseViewAttribute *)ease_width {
    return [[EaseViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeWidth];
}

- (EaseViewAttribute *)ease_height {
    return [[EaseViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeHeight];
}

- (EaseViewAttribute *)ease_centerX {
    return [[EaseViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterX];
}

- (EaseViewAttribute *)ease_centerY {
    return [[EaseViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterY];
}

- (EaseViewAttribute *)ease_baseline {
    return [[EaseViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeBaseline];
}

- (EaseViewAttribute *(^)(NSLayoutAttribute))ease_attribute
{
    return ^(NSLayoutAttribute attr) {
        return [[EaseViewAttribute alloc] initWithView:self layoutAttribute:attr];
    };
}

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

- (EaseViewAttribute *)ease_firstBaseline {
    return [[EaseViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeFirstBaseline];
}
- (EaseViewAttribute *)ease_lastBaseline {
    return [[EaseViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLastBaseline];
}

#endif

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

- (EaseViewAttribute *)ease_leftMargin {
    return [[EaseViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeftMargin];
}

- (EaseViewAttribute *)ease_rightMargin {
    return [[EaseViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeRightMargin];
}

- (EaseViewAttribute *)ease_topMargin {
    return [[EaseViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTopMargin];
}

- (EaseViewAttribute *)ease_bottomMargin {
    return [[EaseViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeBottomMargin];
}

- (EaseViewAttribute *)ease_leadingMargin {
    return [[EaseViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeadingMargin];
}

- (EaseViewAttribute *)ease_trailingMargin {
    return [[EaseViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTrailingMargin];
}

- (EaseViewAttribute *)ease_centerXWithinMargins {
    return [[EaseViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterXWithinMargins];
}

- (EaseViewAttribute *)ease_centerYWithinMargins {
    return [[EaseViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterYWithinMargins];
}

#endif

#if (__IPHONE_OS_VERSION_MAX_ALLOWED >= 110000) || (__TV_OS_VERSION_MAX_ALLOWED >= 110000)

- (EaseViewAttribute *)ease_safeAreaLayoutGuide {
    return [[EaseViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeBottom];
}
- (EaseViewAttribute *)ease_safeAreaLayoutGuideTop {
    return [[EaseViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeTop];
}
- (EaseViewAttribute *)ease_safeAreaLayoutGuideBottom {
    return [[EaseViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeBottom];
}
- (EaseViewAttribute *)ease_safeAreaLayoutGuideLeft {
    return [[EaseViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeLeft];
}
- (EaseViewAttribute *)ease_safeAreaLayoutGuideRight {
    return [[EaseViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeRight];
}

#endif

#pragma mark - associated properties

- (id)ease_key {
    return objc_getAssociatedObject(self, @selector(ease_key));
}

- (void)setEase_key:(id)key {
    objc_setAssociatedObject(self, @selector(ease_key), key, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - heirachy

- (instancetype)Ease_closestCommonSuperview:(Ease_VIEW *)view {
    Ease_VIEW *closestCommonSuperview = nil;

    Ease_VIEW *secondViewSuperview = view;
    while (!closestCommonSuperview && secondViewSuperview) {
        Ease_VIEW *firstViewSuperview = self;
        while (!closestCommonSuperview && firstViewSuperview) {
            if (secondViewSuperview == firstViewSuperview) {
                closestCommonSuperview = secondViewSuperview;
            }
            firstViewSuperview = firstViewSuperview.superview;
        }
        secondViewSuperview = secondViewSuperview.superview;
    }
    return closestCommonSuperview;
}

@end
