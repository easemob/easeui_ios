//
//  UIViewController+EaseAdditions.m
//  Easeonry
//
//  Created by Craig Siemens on 2015-06-23.
//
//

#import "ViewController+EaseAdditions.h"

#ifdef Ease_VIEW_CONTROLLER

@implementation Ease_VIEW_CONTROLLER (EaseAdditions)

- (EaseViewAttribute *)ease_topLayoutGuide {
    return [[EaseViewAttribute alloc] initWithView:self.view item:self.view.safeAreaLayoutGuide.topAnchor layoutAttribute:NSLayoutAttributeBottom];
}
- (EaseViewAttribute *)ease_topLayoutGuideTop {
    return [[EaseViewAttribute alloc] initWithView:self.view item:self.view.safeAreaLayoutGuide.topAnchor layoutAttribute:NSLayoutAttributeTop];
}
- (EaseViewAttribute *)ease_topLayoutGuideBottom {
    return [[EaseViewAttribute alloc] initWithView:self.view item:self.view.safeAreaLayoutGuide.topAnchor layoutAttribute:NSLayoutAttributeBottom];
}

- (EaseViewAttribute *)ease_bottomLayoutGuide {
    return [[EaseViewAttribute alloc] initWithView:self.view item:self.view.safeAreaLayoutGuide.bottomAnchor layoutAttribute:NSLayoutAttributeTop];
}
- (EaseViewAttribute *)ease_bottomLayoutGuideTop {
    return [[EaseViewAttribute alloc] initWithView:self.view item:self.view.safeAreaLayoutGuide.bottomAnchor layoutAttribute:NSLayoutAttributeTop];
}
- (EaseViewAttribute *)ease_bottomLayoutGuideBottom {
    return [[EaseViewAttribute alloc] initWithView:self.view item:self.view.safeAreaLayoutGuide.bottomAnchor layoutAttribute:NSLayoutAttributeBottom];
}



@end

#endif
