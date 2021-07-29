//
//  EMMessageTimeCell.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/2/20.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EaseChatViewModel.h"
#import "EaseEnums.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMMessageTimeCell : UITableViewCell

@property (nonatomic, strong) UILabel *timeLabel;

- (instancetype)initWithViewModel:(EaseChatViewModel *)viewModel remindType:(EaseWeakRemind)remidType;

@end

NS_ASSUME_NONNULL_END
