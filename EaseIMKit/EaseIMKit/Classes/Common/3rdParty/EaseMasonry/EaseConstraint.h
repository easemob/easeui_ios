//
//  EaseConstraint.h
//  Easeonry
//
//  Created by Jonas Budelmann on 22/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "EaseUtilities.h"

/**
 *	Enables Constraints to be created with chainable syntax
 *  Constraint can represent single NSLayoutConstraint (EaseViewConstraint) 
 *  or a group of NSLayoutConstraints (EaseComposisteConstraint)
 */
@interface EaseConstraint : NSObject

// Chaining Support

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects EaseConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeTop, NSLayoutAttributeLeft, NSLayoutAttributeBottom, NSLayoutAttributeRight
 */
- (EaseConstraint * (^)(EaseEdgeInsets insets))insets;

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects EaseConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeTop, NSLayoutAttributeLeft, NSLayoutAttributeBottom, NSLayoutAttributeRight
 */
- (EaseConstraint * (^)(CGFloat inset))inset;

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects EaseConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeWidth, NSLayoutAttributeHeight
 */
- (EaseConstraint * (^)(CGSize offset))sizeOffset;

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects EaseConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeCenterX, NSLayoutAttributeCenterY
 */
- (EaseConstraint * (^)(CGPoint offset))centerOffset;

/**
 *	Modifies the NSLayoutConstraint constant
 */
- (EaseConstraint * (^)(CGFloat offset))offset;

/**
 *  Modifies the NSLayoutConstraint constant based on a value type
 */
- (EaseConstraint * (^)(NSValue *value))valueOffset;

/**
 *	Sets the NSLayoutConstraint multiplier property
 */
- (EaseConstraint * (^)(CGFloat multiplier))multipliedBy;

/**
 *	Sets the NSLayoutConstraint multiplier to 1.0/dividedBy
 */
- (EaseConstraint * (^)(CGFloat divider))dividedBy;

/**
 *	Sets the NSLayoutConstraint priority to a float or EaseLayoutPriority
 */
- (EaseConstraint * (^)(EaseLayoutPriority priority))priority;

/**
 *	Sets the NSLayoutConstraint priority to EaseLayoutPriorityLow
 */
- (EaseConstraint * (^)(void))priorityLow;

/**
 *	Sets the NSLayoutConstraint priority to EaseLayoutPriorityMedium
 */
- (EaseConstraint * (^)(void))priorityMedium;

/**
 *	Sets the NSLayoutConstraint priority to EaseLayoutPriorityHigh
 */
- (EaseConstraint * (^)(void))priorityHigh;

/**
 *	Sets the constraint relation to NSLayoutRelationEqual
 *  returns a block which accepts one of the following:
 *    EaseViewAttribute, UIView, NSValue, NSArray
 *  see readme for more details.
 */
- (EaseConstraint * (^)(id attr))equalTo;

/**
 *	Sets the constraint relation to NSLayoutRelationGreaterThanOrEqual
 *  returns a block which accepts one of the following:
 *    EaseViewAttribute, UIView, NSValue, NSArray
 *  see readme for more details.
 */
- (EaseConstraint * (^)(id attr))greaterThanOrEqualTo;

/**
 *	Sets the constraint relation to NSLayoutRelationLessThanOrEqual
 *  returns a block which accepts one of the following:
 *    EaseViewAttribute, UIView, NSValue, NSArray
 *  see readme for more details.
 */
- (EaseConstraint * (^)(id attr))lessThanOrEqualTo;

/**
 *	Optional semantic property which has no effect but improves the readability of constraint
 */
- (EaseConstraint *)with;

/**
 *	Optional semantic property which has no effect but improves the readability of constraint
 */
- (EaseConstraint *)and;

/**
 *	Creates a new EaseCompositeConstraint with the called attribute and reciever
 */
- (EaseConstraint *)left;
- (EaseConstraint *)top;
- (EaseConstraint *)right;
- (EaseConstraint *)bottom;
- (EaseConstraint *)leading;
- (EaseConstraint *)trailing;
- (EaseConstraint *)width;
- (EaseConstraint *)height;
- (EaseConstraint *)centerX;
- (EaseConstraint *)centerY;
- (EaseConstraint *)baseline;

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

- (EaseConstraint *)firstBaseline;
- (EaseConstraint *)lastBaseline;

#endif

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

- (EaseConstraint *)leftMargin;
- (EaseConstraint *)rightMargin;
- (EaseConstraint *)topMargin;
- (EaseConstraint *)bottomMargin;
- (EaseConstraint *)leadingMargin;
- (EaseConstraint *)trailingMargin;
- (EaseConstraint *)centerXWithinMargins;
- (EaseConstraint *)centerYWithinMargins;

#endif


/**
 *	Sets the constraint debug name
 */
- (EaseConstraint * (^)(id key))key;

// NSLayoutConstraint constant Setters
// for use outside of Ease_updateConstraints/Ease_makeConstraints blocks

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects EaseConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeTop, NSLayoutAttributeLeft, NSLayoutAttributeBottom, NSLayoutAttributeRight
 */
- (void)setInsets:(EaseEdgeInsets)insets;

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects EaseConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeTop, NSLayoutAttributeLeft, NSLayoutAttributeBottom, NSLayoutAttributeRight
 */
- (void)setInset:(CGFloat)inset;

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects EaseConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeWidth, NSLayoutAttributeHeight
 */
- (void)setSizeOffset:(CGSize)sizeOffset;

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects EaseConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeCenterX, NSLayoutAttributeCenterY
 */
- (void)setCenterOffset:(CGPoint)centerOffset;

/**
 *	Modifies the NSLayoutConstraint constant
 */
- (void)setOffset:(CGFloat)offset;


// NSLayoutConstraint Installation support

#if TARGET_OS_MAC && !(TARGET_OS_IPHONE || TARGET_OS_TV)
/**
 *  Whether or not to go through the animator proxy when modifying the constraint
 */
@property (nonatomic, copy, readonly) EaseConstraint *animator;
#endif

/**
 *  Activates an NSLayoutConstraint if it's supported by an OS. 
 *  Invokes install otherwise.
 */
- (void)activate;

/**
 *  Deactivates previously installed/activated NSLayoutConstraint.
 */
- (void)deactivate;

/**
 *	Creates a NSLayoutConstraint and adds it to the appropriate view.
 */
- (void)install;

/**
 *	Removes previously installed NSLayoutConstraint
 */
- (void)uninstall;

@end


/**
 *  Convenience auto-boxing macros for EaseConstraint methods.
 *
 *  Defining Ease_SHORTHAND_GLOBALS will turn on auto-boxing for default syntax.
 *  A potential drawback of this is that the unprefixed macros will appear in global scope.
 */
#define Ease_equalTo(...)                 equalTo(EaseBoxValue((__VA_ARGS__)))
#define Ease_greaterThanOrEqualTo(...)    greaterThanOrEqualTo(EaseBoxValue((__VA_ARGS__)))
#define Ease_lessThanOrEqualTo(...)       lessThanOrEqualTo(EaseBoxValue((__VA_ARGS__)))

#define Ease_offset(...)                  valueOffset(EaseBoxValue((__VA_ARGS__)))


#ifdef Ease_SHORTHAND_GLOBALS

#define equalTo(...)                     Ease_equalTo(__VA_ARGS__)
#define greaterThanOrEqualTo(...)        Ease_greaterThanOrEqualTo(__VA_ARGS__)
#define lessThanOrEqualTo(...)           Ease_lessThanOrEqualTo(__VA_ARGS__)

#define offset(...)                      Ease_offset(__VA_ARGS__)

#endif


@interface EaseConstraint (AutoboxingSupport)

/**
 *  Aliases to corresponding relation methods (for shorthand macros)
 *  Also needed to aid autocompletion
 */
- (EaseConstraint * (^)(id attr))Ease_equalTo;
- (EaseConstraint * (^)(id attr))Ease_greaterThanOrEqualTo;
- (EaseConstraint * (^)(id attr))Ease_lessThanOrEqualTo;

/**
 *  A dummy method to aid autocompletion
 */
- (EaseConstraint * (^)(id offset))Ease_offset;

@end
