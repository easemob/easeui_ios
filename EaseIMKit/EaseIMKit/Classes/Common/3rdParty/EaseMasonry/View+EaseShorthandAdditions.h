//
//  UIView+EaseShorthandAdditions.h
//  Easeonry
//
//  Created by Jonas Budelmann on 22/07/13.
//  Copyright (c) 2013 Jonas Budelmann. All rights reserved.
//

#import "View+EaseAdditions.h"

#ifdef Ease_SHORTHAND

/**
 *	Shorthand view additions without the 'Ease_' prefixes,
 *  only enabled if Ease_SHORTHAND is defined
 */
@interface Ease_VIEW (EaseShorthandAdditions)

@property (nonatomic, strong, readonly) EaseViewAttribute *left;
@property (nonatomic, strong, readonly) EaseViewAttribute *top;
@property (nonatomic, strong, readonly) EaseViewAttribute *right;
@property (nonatomic, strong, readonly) EaseViewAttribute *bottom;
@property (nonatomic, strong, readonly) EaseViewAttribute *leading;
@property (nonatomic, strong, readonly) EaseViewAttribute *trailing;
@property (nonatomic, strong, readonly) EaseViewAttribute *width;
@property (nonatomic, strong, readonly) EaseViewAttribute *height;
@property (nonatomic, strong, readonly) EaseViewAttribute *centerX;
@property (nonatomic, strong, readonly) EaseViewAttribute *centerY;
@property (nonatomic, strong, readonly) EaseViewAttribute *baseline;
@property (nonatomic, strong, readonly) EaseViewAttribute *(^attribute)(NSLayoutAttribute attr);

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

@property (nonatomic, strong, readonly) EaseViewAttribute *firstBaseline;
@property (nonatomic, strong, readonly) EaseViewAttribute *lastBaseline;

#endif

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

@property (nonatomic, strong, readonly) EaseViewAttribute *leftMargin;
@property (nonatomic, strong, readonly) EaseViewAttribute *rightMargin;
@property (nonatomic, strong, readonly) EaseViewAttribute *topMargin;
@property (nonatomic, strong, readonly) EaseViewAttribute *bottomMargin;
@property (nonatomic, strong, readonly) EaseViewAttribute *leadingMargin;
@property (nonatomic, strong, readonly) EaseViewAttribute *trailingMargin;
@property (nonatomic, strong, readonly) EaseViewAttribute *centerXWithinMargins;
@property (nonatomic, strong, readonly) EaseViewAttribute *centerYWithinMargins;

#endif

#if (__IPHONE_OS_VERSION_MAX_ALLOWED >= 110000) || (__TV_OS_VERSION_MAX_ALLOWED >= 110000)

@property (nonatomic, strong, readonly) EaseViewAttribute *safeAreaLayoutGuideTop API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) EaseViewAttribute *safeAreaLayoutGuideBottom API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) EaseViewAttribute *safeAreaLayoutGuideLeft API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) EaseViewAttribute *safeAreaLayoutGuideRight API_AVAILABLE(ios(11.0),tvos(11.0));

#endif

- (NSArray *)makeConstraints:(void(^)(EaseConstraintMaker *make))block;
- (NSArray *)updateConstraints:(void(^)(EaseConstraintMaker *make))block;
- (NSArray *)remakeConstraints:(void(^)(EaseConstraintMaker *make))block;

@end

#define Ease_ATTR_FORWARD(attr)  \
- (EaseViewAttribute *)attr {    \
    return [self Ease_##attr];   \
}

@implementation Ease_VIEW (EaseShorthandAdditions)

Ease_ATTR_FORWARD(top);
Ease_ATTR_FORWARD(left);
Ease_ATTR_FORWARD(bottom);
Ease_ATTR_FORWARD(right);
Ease_ATTR_FORWARD(leading);
Ease_ATTR_FORWARD(trailing);
Ease_ATTR_FORWARD(width);
Ease_ATTR_FORWARD(height);
Ease_ATTR_FORWARD(centerX);
Ease_ATTR_FORWARD(centerY);
Ease_ATTR_FORWARD(baseline);

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

Ease_ATTR_FORWARD(firstBaseline);
Ease_ATTR_FORWARD(lastBaseline);

#endif

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

Ease_ATTR_FORWARD(leftMargin);
Ease_ATTR_FORWARD(rightMargin);
Ease_ATTR_FORWARD(topMargin);
Ease_ATTR_FORWARD(bottomMargin);
Ease_ATTR_FORWARD(leadingMargin);
Ease_ATTR_FORWARD(trailingMargin);
Ease_ATTR_FORWARD(centerXWithinMargins);
Ease_ATTR_FORWARD(centerYWithinMargins);

#endif

#if (__IPHONE_OS_VERSION_MAX_ALLOWED >= 110000) || (__TV_OS_VERSION_MAX_ALLOWED >= 110000)

Ease_ATTR_FORWARD(safeAreaLayoutGuideTop);
Ease_ATTR_FORWARD(safeAreaLayoutGuideBottom);
Ease_ATTR_FORWARD(safeAreaLayoutGuideLeft);
Ease_ATTR_FORWARD(safeAreaLayoutGuideRight);

#endif

- (EaseViewAttribute *(^)(NSLayoutAttribute))attribute {
    return [self Ease_attribute];
}

- (NSArray *)makeConstraints:(void(NS_NOESCAPE ^)(EaseConstraintMaker *))block {
    return [self Ease_makeConstraints:block];
}

- (NSArray *)updateConstraints:(void(NS_NOESCAPE ^)(EaseConstraintMaker *))block {
    return [self Ease_updateConstraints:block];
}

- (NSArray *)remakeConstraints:(void(NS_NOESCAPE ^)(EaseConstraintMaker *))block {
    return [self Ease_remakeConstraints:block];
}

@end

#endif
