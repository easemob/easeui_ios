//
//  EMUserCell.h
//  ChatDemo-UI3.0
//
//  Created by dhc on 15/6/24.
//  Copyright (c) 2015年 easemob.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "IUserModel.h"
#import "IModelCell.h"
#import "EMImageView.h"

static CGFloat EMUserCellMinHeight = 50;

@interface EMUserCell : UITableViewCell<IModelCell>

@property (strong, nonatomic) EMImageView *avatarView;

@property (strong, nonatomic) UILabel *titleLabel;

@property (strong, nonatomic) id<IUserModel> model;

@property (nonatomic) BOOL showAvatar; //default is "YES"

@property (nonatomic) UIFont *titleLabelFont UI_APPEARANCE_SELECTOR;

@property (nonatomic) UIColor *titleLabelColor UI_APPEARANCE_SELECTOR;

@end
