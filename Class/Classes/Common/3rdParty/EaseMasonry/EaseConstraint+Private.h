//
//  EaseConstraint+Private.h
//  Easeonry
//
//  Created by Nick Tymchenko on 29/04/14.
//  Copyright (c) 2014 cloudling. All rights reserved.
//

#import "EaseConstraint.h"

@protocol EaseConstraintDelegate;


@interface EaseConstraint ()

/**
 *  Whether or not to check for an existing constraint instead of adding constraint
 */
@property (nonatomic, assign) BOOL updateExisting;

/**
 *	Usually EaseConstraintMaker but could be a parent EaseConstraint
 */
@property (nonatomic, weak) id<EaseConstraintDelegate> delegate;

/**
 *  Based on a provided value type, is equal to calling:
 *  NSNumber - setOffset:
 *  NSValue with CGPoint - setPointOffset:
 *  NSValue with CGSize - setSizeOffset:
 *  NSValue with EaseEdgeInsets - setInsets:
 */
- (void)setLayoutConstantWithValue:(NSValue *)value;

@end


@interface EaseConstraint (Abstract)

/**
 *	Sets the constraint relation to given NSLayoutRelation
 *  returns a block which accepts one of the following:
 *    EaseViewAttribute, UIView, NSValue, NSArray
 *  see readme for more details.
 */
- (EaseConstraint * (^)(id, NSLayoutRelation))equalToWithRelation;

/**
 *	Override to set a custom chaining behaviour
 */
- (EaseConstraint *)addConstraintWithLayoutAttribute:(NSLayoutAttribute)layoutAttribute;

@end


@protocol EaseConstraintDelegate <NSObject>

/**
 *	Notifies the delegate when the constraint needs to be replaced with another constraint. For example
 *  A EaseViewConstraint may turn into a EaseCompositeConstraint when an array is passed to one of the equality blocks
 */
- (void)constraint:(EaseConstraint *)constraint shouldBeReplacedWithConstraint:(EaseConstraint *)replacementConstraint;

- (EaseConstraint *)constraint:(EaseConstraint *)constraint addConstraintWithLayoutAttribute:(NSLayoutAttribute)layoutAttribute;

@end
