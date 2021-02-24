//
//  NSArray+EaseShorthandAdditions.h
//  Easeonry
//
//  Created by Jonas Budelmann on 22/07/13.
//  Copyright (c) 2013 Jonas Budelmann. All rights reserved.
//

#import "NSArray+EaseAdditions.h"

#ifdef Ease_SHORTHAND

/**
 *	Shorthand array additions without the 'Ease_' prefixes,
 *  only enabled if Ease_SHORTHAND is defined
 */
@interface NSArray (EaseShorthandAdditions)

- (NSArray *)makeConstraints:(void(^)(EaseConstraintMaker *make))block;
- (NSArray *)updateConstraints:(void(^)(EaseConstraintMaker *make))block;
- (NSArray *)remakeConstraints:(void(^)(EaseConstraintMaker *make))block;

@end

@implementation NSArray (EaseShorthandAdditions)

- (NSArray *)makeConstraints:(void(^)(EaseConstraintMaker *))block {
    return [self Ease_makeConstraints:block];
}

- (NSArray *)updateConstraints:(void(^)(EaseConstraintMaker *))block {
    return [self Ease_updateConstraints:block];
}

- (NSArray *)remakeConstraints:(void(^)(EaseConstraintMaker *))block {
    return [self Ease_remakeConstraints:block];
}

@end

#endif
