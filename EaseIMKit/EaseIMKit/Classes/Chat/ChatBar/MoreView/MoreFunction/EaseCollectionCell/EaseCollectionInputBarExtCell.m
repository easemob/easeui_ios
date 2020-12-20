//
//  EaseCollectionInputBarExtCell.m
//  EaseIMKit
//
//  Created by 娜塔莎 on 2020/12/11.
//  Copyright © 2020 djp. All rights reserved.
//

#import "EaseCollectionInputBarExtCell.h"

@implementation EaseCollectionInputBarExtCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.cellLonger = frame.size.width;
        [self setupToolbar];
    }
    return self;
}

- (void)setupToolbar {
    [super setupToolbar];
    self.toolBtn = [[UIButton alloc]init];
    self.toolBtn.layer.masksToBounds = YES;
    self.toolBtn.layer.cornerRadius = 8;
    self.toolBtn.userInteractionEnabled = NO;
    [self.contentView addSubview:self.toolBtn];
    [self.toolBtn Ease_makeConstraints:^(EaseConstraintMaker *make) {
        make.top.equalTo(self.contentView.ease_top);
        make.width.Ease_equalTo(@(self.cellLonger));
        make.height.Ease_equalTo(@(self.cellLonger));
        make.left.equalTo(self.contentView);
    }];
    
    self.toolLabel = [[UILabel alloc]init];
    self.toolLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.toolLabel];
    [self.toolLabel Ease_makeConstraints:^(EaseConstraintMaker *make) {
        make.top.equalTo(self.toolBtn.ease_bottom).offset(3);
        make.width.Ease_equalTo(@(self.cellLonger));
        make.left.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView).offset(-10);
    }];
}

- (void)personalizeToolbar:(EaseExtMenuModel*)menuItemModel menuViewMode:(EaseExtMenuViewModel*)menuViewModel
{
    [super personalizeToolbar:menuItemModel menuViewMode:menuViewModel];
}

@end
