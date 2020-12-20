//
//  UIViewController+EaseAdditions.h
//  Easeonry
//
//  Created by Craig Siemens on 2015-06-23.
//
//

#import "EaseUtilities.h"
#import "EaseConstraintMaker.h"
#import "EaseViewAttribute.h"

#ifdef Ease_VIEW_CONTROLLER

@interface Ease_VIEW_CONTROLLER (EaseAdditions)

/**
 *	following properties return a new EaseViewAttribute with appropriate UILayoutGuide and NSLayoutAttribute
 */
@property (nonatomic, strong, readonly) EaseViewAttribute *ease_topLayoutGuide;
@property (nonatomic, strong, readonly) EaseViewAttribute *ease_bottomLayoutGuide;
@property (nonatomic, strong, readonly) EaseViewAttribute *ease_topLayoutGuideTop;
@property (nonatomic, strong, readonly) EaseViewAttribute *ease_topLayoutGuideBottom;
@property (nonatomic, strong, readonly) EaseViewAttribute *ease_bottomLayoutGuideTop;
@property (nonatomic, strong, readonly) EaseViewAttribute *ease_bottomLayoutGuideBottom;


@end

#endif
