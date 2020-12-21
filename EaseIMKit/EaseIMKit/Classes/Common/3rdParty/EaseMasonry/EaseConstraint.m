//
//  EaseConstraint.m
//  Easeonry
//
//  Created by Nick Tymchenko on 1/20/14.
//

#import "EaseConstraint.h"
#import "EaseConstraint+Private.h"

#define EaseMethodNotImplemented() \
    @throw [NSException exceptionWithName:NSInternalInconsistencyException \
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)] \
                                 userInfo:nil]

@implementation EaseConstraint

#pragma mark - Init

- (id)init {
	NSAssert(![self isMemberOfClass:[EaseConstraint class]], @"EaseConstraint is an abstract class, you should not instantiate it directly.");
	return [super init];
}

#pragma mark - NSLayoutRelation proxies

- (EaseConstraint * (^)(id))equalTo {
    return ^id(id attribute) {
        return self.equalToWithRelation(attribute, NSLayoutRelationEqual);
    };
}

- (EaseConstraint * (^)(id))Ease_equalTo {
    return ^id(id attribute) {
        return self.equalToWithRelation(attribute, NSLayoutRelationEqual);
    };
}

- (EaseConstraint * (^)(id))greaterThanOrEqualTo {
    return ^id(id attribute) {
        return self.equalToWithRelation(attribute, NSLayoutRelationGreaterThanOrEqual);
    };
}

- (EaseConstraint * (^)(id))Ease_greaterThanOrEqualTo {
    return ^id(id attribute) {
        return self.equalToWithRelation(attribute, NSLayoutRelationGreaterThanOrEqual);
    };
}

- (EaseConstraint * (^)(id))lessThanOrEqualTo {
    return ^id(id attribute) {
        return self.equalToWithRelation(attribute, NSLayoutRelationLessThanOrEqual);
    };
}

- (EaseConstraint * (^)(id))Ease_lessThanOrEqualTo {
    return ^id(id attribute) {
        return self.equalToWithRelation(attribute, NSLayoutRelationLessThanOrEqual);
    };
}

#pragma mark - EaseLayoutPriority proxies

- (EaseConstraint * (^)(void))priorityLow {
    return ^id{
        self.priority(EaseLayoutPriorityDefaultLow);
        return self;
    };
}

- (EaseConstraint * (^)(void))priorityMedium {
    return ^id{
        self.priority(EaseLayoutPriorityDefaultMedium);
        return self;
    };
}

- (EaseConstraint * (^)(void))priorityHigh {
    return ^id{
        self.priority(EaseLayoutPriorityDefaultHigh);
        return self;
    };
}

#pragma mark - NSLayoutConstraint constant proxies

- (EaseConstraint * (^)(EaseEdgeInsets))insets {
    return ^id(EaseEdgeInsets insets){
        self.insets = insets;
        return self;
    };
}

- (EaseConstraint * (^)(CGFloat))inset {
    return ^id(CGFloat inset){
        self.inset = inset;
        return self;
    };
}

- (EaseConstraint * (^)(CGSize))sizeOffset {
    return ^id(CGSize offset) {
        self.sizeOffset = offset;
        return self;
    };
}

- (EaseConstraint * (^)(CGPoint))centerOffset {
    return ^id(CGPoint offset) {
        self.centerOffset = offset;
        return self;
    };
}

- (EaseConstraint * (^)(CGFloat))offset {
    return ^id(CGFloat offset){
        self.offset = offset;
        return self;
    };
}

- (EaseConstraint * (^)(NSValue *value))valueOffset {
    return ^id(NSValue *offset) {
        NSAssert([offset isKindOfClass:NSValue.class], @"expected an NSValue offset, got: %@", offset);
        [self setLayoutConstantWithValue:offset];
        return self;
    };
}

- (EaseConstraint * (^)(id offset))Ease_offset {
    // Will never be called due to macro
    return nil;
}

#pragma mark - NSLayoutConstraint constant setter

- (void)setLayoutConstantWithValue:(NSValue *)value {
    if ([value isKindOfClass:NSNumber.class]) {
        self.offset = [(NSNumber *)value doubleValue];
    } else if (strcmp(value.objCType, @encode(CGPoint)) == 0) {
        CGPoint point;
        [value getValue:&point];
        self.centerOffset = point;
    } else if (strcmp(value.objCType, @encode(CGSize)) == 0) {
        CGSize size;
        [value getValue:&size];
        self.sizeOffset = size;
    } else if (strcmp(value.objCType, @encode(EaseEdgeInsets)) == 0) {
        EaseEdgeInsets insets;
        [value getValue:&insets];
        self.insets = insets;
    } else {
        NSAssert(NO, @"attempting to set layout constant with unsupported value: %@", value);
    }
}

#pragma mark - Semantic properties

- (EaseConstraint *)with {
    return self;
}

- (EaseConstraint *)and {
    return self;
}

#pragma mark - Chaining

- (EaseConstraint *)addConstraintWithLayoutAttribute:(NSLayoutAttribute __unused)layoutAttribute {
    EaseMethodNotImplemented();
}

- (EaseConstraint *)left {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeLeft];
}

- (EaseConstraint *)top {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeTop];
}

- (EaseConstraint *)right {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeRight];
}

- (EaseConstraint *)bottom {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeBottom];
}

- (EaseConstraint *)leading {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeLeading];
}

- (EaseConstraint *)trailing {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeTrailing];
}

- (EaseConstraint *)width {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeWidth];
}

- (EaseConstraint *)height {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeHeight];
}

- (EaseConstraint *)centerX {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeCenterX];
}

- (EaseConstraint *)centerY {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeCenterY];
}

- (EaseConstraint *)baseline {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeBaseline];
}

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

- (EaseConstraint *)firstBaseline {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeFirstBaseline];
}
- (EaseConstraint *)lastBaseline {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeLastBaseline];
}

#endif

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

- (EaseConstraint *)leftMargin {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeLeftMargin];
}

- (EaseConstraint *)rightMargin {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeRightMargin];
}

- (EaseConstraint *)topMargin {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeTopMargin];
}

- (EaseConstraint *)bottomMargin {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeBottomMargin];
}

- (EaseConstraint *)leadingMargin {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeLeadingMargin];
}

- (EaseConstraint *)trailingMargin {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeTrailingMargin];
}

- (EaseConstraint *)centerXWithinMargins {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeCenterXWithinMargins];
}

- (EaseConstraint *)centerYWithinMargins {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeCenterYWithinMargins];
}

#endif

#pragma mark - Abstract

- (EaseConstraint * (^)(CGFloat multiplier))multipliedBy { EaseMethodNotImplemented(); }

- (EaseConstraint * (^)(CGFloat divider))dividedBy { EaseMethodNotImplemented(); }

- (EaseConstraint * (^)(EaseLayoutPriority priority))priority { EaseMethodNotImplemented(); }

- (EaseConstraint * (^)(id, NSLayoutRelation))equalToWithRelation { EaseMethodNotImplemented(); }

- (EaseConstraint * (^)(id key))key { EaseMethodNotImplemented(); }

- (void)setInsets:(EaseEdgeInsets __unused)insets { EaseMethodNotImplemented(); }

- (void)setInset:(CGFloat __unused)inset { EaseMethodNotImplemented(); }

- (void)setSizeOffset:(CGSize __unused)sizeOffset { EaseMethodNotImplemented(); }

- (void)setCenterOffset:(CGPoint __unused)centerOffset { EaseMethodNotImplemented(); }

- (void)setOffset:(CGFloat __unused)offset { EaseMethodNotImplemented(); }

#if TARGET_OS_MAC && !(TARGET_OS_IPHONE || TARGET_OS_TV)

- (EaseConstraint *)animator { EaseMethodNotImplemented(); }

#endif

- (void)activate { EaseMethodNotImplemented(); }

- (void)deactivate { EaseMethodNotImplemented(); }

- (void)install { EaseMethodNotImplemented(); }

- (void)uninstall { EaseMethodNotImplemented(); }

@end
