//
//  EMBottomReactionDetailUserCell.h
//  EaseIMKit
//
//  Created by 冯钊 on 2022/2/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMBottomReactionDetailUserCell : UITableViewCell

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *username;

@property (nonatomic, copy) void(^didClickRemove)(void);

@end

NS_ASSUME_NONNULL_END
