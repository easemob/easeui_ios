//
//  EaseContactCell.m
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/11/10.
//

#import "EaseContactCell.h"
#import "EaseContactsViewModel.h"
#import "Easeonry.h"
#import "UIImageView+EaseWebCache.h"


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
    
    [_avatarView Ease_remakeConstraints:^(EaseConstraintMaker *make) {
        make.top.equalTo(weakSelf.contentView.ease_top).offset(weakSelf.viewModel.avatarEdgeInsets.top + 8);
        make.bottom.equalTo(weakSelf.contentView.ease_bottom).offset(-weakSelf.viewModel.avatarEdgeInsets.bottom - 8);
        make.left.equalTo(weakSelf.contentView.ease_left).offset(weakSelf.viewModel.avatarEdgeInsets.left + 20);
        make.width.offset(weakSelf.viewModel.avatarSize.width);
        make.height.offset(weakSelf.viewModel.avatarSize.height).priority(750);
    }];
    
    [_nameLabel Ease_remakeConstraints:^(EaseConstraintMaker *make) {
        make.top.equalTo(weakSelf.contentView.ease_top).offset(weakSelf.viewModel.nameLabelEdgeInsets.top + 16);
        make.bottom.equalTo(weakSelf.contentView.ease_bottom).offset(-weakSelf.viewModel.nameLabelEdgeInsets.bottom - 16);
        make.left.equalTo(weakSelf.avatarView.ease_right).offset(weakSelf.viewModel.avatarEdgeInsets.right + weakSelf.viewModel.nameLabelEdgeInsets.left + 12);
        make.right.equalTo(weakSelf.contentView.ease_right).offset(-weakSelf.viewModel.nameLabelEdgeInsets.right - 10);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setModel:(EaseContactModel *)model {
    _model = model;
    
    if ([_model respondsToSelector:@selector(showName)]) {
        self.nameLabel.text = _model.showName;
    }
    
    UIImage *img = nil;
    if ([_model respondsToSelector:@selector(defaultAvatar)]) {
        img = _model.defaultAvatar;
    }
    
    if (_viewModel.defaultAvatarImage && !img) {
        img = _viewModel.defaultAvatarImage;
    }
    
    if ([_model respondsToSelector:@selector(avatarURL)]) {
        [self.avatarView Ease_setImageWithURL:[NSURL URLWithString:_model.avatarURL]
                           placeholderImage:img];
    }else {
        self.avatarView.image = img;
    }
}



@end
