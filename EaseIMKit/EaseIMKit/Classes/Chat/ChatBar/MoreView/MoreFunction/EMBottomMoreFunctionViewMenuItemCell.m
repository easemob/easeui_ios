//
//  EMBottomMoreFunctionViewMenuItemCell.m
//  EaseIMKit
//
//  Created by 冯钊 on 2022/2/22.
//

#import "EMBottomMoreFunctionViewMenuItemCell.h"

#import "EaseExtMenuModel.h"
#import "UIImage+EaseUI.h"

@interface EMBottomMoreFunctionViewMenuItemCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;

@end

@implementation EMBottomMoreFunctionViewMenuItemCell

- (void)setMenuItem:(EaseExtMenuModel *)menuItem {
    _menuItem = menuItem;
    
    _iconImageView.image = menuItem.icon;
    _descLabel.text = menuItem.funcDesc;
}

@end
