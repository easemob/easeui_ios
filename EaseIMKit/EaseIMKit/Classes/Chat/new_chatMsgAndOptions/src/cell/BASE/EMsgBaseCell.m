//
//  EMsgBaseCell.m
//  EaseIMKit
//
//  Created by yangjian on 2022/5/18.
//

#import "EMsgBaseCell.h"

@implementation EMsgBaseCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}


- (void)bindViewModel:(EMsgBaseCellModel *)model{
}





@end
