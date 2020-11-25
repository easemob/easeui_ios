//
//  EMMessageTimeCell.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/2/20.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMMessageTimeCell.h"
#import "EMColorDefine.h"
#import "Masonry.h"

@implementation EMMessageTimeCell

- (instancetype)initWithViewModel:(EaseViewModel *)viewModel
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EMMessageTimeCell"];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = viewModel.msgTimeItemBgColor;
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont systemFontOfSize:14];
        _timeLabel.textColor = viewModel.msgTimeItemFontColor;
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_timeLabel];
        [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
            make.height.equalTo(@30);
        }];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
