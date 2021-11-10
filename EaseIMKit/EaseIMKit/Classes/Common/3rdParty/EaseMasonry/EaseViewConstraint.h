//
//  EaseViewConstraint.h
//  Easeonry
//
//  Created by Jonas Budelmann on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "EaseViewAttribute.h"
#import "EaseConstraint.h"
#import "EaseLayoutConstraint.h"
#import "EaseUtilities.h"

/**
 *  A single constraint.
 *  Contains the attributes neccessary for creating a NSLayoutConstraint and adding it to the appropriate view
 */
@interface EaseViewConstraint : EaseConstraint <NSCopying>

/**
 *	First item/view and first attribute of the NSLayoutConstraint
 */
@property (nonatomic, strong, readonly) EaseViewAttribute *firstViewAttribute;

/**
 *	Second item/view and second attribute of the NSLayoutConstraint
 */
@property (nonatomic, strong, readonly) EaseViewAttribute *secondViewAttribute;

/**
 *	initialises the EaseViewConstraint with the first part of the equation
 *
 *	@param	firstViewAttribute	view.Ease_left, view.Ease_width etc.
 *
 *	@return	a new view constraint
 */
- (id)initWithFirstViewAttribute:(EaseViewAttribute *)firstViewAttribute;

/**
 *  Returns all EaseViewConstraints installed with this view as a first item.
 *
 *  @param  view  A view to retrieve constraints for.
 *
 *  @return An array of EaseViewConstraints.
 */
+ (NSArray *)installedConstraintsForView:(Ease_VIEW *)view;

@end
