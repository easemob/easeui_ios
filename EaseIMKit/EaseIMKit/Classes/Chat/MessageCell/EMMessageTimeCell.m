//
//  EMMessageTimeCell.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/2/20.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMMessageTimeCell.h"
#import "Easeonry.h"
#import "UIColor+EaseUI.h"

@implementation EMMessageTimeCell

- (instancetype)initWithViewModel:(EaseChatViewModel *)viewModel remindType:(EaseWeakRemind)remidType
{
    NSString *identifier = (remidType == EaseWeakRemindMsgTime) ? @"EMMessageTimeCell" : @"EMMessageSystemHint";
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        _timeLabel = [[UILabel alloc] init];
        if (remidType == EaseWeakRemindMsgTime) {
            _timeLabel.textColor = viewModel.msgTimeItemFontColor;
            _timeLabel.backgroundColor = viewModel.msgTimeItemBgColor;
        } else {
            _timeLabel.textColor = [UIColor colorWithHexString:@"#ADADAD"];;
            _timeLabel.backgroundColor = [UIColor clearColor];
        }
        _timeLabel.font = [UIFont systemFontOfSize:14];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_timeLabel];
        [_timeLabel Ease_makeConstraints:^(EaseConstraintMaker *make) {
            make.center.equalTo(self.contentView);
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
