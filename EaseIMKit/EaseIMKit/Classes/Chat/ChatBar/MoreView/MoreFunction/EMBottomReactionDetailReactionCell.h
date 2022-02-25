//
//  EMBottomReactionDetailReactionCell.h
//  EaseIMKit
//
//  Created by 冯钊 on 2022/2/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMBottomReactionDetailReactionCell : UICollectionViewCell

@property (nonatomic, strong) NSString *reaction;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, assign) BOOL reactionSelected;

@end

NS_ASSUME_NONNULL_END
