//
//  EMsgUserFileCell.m
//  EaseIMKit
//
//  Created by yangjian on 2022/5/28.
//

#import "EMsgUserFileCell.h"

@interface EMsgUserFileCell ()
@property (nonatomic,strong)UIView *msgContentView;
@property (nonatomic,strong)UIImageView *bubbleView;

@end

@implementation EMsgUserFileCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self configMsgSubViews];
    }
    return self;
}

- (void)configMsgSubViews{
    self.msgContentView = UIView.new;
    [self.msgBackgroundView addSubview:self.msgContentView];

    {
        UIImageView *imageView = UIImageView.new;
        [self.msgContentView addSubview:imageView];
        imageView.image = [UIImage imageNamed:@"alert_error"];
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(0);
            make.width.mas_equalTo(50);
            make.height.mas_equalTo(50);
            make.right.mas_equalTo(- (EMsgCellLayoutAdapterConfigs.shared.msgContentMaxWidth - 50 - 0));
            make.bottom.mas_equalTo(0);


        }];
        self.fileIconImageView = imageView;
    }
    
    {
        UILabel *label = UILabel.new;
        label.font = [UIFont systemFontOfSize:16];
        [label setContentCompressionResistancePriority:UILayoutPriorityFittingSizeLevel forAxis:UILayoutConstraintAxisHorizontal];
        [self.msgContentView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.fileIconImageView.mas_right).offset(8);
            make.right.mas_equalTo(-8);
            make.centerY.mas_equalTo(self.fileIconImageView);
        }];
        self.fileNameLabel = label;
    }
    {
        UILabel *label = UILabel.new;
        label.font = [UIFont systemFontOfSize:13];
        [label setContentCompressionResistancePriority:UILayoutPriorityFittingSizeLevel forAxis:UILayoutConstraintAxisHorizontal];
        [self.msgContentView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.fileIconImageView.mas_right).offset(8);
            make.right.mas_equalTo(-8);
            make.top.mas_equalTo(self.fileNameLabel.mas_bottom).offset(4);
        }];
        self.fileSizeLabel = label;
    }
    
    
    [self configBubble];
}

- (void)configBubble{
    self.bubbleView = UIImageView.new;
    [self.msgBackgroundView insertSubview:self.bubbleView belowSubview:self.msgContentView];
    {
        self.msgContentView.userInteractionEnabled = false;
        self.bubbleView.userInteractionEnabled = true;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(messageTapGestureClick:)];
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(messagePressGestureClick:)];
        [self.bubbleView addGestureRecognizer:tapGesture];
        [self.bubbleView addGestureRecognizer:longPressGesture];
    }
}

- (void)messageTapGestureClick:(UITapGestureRecognizer *)tapGesture{
    [super messageTapGestureClick:tapGesture];
}
- (void)messagePressGestureClick:(UILongPressGestureRecognizer *)longPressGesture{
    [super messagePressGestureClick:longPressGesture];
}


- (void)resetSubViewsLayout:(EMMessageDirection)direction showHead:(BOOL)showHead showName:(BOOL)showName{
    [super resetSubViewsLayout:direction showHead:showHead showName:showName];
    UIEdgeInsets msgContentEdgeInsets = [EMsgCellLayoutAdapterConfigs.shared
                                         convertToEdgeInsets_direction:direction top:EMsgCellLayoutAdapterConfigs.shared.contentLayoutAdapter.top fromSide:EMsgCellLayoutAdapterConfigs.shared.contentLayoutAdapter.fromSide toSide:EMsgCellLayoutAdapterConfigs.shared.contentLayoutAdapter.toSide bottom:EMsgCellLayoutAdapterConfigs.shared.contentLayoutAdapter.bottom];
    [self.msgContentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(msgContentEdgeInsets.top);
        make.bottom.mas_equalTo(-msgContentEdgeInsets.bottom);
        switch (direction) {
            case EMMessageDirectionSend:{
                make.left.mas_greaterThanOrEqualTo(msgContentEdgeInsets.left);
                make.right.mas_equalTo(-msgContentEdgeInsets.right);
                break;
            }
            case EMMessageDirectionReceive:{
                make.left.mas_equalTo(msgContentEdgeInsets.left);
                make.right.mas_lessThanOrEqualTo(-msgContentEdgeInsets.right);
                break;
            }
            default:
                break;
        }
    }];

    UIEdgeInsets bubbleEdgeInsets =
    [EMsgCellLayoutAdapterConfigs.shared
     convertToEdgeInsets_direction:direction
     top:EMsgCellBubbleLayoutAdapterConfigs.shared.catAdapter.top
     fromSide:EMsgCellBubbleLayoutAdapterConfigs.shared.catAdapter.fromSide
     toSide:EMsgCellBubbleLayoutAdapterConfigs.shared.catAdapter.toSide
     bottom:EMsgCellBubbleLayoutAdapterConfigs.shared.catAdapter.bottom];
    
    [self.bubbleView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.msgContentView).offset(-bubbleEdgeInsets.top);
        make.left.mas_equalTo(self.msgContentView).offset(-bubbleEdgeInsets.left);
        make.bottom.mas_equalTo(self.msgContentView).offset(bubbleEdgeInsets.bottom);
        make.right.mas_equalTo(self.msgContentView).offset(bubbleEdgeInsets.right);
    }];
    self.bubbleView.image = [EMsgCellBubbleLayoutAdapterConfigs.shared.catAdapter bubbleImage:direction];
}

- (void)bindViewModel:(EMsgBaseCellModel *)model{
    self.weakModel = model;
    [self resetSubViewsLayout:model.direction
                     showHead:[EMsgTableViewConfig.shared showHead_chatType:model.message.chatType direction:model.direction]
                     showName:[EMsgTableViewConfig.shared showName_chatType:model.message.chatType direction:model.direction]];
    EMFileMessageBody *body = (EMFileMessageBody *)model.message.body;
    self.fileNameLabel.text = body.displayName;
    self.fileSizeLabel.text = [NSString stringWithFormat:@"%lld字节",body.fileLength];
}

@end

