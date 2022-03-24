//
//  EMBottomMoreFunctionViewEmojiCell.h
//  EaseIMKit
//
//  Created by 冯钊 on 2022/2/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMBottomMoreFunctionViewEmojiCell : UICollectionViewCell

@property (nonatomic, strong) NSString *imageName;
@property (nonatomic, assign, getter=isAdded) BOOL added;

@end

NS_ASSUME_NONNULL_END
