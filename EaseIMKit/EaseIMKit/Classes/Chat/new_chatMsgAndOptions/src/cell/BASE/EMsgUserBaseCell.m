//
//  EMsgUserBaseCell.m
//  EaseIMKit
//
//  Created by yangjian on 2022/5/18.
//

#import "EMsgUserBaseCell.h"

@implementation EMsgUserBaseCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self configUserInfoViews];
    }
    return self;
}

- (void)configUserInfoViews{
    self.customBackgroundView = UIView.new;
    self.headImageView = UIImageView.new;
    self.nameLabel = UILabel.new;
    self.nameLabel.font = EMsgTableViewConfig.shared.nameFont;
    self.msgBackgroundView = UIView.new;

    self.stateLabel = UILabel.new;
    self.stateLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    self.stateLabel.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1];
    
    
    [self.contentView addSubview:self.customBackgroundView];
    [self.customBackgroundView addSubview:self.headImageView];
    [self.customBackgroundView addSubview:self.nameLabel];
    [self.customBackgroundView addSubview:self.msgBackgroundView];
    
    [self.customBackgroundView addSubview:self.stateLabel];
    
    [self.customBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    {
        self.headImageView.userInteractionEnabled = true;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headImageViewTapGestureClick:)];
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(headImageViewLongPressGestureClick:)];
        [self.headImageView addGestureRecognizer:tapGesture];
        [self.headImageView addGestureRecognizer:longPressGesture];
    }
    
//    self.headImageView.image = [UIImage imageNamed:@"alert_error"];

}

- (UIView *)longPressView{
    return self.msgBackgroundView;
}

- (void)headImageViewTapGestureClick:(UITapGestureRecognizer *)tapGesture{
    if (self.userMessageDelegate
        && [self.userMessageDelegate respondsToSelector:@selector(userMessageHeadDidSelected:model:)]) {
        [self.userMessageDelegate userMessageHeadDidSelected:self model:self.weakModel];
    }
}

- (void)headImageViewLongPressGestureClick:(UILongPressGestureRecognizer *)longPressGesture{
    if (longPressGesture.state == UIGestureRecognizerStateBegan) {
        if (self.userMessageDelegate
            && [self.userMessageDelegate respondsToSelector:@selector(userMessageHeadDidLongPress:model:)]) {
            [self.userMessageDelegate userMessageHeadDidLongPress:self model:self.weakModel];
        }
    }
}


- (void)messageTapGestureClick:(UITapGestureRecognizer *)tapGesture{
    if (self.userMessageDelegate
        && [self.userMessageDelegate respondsToSelector:@selector(userMessageDidSelected:model:)]) {
        [self.userMessageDelegate userMessageDidSelected:self model:self.weakModel];
    }
}

- (void)messagePressGestureClick:(UILongPressGestureRecognizer *)longPressGesture{
    if (longPressGesture.state == UIGestureRecognizerStateBegan) {
        if (self.userMessageDelegate
            && [self.userMessageDelegate respondsToSelector:@selector(userMessageDidLongPress:model:cgPoint:)]) {
            [self.userMessageDelegate userMessageDidLongPress:self model:self.weakModel cgPoint:CGPointZero];
        }
    }
}

- (void)resetSubViewsLayout:(EMMessageDirection)direction
                   showHead:(BOOL)showHead
                   showName:(BOOL)showName {
    self.headImageView.hidden = !showHead;
    self.nameLabel.hidden = !showName;
    if (showHead) {
        [self.headImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(EMsgCellLayoutAdapterConfigs.shared.userInfoLayoutAdapter.headTop);
            make.width.mas_equalTo(EMsgCellLayoutAdapterConfigs.shared.userInfoLayoutAdapter.headWidth);
            make.height.mas_equalTo(EMsgCellLayoutAdapterConfigs.shared.userInfoLayoutAdapter.headHeight);
            switch (direction) {
                case EMMessageDirectionSend:
                    make.right.mas_equalTo(- EMsgCellLayoutAdapterConfigs.shared
                                           .userInfoLayoutAdapter.headFromSide);
                    break;
                case EMMessageDirectionReceive:
                    make.left.mas_equalTo(EMsgCellLayoutAdapterConfigs.shared
                                          .userInfoLayoutAdapter.headFromSide);
                    break;
                default:
                    break;
            }
        }];
    }
    if (showName) {
        [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(EMsgCellLayoutAdapterConfigs.shared.userInfoLayoutAdapter.nameTop);
            make.height.mas_equalTo(EMsgCellLayoutAdapterConfigs.shared.userInfoLayoutAdapter.nameHeight);
            switch (direction) {
                case EMMessageDirectionSend:
                    make.right.mas_equalTo(- (EMsgCellLayoutAdapterConfigs.shared
                                              .userInfoLayoutAdapter.nameFromSide
                                              + (showHead?EMsgCellLayoutAdapterConfigs.shared
                                                 .userInfoLayoutAdapter.headTakeWidth : 0)));
                    break;
                case EMMessageDirectionReceive:
                    make.left.mas_equalTo(EMsgCellLayoutAdapterConfigs.shared
                                          .userInfoLayoutAdapter.nameFromSide
                                          + (showHead?EMsgCellLayoutAdapterConfigs.shared
                                             .userInfoLayoutAdapter.headTakeWidth : 0));
                    break;
                default:
                    break;
            }
        }];
    }
    //这里说明下:如果不展示头像,聊天内容会偏移,而不是拉宽消息显示控件的宽度.偏移的距离和头像展示时占用的宽度相同(区别于头像本身,头像展示时宽度为 : 头像本身宽度和头像距离边缘的宽度相加)
    UIEdgeInsets msgBackgroundEdgeInsets
    = [EMsgTableViewFunctions
       convertToEdgeInsets_direction:direction
       top:EMsgCellLayoutAdapterConfigs.shared.backgroundLayoutAdapter.top
       + (showName ? EMsgCellLayoutAdapterConfigs.shared.userInfoLayoutAdapter.nameTakeHeight : 0)
       fromSide:EMsgCellLayoutAdapterConfigs.shared.backgroundLayoutAdapter.fromSide
       + (showHead ? EMsgCellLayoutAdapterConfigs.shared.userInfoLayoutAdapter.headTakeWidth : 0)
       toSide:EMsgCellLayoutAdapterConfigs.shared.backgroundLayoutAdapter.toSide
       + (showHead ? 0 : EMsgCellLayoutAdapterConfigs.shared.userInfoLayoutAdapter.headTakeWidth)
       bottom:EMsgCellLayoutAdapterConfigs.shared.backgroundLayoutAdapter.bottom];
    
    [self.msgBackgroundView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(msgBackgroundEdgeInsets.top);
        make.left.mas_equalTo(msgBackgroundEdgeInsets.left);
#if YANGJIANXIUGAI
        //手动算高度
#else
        //自动算高度
        make.bottom.mas_equalTo(-msgBackgroundEdgeInsets.bottom);
#endif
        make.right.mas_equalTo(-msgBackgroundEdgeInsets.right);

    }];
}

- (void)bindViewModel:(EMsgBaseCellModel *)model{
    [super bindViewModel:model];
    
    if (!self.nameLabel.hidden) {
        if (model.userDataDelegate && [model.userDataDelegate respondsToSelector:@selector(showName)]) {
            NSLog(@"===========%@",model.userDataDelegate.showName);
            self.nameLabel.text = model.userDataDelegate.showName;
        } else {
            self.nameLabel.text = model.message.from;
        }
    }
    if (!self.headImageView.hidden) {
        BOOL isCustomAvatar = NO;
        if (model.userDataDelegate && [model.userDataDelegate respondsToSelector:@selector(defaultAvatar)]) {
            if (model.userDataDelegate.defaultAvatar) {
                self.headImageView.image = model.userDataDelegate.defaultAvatar;
                isCustomAvatar = YES;
            }
        }
        if (model.userDataDelegate && [model.userDataDelegate respondsToSelector:@selector(avatarURL)]) {
            if ([model.userDataDelegate.avatarURL length] > 0) {
                [self.headImageView Ease_setImageWithURL:[NSURL URLWithString:model.userDataDelegate.avatarURL]
                                        placeholderImage:[UIImage imageNamed:@"defaultHead"]];
                isCustomAvatar = YES;
            }
        }
        if (!isCustomAvatar) {
//            self.headImageView.image = [UIImage easeUIImageNamed:@"defaultHead"];
            self.headImageView.image = [UIImage imageNamed:@"defaultHead"];
        }
    }
    
    if (model.message.chatType == EMChatTypeChat) {
        if (model.message.direction == EMMessageDirectionSend) {
            self.stateLabel.hidden = false;
            switch (model.message.status) {
                case EMMessageStatusPending:{
                    self.stateLabel.text = @"等待发送";
                    break;
                }
                case EMMessageStatusDelivering:{
                    self.stateLabel.text = @"正在发送";
                    break;
                }
                case EMMessageStatusSucceed:{
                    if (model.message.isReadAcked) {
                        self.stateLabel.text = @"已读";
                    }else{
                        self.stateLabel.text = @"未读";
                    }
                    break;
                }
                case EMMessageStatusFailed:{
                    self.stateLabel.text = @"发送失败";
                    break;
                }
                default:
                    break;
            }
        }else{
            self.stateLabel.hidden = true;
        }
    }
}

@end
