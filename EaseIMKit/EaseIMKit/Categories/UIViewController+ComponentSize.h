//
//  UIViewController+ComponentSize.h
//  EaseIMKit
//
//  Created by 娜塔莎 on 2020/11/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (ComponentSize)

- (void)keyBoardWillShow:(NSNotification *)note animations:(void (^)(void))animations completion:(void (^ __nullable)(BOOL finished, CGRect keyBoardBounds))completion;

- (void)keyBoardWillHide:(NSNotification *)note animations:(void (^)(void))animations completion:(void (^ __nullable)(BOOL finished))completion;

//刘海高度
- (CGFloat)bangScreenSize;

@end

NS_ASSUME_NONNULL_END
