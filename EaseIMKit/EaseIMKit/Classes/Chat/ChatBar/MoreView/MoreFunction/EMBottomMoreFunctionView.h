//
//  EMBottomMoreFunctionView.h
//  EaseIMKit
//
//  Created by 冯钊 on 2022/2/22.
//

#import <UIKit/UIKit.h>

@class EaseExtMenuModel;

NS_ASSUME_NONNULL_BEGIN

@interface EMBottomMoreFunctionView : UIView

+ (void)showMenuItems:(NSArray <EaseExtMenuModel *>*)menuItems
            animation:(BOOL)animation
  didSelectedMenuItem:(void(^)(EaseExtMenuModel *menuItem))didSelectedMenuItem
     didSelectedEmoji:(void(^)(NSString *emoji))didSelectedEmoji;

+ (void)hideWithAnimation:(BOOL)animation needClear:(BOOL)needClear;

@end

NS_ASSUME_NONNULL_END
