//
//  EaseContactCell.m
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/11/10.
//

#import "EaseContactCell.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>


@interface EaseContactCell ()
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *showNameLabel;
@end

@implementation EaseContactCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.avatarImageView];
        [self.contentView addSubview:self.showNameLabel];
        [self _setupSubViews];
    }
    
    return self;
}


- (void)_setupSubViews {
    [self.avatarImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(5);
        make.top.equalTo(self.contentView.mas_top).offset(5);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.width.equalTo(self.avatarImageView.mas_height);
    }];
    
    [self.showNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.avatarImageView.mas_right).offset(5);
        make.top.equalTo(self.avatarImageView.mas_top);
        make.bottom.equalTo(self.avatarImageView.mas_bottom);
        make.right.equalTo(self.contentView.mas_right).offset(-5);
    }];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setModel:(id<EaseContactDelegate>)model {
    _model = model;
    self.showNameLabel.text = _model.showName;
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:_model.avatarURL] placeholderImage:_model.defaultAvatar];
}


#pragma mark - getter
- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _avatarImageView;
}

- (UILabel *)showNameLabel {
    if (!_showNameLabel) {
        _showNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _showNameLabel.textAlignment = MASAttributeRight;
    }
    
    return _showNameLabel;;
}

@end
