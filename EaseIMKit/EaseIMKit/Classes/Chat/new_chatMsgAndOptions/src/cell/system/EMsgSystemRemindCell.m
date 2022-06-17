//
//  EMsgSystemRemindCell.m
//  EaseIMKit
//
//  Created by yangjian on 2022/5/19.
//

#import "EMsgSystemRemindCell.h"

@implementation EMsgSystemRemindCell

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
    label.textColor = UIColor.grayColor;
    [self.contentView addSubview:label];
    label.numberOfLines = 0;
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        //标记测试cell能力,完成后只保留最后一行,前三行约束要注释掉.
        make.top.mas_equalTo(EMsgCellOtherLayoutAdapterConfigs.shared.systemRemindTopAndBottomEdgeSpacing);
        make.centerX.mas_equalTo(0);
        make.width.mas_lessThanOrEqualTo
        (
         ESCREEN_W
         - EMsgCellOtherLayoutAdapterConfigs.shared.systemRemindLeftAndRightMiniEdgeSpacing
         - EMsgCellOtherLayoutAdapterConfigs.shared.systemRemindLeftAndRightMiniEdgeSpacing
         );
        make.bottom.mas_equalTo
        (- EMsgCellOtherLayoutAdapterConfigs.shared.systemRemindTopAndBottomEdgeSpacing);
    }];
    label.textColor = UIColor.grayColor;
    label.font = EMsgTableViewConfig.shared.timeFont;
    self.label = label;
}

- (void)bindViewModel:(EMsgBaseCellModel *)model{

    [super bindViewModel:model];
    if (model.cellType == EMsgCellType_system) {
        self.label.attributedText = model.show_content;
    }
}

@end
