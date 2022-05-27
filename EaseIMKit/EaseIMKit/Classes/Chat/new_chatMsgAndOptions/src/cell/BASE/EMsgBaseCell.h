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

@interface EMsgBaseCell : UITableViewCell

- (void)bindViewModel:(EMsgBaseCellModel *)model;

@end

NS_ASSUME_NONNULL_END
