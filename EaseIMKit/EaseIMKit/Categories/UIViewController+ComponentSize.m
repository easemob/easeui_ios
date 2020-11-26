//
//  UIViewController+ComponentSize.m
//  EaseIMKit
//
//  Created by 娜塔莎 on 2020/11/25.
//

#import "UIViewController+ComponentSize.h"

@implementation UIViewController (ComponentSize)

- (void)keyBoardWillShow:(NSNotification *)note animations:(void (^)(void))animations completion:(void (^ __nullable)(BOOL finished, CGRect keyBoardBounds))completion
{
    // 获取用户信息
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:note.userInfo];
    // 获取键盘高度
    CGRect keyBoardBounds  = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //CGFloat keyBoardHeight = keyBoardBounds.size.height;
    // 获取键盘动画时间
    CGFloat animationTime  = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    if (animationTime > 0) {
        [UIView animateWithDuration:animationTime animations:animations completion:^(BOOL finished) {
            if (completion) {
                completion(finished, keyBoardBounds);
            }
        }];
    } else {
        animations();
    }
}

- (void)keyBoardWillHide:(NSNotification *)note animations:(void (^)(void))animations completion:(void (^ __nullable)(BOOL finished))completion
{
    // 获取用户信息
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:note.userInfo];
    // 获取键盘动画时间
    CGFloat animationTime  = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    if (animationTime > 0) {
        [UIView animateWithDuration:animationTime animations:animations completion:^(BOOL finished) {
            if (completion) {
                completion(finished);
            }
        }];
    } else {
        animations();
    }
}

//刘海高度
- (CGFloat)bangScreenSize {
     if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
         return 0;
     }
     CGSize size = [UIScreen mainScreen].bounds.size;
     NSInteger notchValue = size.width / size.height * 100;
     if (216 == notchValue || 46 == notchValue) {
         return 34;
     }
     return 0;
}

@end
