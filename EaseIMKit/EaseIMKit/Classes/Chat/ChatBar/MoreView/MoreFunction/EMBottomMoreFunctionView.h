//
//  EMBottomMoreFunctionView.h
//  EaseIMKit
//
//  Created by 冯钊 on 2022/2/22.
//

#import <UIKit/UIKit.h>

@class EaseExtMenuModel;
@class EMBottomMoreFunctionView;

NS_ASSUME_NONNULL_BEGIN

@protocol EMBottomMoreFunctionViewDelegate <NSObject>

@optional
- (void)bottomMoreFunctionView:(EMBottomMoreFunctionView *)view didSelectedMenuItem:(EaseExtMenuModel *)model;
- (void)bottomMoreFunctionView:(EMBottomMoreFunctionView *)view didSelectedEmoji:(NSString *)emoji changeSelectedStateHandle:(void(^)(void))changeSelectedStateHandle;
- (BOOL)bottomMoreFunctionView:(EMBottomMoreFunctionView *)view getEmojiIsSelected:(NSString *)emoji userInfo:(NSDictionary *)userInfo;

@end

@interface EMBottomMoreFunctionView : UIView

+ (void)showMenuItems:(NSArray <EaseExtMenuModel *>*)menuItems
             delegate:(id<EMBottomMoreFunctionViewDelegate>)delegate
            animation:(BOOL)animation;

+ (void)showMenuItems:(NSArray <EaseExtMenuModel *>*)menuItems
             delegate:(id<EMBottomMoreFunctionViewDelegate>)delegate
            animation:(BOOL)animation
             userInfo:(NSDictionary *)userInfo;

+ (void)showMenuItems:(NSArray <EaseExtMenuModel *>*)menuItems
             delegate:(id<EMBottomMoreFunctionViewDelegate>)delegate
           ligheViews:(nullable NSArray <UIView *>*)views
            animation:(BOOL)animation
             userInfo:(nullable NSDictionary *)userInfo;

+ (void)showMenuItems:(NSArray <EaseExtMenuModel *>*)menuItems
         showReaction:(BOOL)showReaction
             delegate:(id<EMBottomMoreFunctionViewDelegate>)delegate
           ligheViews:(nullable NSArray <UIView *>*)views
            animation:(BOOL)animation
             userInfo:(nullable NSDictionary *)userInfo;

+ (void)updateHighlightViews:(nullable NSArray <UIView *>*)views;

+ (void)hideWithAnimation:(BOOL)animation needClear:(BOOL)needClear;

@end

NS_ASSUME_NONNULL_END
