//
//  EMsgBaseCell.h
//  EaseIMKit
//
//  Created by yangjian on 2022/5/18.
//

#import <UIKit/UIKit.h>
#import "EMsgBaseCellModel.h"
#import "EMsgCellLayoutAdapterConfigs.h"
#import "EMsgTableViewFunctions.h"
#import "Masonry.h"

#import "UIImageView+EaseWebCache.h"
#import "UIImage+EaseUI.h"

NS_ASSUME_NONNULL_BEGIN

@protocol EMsgUserBaseCellDelegate;

@interface EMsgBaseCell : UITableViewCell

@property (nonatomic,weak)__weak EMsgBaseCellModel *weakModel;
@property (nonatomic,weak)__weak id userMessageDelegate;



- (void)bindViewModel:(EMsgBaseCellModel *)model;



@end


NS_ASSUME_NONNULL_END
