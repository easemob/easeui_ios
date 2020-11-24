//
//  EaseContactCell.m
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/11/10.
//

#import "EaseContactCell.h"
#import "EaseContactsViewModel.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>


@interface EaseContactCell ()
@property (nonatomic, strong) EaseContactsViewModel *viewModel;
@end

@implementation EaseContactCell

+ (EaseContactCell *)tableView:(UITableView *)tableView cellViewModel:(EaseContactsViewModel *)viewModel {
    static NSString *cellId = @"EMContactCell";
    EaseContactCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[EaseContactCell alloc] initWithContactsViewModel:viewModel identifier: cellId];
    }
    
    return cell;
}

- (instancetype)initWithContactsViewModel:(EaseContactsViewModel*)viewModel
                                   identifier:(NSString *)identifier
{
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier]){
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _viewModel = viewModel;
        [self _addSubViews];
        [self _setupSubViewsConstraints];
        [self _setupViewsProperty];
    }
    
    return self;
}

- (void)_addSubViews {
    _avatarView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    
    [self.contentView addSubview:_avatarView];
    [self.contentView addSubview:_nameLabel];
}

- (void)_setupViewsProperty {
    
    self.contentView.backgroundColor = _viewModel.cellBgColor;
    
    if (_viewModel.avatarType != Rectangular) {
        _avatarView.clipsToBounds = YES;
        if (_viewModel.avatarType == RoundedCorner) {
            _avatarView.layer.cornerRadius = 5;
        }
        else if(Circular) {
            _avatarView.layer.cornerRadius = _viewModel.avatarSize.width / 2;
        }
        
    }else {
        _avatarView.clipsToBounds = NO;
    }

    _avatarView.backgroundColor = [UIColor clearColor];
    
    _nameLabel.font = _viewModel.nameLabelFont;
    _nameLabel.textColor = _viewModel.nameLabelColor;
    _nameLabel.lineBreakMode = NSLineBreakByCharWrapping;
    _nameLabel.backgroundColor = [UIColor clearColor];
    
}

- (void)_setupSubViewsConstraints {
    __weak typeof(self) weakSelf = self;
    
    [_avatarView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.contentView.mas_top).offset(weakSelf.viewModel.avatarEdgeInsets.top);
        make.bottom.equalTo(weakSelf.contentView.mas_bottom).offset(-weakSelf.viewModel.avatarEdgeInsets.bottom);
        make.left.equalTo(weakSelf.contentView.mas_left).offset(weakSelf.viewModel.avatarEdgeInsets.left);
        make.width.offset(weakSelf.viewModel.avatarSize.width);
        make.height.offset(weakSelf.viewModel.avatarSize.height).priority(750);
    }];
    
    [_nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.contentView.mas_top).offset(weakSelf.viewModel.nameLabelEdgeInsets.top);
        make.bottom.equalTo(weakSelf.contentView.mas_bottom).offset(-weakSelf.viewModel.nameLabelEdgeInsets.bottom);
        make.left.equalTo(weakSelf.avatarView.mas_right).offset(weakSelf.viewModel.avatarEdgeInsets.right + weakSelf.viewModel.nameLabelEdgeInsets.left);
        make.right.equalTo(weakSelf.contentView.mas_right).offset(-weakSelf.viewModel.nameLabelEdgeInsets.right);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setModel:(id<EaseContactDelegate>)model {
    _model = model;
    
    if ([_model respondsToSelector:@selector(showName)]) {
        self.nameLabel.text = _model.showName;
    }
    
    UIImage *img = nil;
    if ([_model respondsToSelector:@selector(defaultAvatar)]) {
        img = _model.defaultAvatar;
    }
    if ([_model respondsToSelector:@selector(avatarURL)]) {
        [self.avatarView sd_setImageWithURL:[NSURL URLWithString:_model.avatarURL]
                           placeholderImage:img];
    }else {
        self.avatarView.image = img;
    }
}



@end
