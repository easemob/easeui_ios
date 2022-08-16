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
    [label Ease_makeConstraints:^(EaseConstraintMaker *make) {
        //标记测试cell能力,完成后只保留最后一行,前三行约束要注释掉.
        make.top.Ease_equalTo(EMsgCellOtherLayoutAdapterConfigs.shared.systemRemindTopAndBottomEdgeSpacing);
        make.centerX.Ease_equalTo(0);
        make.width.Ease_lessThanOrEqualTo
        (
         ESCREEN_W
         - EMsgCellOtherLayoutAdapterConfigs.shared.systemRemindLeftAndRightMiniEdgeSpacing
         - EMsgCellOtherLayoutAdapterConfigs.shared.systemRemindLeftAndRightMiniEdgeSpacing
         );
        make.bottom.Ease_equalTo
        (- EMsgCellOtherLayoutAdapterConfigs.shared.systemRemindTopAndBottomEdgeSpacing);
    }];
    label.textColor = UIColor.grayColor;
    label.font = EMsgTableViewConfig.shared.timeFont;
    self.label = label;
}

- (void)bindDataFromViewModel:(EMsgBaseCellModel *)model{

    [super bindDataFromViewModel:model];
    if (model.cellType == EMsgCellType_system) {
        self.label.attributedText = model.show_content;
    }
}

@end
