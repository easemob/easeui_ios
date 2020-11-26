//
//  UIViewController+KeyBoardChangedStatus.h
//  EaseIMKit
//
//  Created by 娜塔莎 on 2020/11/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (KeyBoardChangedStatus)

- (void)keyBoardWillShow:(NSNotification *)note animations:(void (^)(void))animations completion:(void (^ __nullable)(BOOL finished, CGRect keyBoardBounds))completion;

- (void)keyBoardWillHide:(NSNotification *)note animations:(void (^)(void))animations completion:(void (^ __nullable)(BOOL finished))completion;

@end

NS_ASSUME_NONNULL_END
