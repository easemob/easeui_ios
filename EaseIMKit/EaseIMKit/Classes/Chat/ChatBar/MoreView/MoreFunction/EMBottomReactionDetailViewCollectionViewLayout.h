//
//  EMBottomReactionDetailViewCollectionViewLayout.h
//  EaseIMKit
//
//  Created by 冯钊 on 2022/2/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMBottomReactionDetailViewCollectionViewLayout : UICollectionViewLayout

@property (nonatomic, strong) CGFloat(^getCellItemWidth)(NSIndexPath *indexPath);
@property (nonatomic, assign) CGFloat spacing;
@property (nonatomic, assign) UIEdgeInsets contentInsets;

@end

NS_ASSUME_NONNULL_END
