//
//  EaseCompositeConstraint.h
//  Easeonry
//
//  Created by Jonas Budelmann on 21/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "EaseConstraint.h"
#import "EaseUtilities.h"

/**
 *	A group of EaseConstraint objects
 */
@interface EaseCompositeConstraint : EaseConstraint

/**
 *	Creates a composite with a predefined array of children
 *
 *	@param	children	child EaseConstraints
 *
 *	@return	a composite constraint
 */
- (id)initWithChildren:(NSArray *)children;

@end
