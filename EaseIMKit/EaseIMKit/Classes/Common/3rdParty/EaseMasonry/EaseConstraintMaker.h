//
//  EaseConstraintMaker.h
//  Easeonry
//
//  Created by Jonas Budelmann on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "EaseConstraint.h"
#import "EaseUtilities.h"

typedef NS_OPTIONS(NSInteger, EaseAttribute) {
    EaseAttributeLeft = 1 << NSLayoutAttributeLeft,
    EaseAttributeRight = 1 << NSLayoutAttributeRight,
    EaseAttributeTop = 1 << NSLayoutAttributeTop,
    EaseAttributeBottom = 1 << NSLayoutAttributeBottom,
    EaseAttributeLeading = 1 << NSLayoutAttributeLeading,
    EaseAttributeTrailing = 1 << NSLayoutAttributeTrailing,
    EaseAttributeWidth = 1 << NSLayoutAttributeWidth,
    EaseAttributeHeight = 1 << NSLayoutAttributeHeight,
    EaseAttributeCenterX = 1 << NSLayoutAttributeCenterX,
    EaseAttributeCenterY = 1 << NSLayoutAttributeCenterY,
    EaseAttributeBaseline = 1 << NSLayoutAttributeBaseline,
    
#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)
    
    EaseAttributeFirstBaseline = 1 << NSLayoutAttributeFirstBaseline,
    EaseAttributeLastBaseline = 1 << NSLayoutAttributeLastBaseline,
    
#endif
    
#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)
    
    EaseAttributeLeftMargin = 1 << NSLayoutAttributeLeftMargin,
    EaseAttributeRightMargin = 1 << NSLayoutAttributeRightMargin,
    EaseAttributeTopMargin = 1 << NSLayoutAttributeTopMargin,
    EaseAttributeBottomMargin = 1 << NSLayoutAttributeBottomMargin,
    EaseAttributeLeadingMargin = 1 << NSLayoutAttributeLeadingMargin,
    EaseAttributeTrailingMargin = 1 << NSLayoutAttributeTrailingMargin,
    EaseAttributeCenterXWithinMargins = 1 << NSLayoutAttributeCenterXWithinMargins,
    EaseAttributeCenterYWithinMargins = 1 << NSLayoutAttributeCenterYWithinMargins,

#endif
    
};

/**
 *  Provides factory methods for creating EaseConstraints.
 *  Constraints are collected until they are ready to be installed
 *
 */
@interface EaseConstraintMaker : NSObject

/**
 *	The following properties return a new EaseViewConstraint
 *  with the first item set to the makers associated view and the appropriate EaseViewAttribute
 */
@property (nonatomic, strong, readonly) EaseConstraint *left;
@property (nonatomic, strong, readonly) EaseConstraint *top;
@property (nonatomic, strong, readonly) EaseConstraint *right;
@property (nonatomic, strong, readonly) EaseConstraint *bottom;
@property (nonatomic, strong, readonly) EaseConstraint *leading;
@property (nonatomic, strong, readonly) EaseConstraint *trailing;
@property (nonatomic, strong, readonly) EaseConstraint *width;
@property (nonatomic, strong, readonly) EaseConstraint *height;
@property (nonatomic, strong, readonly) EaseConstraint *centerX;
@property (nonatomic, strong, readonly) EaseConstraint *centerY;
@property (nonatomic, strong, readonly) EaseConstraint *baseline;

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

@property (nonatomic, strong, readonly) EaseConstraint *firstBaseline;
@property (nonatomic, strong, readonly) EaseConstraint *lastBaseline;

#endif

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

@property (nonatomic, strong, readonly) EaseConstraint *leftMargin;
@property (nonatomic, strong, readonly) EaseConstraint *rightMargin;
@property (nonatomic, strong, readonly) EaseConstraint *topMargin;
@property (nonatomic, strong, readonly) EaseConstraint *bottomMargin;
@property (nonatomic, strong, readonly) EaseConstraint *leadingMargin;
@property (nonatomic, strong, readonly) EaseConstraint *trailingMargin;
@property (nonatomic, strong, readonly) EaseConstraint *centerXWithinMargins;
@property (nonatomic, strong, readonly) EaseConstraint *centerYWithinMargins;

#endif

/**
 *  Returns a block which creates a new EaseCompositeConstraint with the first item set
 *  to the makers associated view and children corresponding to the set bits in the
 *  EaseAttribute parameter. Combine multiple attributes via binary-or.
 */
@property (nonatomic, strong, readonly) EaseConstraint *(^attributes)(EaseAttribute attrs);

/**
 *	Creates a EaseCompositeConstraint with type EaseCompositeConstraintTypeEdges
 *  which generates the appropriate EaseViewConstraint children (top, left, bottom, right)
 *  with the first item set to the makers associated view
 */
@property (nonatomic, strong, readonly) EaseConstraint *edges;

/**
 *	Creates a EaseCompositeConstraint with type EaseCompositeConstraintTypeSize
 *  which generates the appropriate EaseViewConstraint children (width, height)
 *  with the first item set to the makers associated view
 */
@property (nonatomic, strong, readonly) EaseConstraint *size;

/**
 *	Creates a EaseCompositeConstraint with type EaseCompositeConstraintTypeCenter
 *  which generates the appropriate EaseViewConstraint children (centerX, centerY)
 *  with the first item set to the makers associated view
 */
@property (nonatomic, strong, readonly) EaseConstraint *center;

/**
 *  Whether or not to check for an existing constraint instead of adding constraint
 */
@property (nonatomic, assign) BOOL updateExisting;

/**
 *  Whether or not to remove existing constraints prior to installing
 */
@property (nonatomic, assign) BOOL removeExisting;

/**
 *	initialises the maker with a default view
 *
 *	@param	view	any EaseConstraint are created with this view as the first item
 *
 *	@return	a new EaseConstraintMaker
 */
- (id)initWithView:(Ease_VIEW *)view;

/**
 *	Calls install method on any EaseConstraints which have been created by this maker
 *
 *	@return	an array of all the installed EaseConstraints
 */
- (NSArray *)install;

- (EaseConstraint * (^)(dispatch_block_t))group;

@end
