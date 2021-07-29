//
//  EaseConstraintMaker.m
//  Easeonry
//
//  Created by Jonas Budelmann on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "EaseConstraintMaker.h"
#import "EaseViewConstraint.h"
#import "EaseCompositeConstraint.h"
#import "EaseConstraint+Private.h"
#import "EaseViewAttribute.h"
#import "View+EaseAdditions.h"

@interface EaseConstraintMaker () <EaseConstraintDelegate>

@property (nonatomic, weak) Ease_VIEW *view;
@property (nonatomic, strong) NSMutableArray *constraints;

@end

@implementation EaseConstraintMaker

- (id)initWithView:(Ease_VIEW *)view {
    self = [super init];
    if (!self) return nil;
    
    self.view = view;
    self.constraints = NSMutableArray.new;
    
    return self;
}

- (NSArray *)install {
    if (self.removeExisting) {
        NSArray *installedConstraints = [EaseViewConstraint installedConstraintsForView:self.view];
        for (EaseConstraint *constraint in installedConstraints) {
            [constraint uninstall];
        }
    }
    NSArray *constraints = self.constraints.copy;
    for (EaseConstraint *constraint in constraints) {
        constraint.updateExisting = self.updateExisting;
        [constraint install];
    }
    [self.constraints removeAllObjects];
    return constraints;
}

#pragma mark - EaseConstraintDelegate

- (void)constraint:(EaseConstraint *)constraint shouldBeReplacedWithConstraint:(EaseConstraint *)replacementConstraint {
    NSUInteger index = [self.constraints indexOfObject:constraint];
    NSAssert(index != NSNotFound, @"Could not find constraint %@", constraint);
    [self.constraints replaceObjectAtIndex:index withObject:replacementConstraint];
}

- (EaseConstraint *)constraint:(EaseConstraint *)constraint addConstraintWithLayoutAttribute:(NSLayoutAttribute)layoutAttribute {
    EaseViewAttribute *viewAttribute = [[EaseViewAttribute alloc] initWithView:self.view layoutAttribute:layoutAttribute];
    EaseViewConstraint *newConstraint = [[EaseViewConstraint alloc] initWithFirstViewAttribute:viewAttribute];
    if ([constraint isKindOfClass:EaseViewConstraint.class]) {
        //replace with composite constraint
        NSArray *children = @[constraint, newConstraint];
        EaseCompositeConstraint *compositeConstraint = [[EaseCompositeConstraint alloc] initWithChildren:children];
        compositeConstraint.delegate = self;
        [self constraint:constraint shouldBeReplacedWithConstraint:compositeConstraint];
        return compositeConstraint;
    }
    if (!constraint) {
        newConstraint.delegate = self;
        [self.constraints addObject:newConstraint];
    }
    return newConstraint;
}

- (EaseConstraint *)addConstraintWithAttributes:(EaseAttribute)attrs {
    __unused EaseAttribute anyAttribute = (EaseAttributeLeft | EaseAttributeRight | EaseAttributeTop | EaseAttributeBottom | EaseAttributeLeading
                                          | EaseAttributeTrailing | EaseAttributeWidth | EaseAttributeHeight | EaseAttributeCenterX
                                          | EaseAttributeCenterY | EaseAttributeBaseline
#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)
                                          | EaseAttributeFirstBaseline | EaseAttributeLastBaseline
#endif
#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)
                                          | EaseAttributeLeftMargin | EaseAttributeRightMargin | EaseAttributeTopMargin | EaseAttributeBottomMargin
                                          | EaseAttributeLeadingMargin | EaseAttributeTrailingMargin | EaseAttributeCenterXWithinMargins
                                          | EaseAttributeCenterYWithinMargins
#endif
                                          );
    
    NSAssert((attrs & anyAttribute) != 0, @"You didn't pass any attribute to make.attributes(...)");
    
    NSMutableArray *attributes = [NSMutableArray array];
    
    if (attrs & EaseAttributeLeft) [attributes addObject:self.view.ease_left];
    if (attrs & EaseAttributeRight) [attributes addObject:self.view.ease_right];
    if (attrs & EaseAttributeTop) [attributes addObject:self.view.ease_top];
    if (attrs & EaseAttributeBottom) [attributes addObject:self.view.ease_bottom];
    if (attrs & EaseAttributeLeading) [attributes addObject:self.view.ease_leading];
    if (attrs & EaseAttributeTrailing) [attributes addObject:self.view.ease_trailing];
    if (attrs & EaseAttributeWidth) [attributes addObject:self.view.ease_width];
    if (attrs & EaseAttributeHeight) [attributes addObject:self.view.ease_height];
    if (attrs & EaseAttributeCenterX) [attributes addObject:self.view.ease_centerX];
    if (attrs & EaseAttributeCenterY) [attributes addObject:self.view.ease_centerY];
    if (attrs & EaseAttributeBaseline) [attributes addObject:self.view.ease_baseline];
    
#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)
    
    if (attrs & EaseAttributeFirstBaseline) [attributes addObject:self.view.ease_firstBaseline];
    if (attrs & EaseAttributeLastBaseline) [attributes addObject:self.view.ease_lastBaseline];
    
#endif
    
#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)
    
    if (attrs & EaseAttributeLeftMargin) [attributes addObject:self.view.ease_leftMargin];
    if (attrs & EaseAttributeRightMargin) [attributes addObject:self.view.ease_rightMargin];
    if (attrs & EaseAttributeTopMargin) [attributes addObject:self.view.ease_topMargin];
    if (attrs & EaseAttributeBottomMargin) [attributes addObject:self.view.ease_bottomMargin];
    if (attrs & EaseAttributeLeadingMargin) [attributes addObject:self.view.ease_leadingMargin];
    if (attrs & EaseAttributeTrailingMargin) [attributes addObject:self.view.ease_trailingMargin];
    if (attrs & EaseAttributeCenterXWithinMargins) [attributes addObject:self.view.ease_centerXWithinMargins];
    if (attrs & EaseAttributeCenterYWithinMargins) [attributes addObject:self.view.ease_centerYWithinMargins];
    
#endif
    
    NSMutableArray *children = [NSMutableArray arrayWithCapacity:attributes.count];
    
    for (EaseViewAttribute *a in attributes) {
        [children addObject:[[EaseViewConstraint alloc] initWithFirstViewAttribute:a]];
    }
    
    EaseCompositeConstraint *constraint = [[EaseCompositeConstraint alloc] initWithChildren:children];
    constraint.delegate = self;
    [self.constraints addObject:constraint];
    return constraint;
}

#pragma mark - standard Attributes

- (EaseConstraint *)addConstraintWithLayoutAttribute:(NSLayoutAttribute)layoutAttribute {
    return [self constraint:nil addConstraintWithLayoutAttribute:layoutAttribute];
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

- (EaseConstraint *(^)(EaseAttribute))attributes {
    return ^(EaseAttribute attrs){
        return [self addConstraintWithAttributes:attrs];
    };
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


#pragma mark - composite Attributes

- (EaseConstraint *)edges {
    return [self addConstraintWithAttributes:EaseAttributeTop | EaseAttributeLeft | EaseAttributeRight | EaseAttributeBottom];
}

- (EaseConstraint *)size {
    return [self addConstraintWithAttributes:EaseAttributeWidth | EaseAttributeHeight];
}

- (EaseConstraint *)center {
    return [self addConstraintWithAttributes:EaseAttributeCenterX | EaseAttributeCenterY];
}

#pragma mark - grouping

- (EaseConstraint *(^)(dispatch_block_t group))group {
    return ^id(dispatch_block_t group) {
        NSInteger previousCount = self.constraints.count;
        group();

        NSArray *children = [self.constraints subarrayWithRange:NSMakeRange(previousCount, self.constraints.count - previousCount)];
        EaseCompositeConstraint *constraint = [[EaseCompositeConstraint alloc] initWithChildren:children];
        constraint.delegate = self;
        return constraint;
    };
}

@end
