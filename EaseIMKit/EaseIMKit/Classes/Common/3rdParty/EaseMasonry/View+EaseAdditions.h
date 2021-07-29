//
//  UIView+EaseAdditions.h
//  Easeonry
//
//  Created by Jonas Budelmann on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "EaseUtilities.h"
#import "EaseConstraintMaker.h"
#import "EaseViewAttribute.h"

/**
 *	Provides constraint maker block
 *  and convience methods for creating EaseViewAttribute which are view + NSLayoutAttribute pairs
 */
@interface Ease_VIEW (EaseAdditions)

/**
 *	following properties return a new EaseViewAttribute with current view and appropriate NSLayoutAttribute
 */
@property (nonatomic, strong, readonly) EaseViewAttribute *ease_left;
@property (nonatomic, strong, readonly) EaseViewAttribute *ease_top;
@property (nonatomic, strong, readonly) EaseViewAttribute *ease_right;
@property (nonatomic, strong, readonly) EaseViewAttribute *ease_bottom;
@property (nonatomic, strong, readonly) EaseViewAttribute *ease_leading;
@property (nonatomic, strong, readonly) EaseViewAttribute *ease_trailing;
@property (nonatomic, strong, readonly) EaseViewAttribute *ease_width;
@property (nonatomic, strong, readonly) EaseViewAttribute *ease_height;
@property (nonatomic, strong, readonly) EaseViewAttribute *ease_centerX;
@property (nonatomic, strong, readonly) EaseViewAttribute *ease_centerY;
@property (nonatomic, strong, readonly) EaseViewAttribute *ease_baseline;
@property (nonatomic, strong, readonly) EaseViewAttribute *(^ease_attribute)(NSLayoutAttribute attr);

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

@property (nonatomic, strong, readonly) EaseViewAttribute *ease_firstBaseline;
@property (nonatomic, strong, readonly) EaseViewAttribute *ease_lastBaseline;

#endif

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

@property (nonatomic, strong, readonly) EaseViewAttribute *ease_leftMargin;
@property (nonatomic, strong, readonly) EaseViewAttribute *ease_rightMargin;
@property (nonatomic, strong, readonly) EaseViewAttribute *ease_topMargin;
@property (nonatomic, strong, readonly) EaseViewAttribute *ease_bottomMargin;
@property (nonatomic, strong, readonly) EaseViewAttribute *ease_leadingMargin;
@property (nonatomic, strong, readonly) EaseViewAttribute *ease_trailingMargin;
@property (nonatomic, strong, readonly) EaseViewAttribute *ease_centerXWithinMargins;
@property (nonatomic, strong, readonly) EaseViewAttribute *ease_centerYWithinMargins;

#endif

#if (__IPHONE_OS_VERSION_MAX_ALLOWED >= 110000) || (__TV_OS_VERSION_MAX_ALLOWED >= 110000)

@property (nonatomic, strong, readonly) EaseViewAttribute *ease_safeAreaLayoutGuide API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) EaseViewAttribute *ease_safeAreaLayoutGuideTop API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) EaseViewAttribute *ease_safeAreaLayoutGuideBottom API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) EaseViewAttribute *ease_safeAreaLayoutGuideLeft API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) EaseViewAttribute *ease_safeAreaLayoutGuideRight API_AVAILABLE(ios(11.0),tvos(11.0));

#endif

/**
 *	a key to associate with this view
 */
@property (nonatomic, strong) id ease_key;

/**
 *	Finds the closest common superview between this view and another view
 *
 *	@param	view	other view
 *
 *	@return	returns nil if common superview could not be found
 */
- (instancetype)Ease_closestCommonSuperview:(Ease_VIEW *)view;

/**
 *  Creates a EaseConstraintMaker with the callee view.
 *  Any constraints defined are added to the view or the appropriate superview once the block has finished executing
 *
 *  @param block scope within which you can build up the constraints which you wish to apply to the view.
 *
 *  @return Array of created EaseConstraints
 */
- (NSArray *)Ease_makeConstraints:(void(NS_NOESCAPE ^)(EaseConstraintMaker *make))block;

/**
 *  Creates a EaseConstraintMaker with the callee view.
 *  Any constraints defined are added to the view or the appropriate superview once the block has finished executing.
 *  If an existing constraint exists then it will be updated instead.
 *
 *  @param block scope within which you can build up the constraints which you wish to apply to the view.
 *
 *  @return Array of created/updated EaseConstraints
 */
- (NSArray *)Ease_updateConstraints:(void(NS_NOESCAPE ^)(EaseConstraintMaker *make))block;

/**
 *  Creates a EaseConstraintMaker with the callee view.
 *  Any constraints defined are added to the view or the appropriate superview once the block has finished executing.
 *  All constraints previously installed for the view will be removed.
 *
 *  @param block scope within which you can build up the constraints which you wish to apply to the view.
 *
 *  @return Array of created/updated EaseConstraints
 */
- (NSArray *)Ease_remakeConstraints:(void(NS_NOESCAPE ^)(EaseConstraintMaker *make))block;

@end
