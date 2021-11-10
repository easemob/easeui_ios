//
//  NSArray+EaseAdditions.m
//  
//
//  Created by Daniel Hammond on 11/26/13.
//
//

#import "NSArray+EaseAdditions.h"
#import "View+EaseAdditions.h"

@implementation NSArray (EaseAdditions)

- (NSArray *)Ease_makeConstraints:(void(NS_NOESCAPE^)(EaseConstraintMaker *make))block {
    NSMutableArray *constraints = [NSMutableArray array];
    for (Ease_VIEW *view in self) {
        NSAssert([view isKindOfClass:[Ease_VIEW class]], @"All objects in the array must be views");
        [constraints addObjectsFromArray:[view Ease_makeConstraints:block]];
    }
    return constraints;
}

- (NSArray *)Ease_updateConstraints:(void(NS_NOESCAPE^)(EaseConstraintMaker *make))block {
    NSMutableArray *constraints = [NSMutableArray array];
    for (Ease_VIEW *view in self) {
        NSAssert([view isKindOfClass:[Ease_VIEW class]], @"All objects in the array must be views");
        [constraints addObjectsFromArray:[view Ease_updateConstraints:block]];
    }
    return constraints;
}

- (NSArray *)Ease_remakeConstraints:(void(NS_NOESCAPE^)(EaseConstraintMaker *make))block {
    NSMutableArray *constraints = [NSMutableArray array];
    for (Ease_VIEW *view in self) {
        NSAssert([view isKindOfClass:[Ease_VIEW class]], @"All objects in the array must be views");
        [constraints addObjectsFromArray:[view Ease_remakeConstraints:block]];
    }
    return constraints;
}

- (void)Ease_distributeViewsAlongAxis:(EaseAxisType)axisType withFixedSpacing:(CGFloat)fixedSpacing leadSpacing:(CGFloat)leadSpacing tailSpacing:(CGFloat)tailSpacing {
    if (self.count < 2) {
        NSAssert(self.count>1,@"views to distribute need to bigger than one");
        return;
    }
    
    Ease_VIEW *tempSuperView = [self Ease_commonSuperviewOfViews];
    if (axisType == EaseAxisTypeHorizontal) {
        Ease_VIEW *prev;
        for (int i = 0; i < self.count; i++) {
            Ease_VIEW *v = self[i];
            [v Ease_makeConstraints:^(EaseConstraintMaker *make) {
                if (prev) {
                    make.width.equalTo(prev);
                    make.left.equalTo(prev.ease_right).offset(fixedSpacing);
                    if (i == self.count - 1) {//last one
                        make.right.equalTo(tempSuperView).offset(-tailSpacing);
                    }
                }
                else {//first one
                    make.left.equalTo(tempSuperView).offset(leadSpacing);
                }
                
            }];
            prev = v;
        }
    }
    else {
        Ease_VIEW *prev;
        for (int i = 0; i < self.count; i++) {
            Ease_VIEW *v = self[i];
            [v Ease_makeConstraints:^(EaseConstraintMaker *make) {
                if (prev) {
                    make.height.equalTo(prev);
                    make.top.equalTo(prev.ease_bottom).offset(fixedSpacing);
                    if (i == self.count - 1) {//last one
                        make.bottom.equalTo(tempSuperView).offset(-tailSpacing);
                    }                    
                }
                else {//first one
                    make.top.equalTo(tempSuperView).offset(leadSpacing);
                }
                
            }];
            prev = v;
        }
    }
}

- (void)Ease_distributeViewsAlongAxis:(EaseAxisType)axisType withFixedItemLength:(CGFloat)fixedItemLength leadSpacing:(CGFloat)leadSpacing tailSpacing:(CGFloat)tailSpacing {
    if (self.count < 2) {
        NSAssert(self.count>1,@"views to distribute need to bigger than one");
        return;
    }
    
    Ease_VIEW *tempSuperView = [self Ease_commonSuperviewOfViews];
    if (axisType == EaseAxisTypeHorizontal) {
        Ease_VIEW *prev;
        for (int i = 0; i < self.count; i++) {
            Ease_VIEW *v = self[i];
            [v Ease_makeConstraints:^(EaseConstraintMaker *make) {
                make.width.equalTo(@(fixedItemLength));
                if (prev) {
                    if (i == self.count - 1) {//last one
                        make.right.equalTo(tempSuperView).offset(-tailSpacing);
                    }
                    else {
                        CGFloat offset = (1-(i/((CGFloat)self.count-1)))*(fixedItemLength+leadSpacing)-i*tailSpacing/(((CGFloat)self.count-1));
                        make.right.equalTo(tempSuperView).multipliedBy(i/((CGFloat)self.count-1)).with.offset(offset);
                    }
                }
                else {//first one
                    make.left.equalTo(tempSuperView).offset(leadSpacing);
                }
            }];
            prev = v;
        }
    }
    else {
        Ease_VIEW *prev;
        for (int i = 0; i < self.count; i++) {
            Ease_VIEW *v = self[i];
            [v Ease_makeConstraints:^(EaseConstraintMaker *make) {
                make.height.equalTo(@(fixedItemLength));
                if (prev) {
                    if (i == self.count - 1) {//last one
                        make.bottom.equalTo(tempSuperView).offset(-tailSpacing);
                    }
                    else {
                        CGFloat offset = (1-(i/((CGFloat)self.count-1)))*(fixedItemLength+leadSpacing)-i*tailSpacing/(((CGFloat)self.count-1));
                        make.bottom.equalTo(tempSuperView).multipliedBy(i/((CGFloat)self.count-1)).with.offset(offset);
                    }
                }
                else {//first one
                    make.top.equalTo(tempSuperView).offset(leadSpacing);
                }
            }];
            prev = v;
        }
    }
}

- (Ease_VIEW *)Ease_commonSuperviewOfViews
{
    Ease_VIEW *commonSuperview = nil;
    Ease_VIEW *previousView = nil;
    for (id object in self) {
        if ([object isKindOfClass:[Ease_VIEW class]]) {
            Ease_VIEW *view = (Ease_VIEW *)object;
            if (previousView) {
                commonSuperview = [view Ease_closestCommonSuperview:commonSuperview];
            } else {
                commonSuperview = view;
            }
            previousView = view;
        }
    }
    NSAssert(commonSuperview, @"Can't constrain views that do not share a common superview. Make sure that all the views in this array have been added into the same view hierarchy.");
    return commonSuperview;
}

@end
