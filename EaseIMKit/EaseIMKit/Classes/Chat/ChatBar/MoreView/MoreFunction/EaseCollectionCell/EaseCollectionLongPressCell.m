//
//  EaseCollectionLongPressCell.m
//  EaseIMKit
//
//  Created by 娜塔莎 on 2020/12/11.
//  Copyright © 2020 djp. All rights reserved.
//

#import "EaseCollectionLongPressCell.h"

@implementation EaseCollectionLongPressCell

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
    self.toolBtn.imageEdgeInsets = UIEdgeInsetsMake(10, 0, 0, 0);
    [self.contentView addSubview:self.toolBtn];
    [self.toolBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(5);
        make.width.mas_equalTo(@(self.cellLonger));
        make.height.mas_equalTo(@(self.cellLonger - 20));
        make.left.equalTo(self.contentView);
    }];
    
    self.toolLabel = [[UILabel alloc]init];
    self.toolLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.toolLabel];
    [self.toolLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.toolBtn.mas_bottom);
        make.width.mas_equalTo(@(self.cellLonger));
        make.left.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView).offset(-10);
    }];
}

- (void)personalizeToolbar:(EaseExtMenuModel*)menuItemModel menuViewMode:(EaseExtMenuViewModel*)menuViewModel
{
    [super personalizeToolbar:menuItemModel menuViewMode:menuViewModel];
}

@end
