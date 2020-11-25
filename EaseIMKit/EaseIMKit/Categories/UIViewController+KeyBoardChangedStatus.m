//
//  UIViewController+KeyBoardChangedStatus.m
//  EaseIMKit
//
//  Created by 娜塔莎 on 2020/11/25.
//

#import "UIViewController+KeyBoardChangedStatus.h"

@implementation UIViewController (KeyBoardChangedStatus)

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

@end
