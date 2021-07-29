//
//  EaseBadgeView.h
//  
//
//  Created by 杜洁鹏 on 2020/11/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EaseBadgeView : UIView
@property (nonatomic) int badge;
@property (nonatomic, strong) UIColor *badgeColor;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic) int maxNum;
@end

NS_ASSUME_NONNULL_END
