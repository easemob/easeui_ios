//
//  EMsgTimeMarkerCell.m
//  EaseIMKit
//
//  Created by yangjian on 2022/5/19.
//

#import "EMsgTimeMarkerCell.h"

@implementation EMsgTimeMarkerCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self config];
    }
    return self;
}

- (void)config{
    UILabel *label = UILabel.new;
    [self.contentView addSubview:label];
    [label Ease_makeConstraints:^(EaseConstraintMaker *make) {
        //标记测试cell能力,完成后只保留最后一行,前三行约束要注释掉.
        make.center.Ease_equalTo(0);
    }];
    label.textColor = UIColor.grayColor;
    label.font = EMsgTableViewConfig.shared.timeFont;
    self.label = label;
}

- (void)bindDataFromViewModel:(EMsgBaseCellModel *)model{
    [super bindDataFromViewModel:model];
    if (model.cellType == EMsgCellType_time) {
        self.label.attributedText = model.show_content;
    }
}

@end


