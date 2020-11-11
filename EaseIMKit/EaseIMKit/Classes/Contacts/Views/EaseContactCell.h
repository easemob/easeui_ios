//
//  EaseContactCell.h
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/11/10.
//

#import <UIKit/UIKit.h>
#import "EaseContactModelDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface EaseContactCell : UITableViewCell
@property (nonatomic) id<EaseContactModelDelegate> model;
@end

NS_ASSUME_NONNULL_END
