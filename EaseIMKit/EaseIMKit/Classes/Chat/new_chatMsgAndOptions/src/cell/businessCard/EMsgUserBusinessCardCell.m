//
//  EMsgUserBusinessCardCell.m
//  EaseIMKit
//
//  Created by yangjian on 2022/5/25.
//

#import "EMsgUserBusinessCardCell.h"


@interface EMsgUserBusinessCardCell ()
@property (nonatomic,strong)UIView *msgContentView;
@property (nonatomic,strong)UIImageView *bubbleView;

@end

@implementation EMsgUserBusinessCardCell

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
        
        [imageView Ease_makeConstraints:^(EaseConstraintMaker *make) {
            make.top.Ease_equalTo(8);
            make.left.Ease_equalTo(8);
            make.width.Ease_equalTo(50);
            make.height.Ease_equalTo(50);
            make.right.Ease_equalTo(- (EMsgCellLayoutAdapterConfigs.shared.msgContentMaxWidth - 8 - 50));
        }];
        self.cardHeadImageView = imageView;
    }
    
    {
        UILabel *label = UILabel.new;
        label.numberOfLines = 2;
        [label setContentCompressionResistancePriority:UILayoutPriorityFittingSizeLevel forAxis:UILayoutConstraintAxisHorizontal];
        [self.msgContentView addSubview:label];
        [label Ease_makeConstraints:^(EaseConstraintMaker *make) {
            make.left.Ease_equalTo(self.cardHeadImageView.ease_right).offset(8);
            make.right.Ease_equalTo(-8);
            make.centerY.Ease_equalTo(self.cardHeadImageView);
        }];
        self.cardNameLabel = label;
    }
    {
        UIView *view = UIView.new;
        view.backgroundColor = UIColor.grayColor;
        [self.msgContentView addSubview:view];
        [view Ease_makeConstraints:^(EaseConstraintMaker *make) {
            make.top.Ease_equalTo(self.cardHeadImageView.ease_bottom).offset(20);
            make.left.Ease_equalTo(8);
            make.right.Ease_equalTo(-8);
            make.height.Ease_equalTo(0.6);
        }];
    }
    {
        float fontSize = 12;
        UILabel *label = UILabel.new;
        label.font = [UIFont systemFontOfSize:fontSize];
        label.textColor = UIColor.grayColor;
        label.text = @"[个人名片]";
        [self.msgContentView addSubview:label];
        [label Ease_makeConstraints:^(EaseConstraintMaker *make) {
            make.left.Ease_equalTo(8);
            make.top.Ease_equalTo(self.cardHeadImageView.ease_bottom).offset(20 + 2);
            make.height.Ease_equalTo(16);
            make.bottom.Ease_equalTo(- 2);
        }];
    }
    
    [self configStateView];
    [self configBubble];
}

- (void)configStateView{
    [self.stateLabel Ease_remakeConstraints:^(EaseConstraintMaker *make) {
        make.bottom.Ease_equalTo(self.msgContentView.ease_bottom);
        make.right.Ease_equalTo(self.msgContentView.ease_left).offset(-20);
    }];
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
    UIEdgeInsets msgContentEdgeInsets = [EMsgTableViewFunctions
                                         convertToEdgeInsets_direction:direction top:EMsgCellLayoutAdapterConfigs.shared.contentLayoutAdapter.top fromSide:EMsgCellLayoutAdapterConfigs.shared.contentLayoutAdapter.fromSide toSide:EMsgCellLayoutAdapterConfigs.shared.contentLayoutAdapter.toSide bottom:EMsgCellLayoutAdapterConfigs.shared.contentLayoutAdapter.bottom];
    [self.msgContentView Ease_remakeConstraints:^(EaseConstraintMaker *make) {
        make.top.Ease_equalTo(msgContentEdgeInsets.top);
        make.bottom.Ease_equalTo(-msgContentEdgeInsets.bottom);
        switch (direction) {
            case EMMessageDirectionSend:{
                make.left.Ease_greaterThanOrEqualTo(msgContentEdgeInsets.left);
                make.right.Ease_equalTo(-msgContentEdgeInsets.right);
                break;
            }
            case EMMessageDirectionReceive:{
                make.left.Ease_equalTo(msgContentEdgeInsets.left);
                make.right.Ease_lessThanOrEqualTo(-msgContentEdgeInsets.right);
                break;
            }
            default:
                break;
        }
    }];

    UIEdgeInsets bubbleEdgeInsets =
    [EMsgTableViewFunctions
     convertToEdgeInsets_direction:direction
     top:EMsgCellBubbleLayoutAdapterConfigs.shared.currentAdapter.top
     fromSide:EMsgCellBubbleLayoutAdapterConfigs.shared.currentAdapter.fromSide
     toSide:EMsgCellBubbleLayoutAdapterConfigs.shared.currentAdapter.toSide
     bottom:EMsgCellBubbleLayoutAdapterConfigs.shared.currentAdapter.bottom];
    
    [self.bubbleView Ease_remakeConstraints:^(EaseConstraintMaker *make) {
        make.top.Ease_equalTo(self.msgContentView).offset(-bubbleEdgeInsets.top);
        make.left.Ease_equalTo(self.msgContentView).offset(-bubbleEdgeInsets.left);
        make.bottom.Ease_equalTo(self.msgContentView).offset(bubbleEdgeInsets.bottom);
        make.right.Ease_equalTo(self.msgContentView).offset(bubbleEdgeInsets.right);
    }];
    self.bubbleView.image = [EMsgCellBubbleLayoutAdapterConfigs.shared.currentAdapter bubbleImage:direction];
}

- (void)bindDataFromViewModel:(EMsgBaseCellModel *)model{
    [self resetSubViewsLayout:model.direction
                     showHead:[EMsgTableViewConfig.shared showHead_chatType:model.message.chatType direction:model.direction]
                     showName:[EMsgTableViewConfig.shared showName_chatType:model.message.chatType direction:model.direction]];
    
    [super bindDataFromViewModel:model];
    
    EMCustomMessageBody *body = (EMCustomMessageBody *)model.message.body;
    NSString* uid = [body.customExt objectForKey:@"uid"];
    NSString* nickName = [body.customExt objectForKey:@"nickname"];
    NSString* strUrl = [body.customExt objectForKey:@"avatar"];
    
    if (nickName && nickName.length) {
        NSMutableAttributedString *mAttributedString = NSMutableAttributedString.new;
        [mAttributedString appendAttributedString:
         [EMsgTableViewFunctions attributedString:nickName font:[UIFont systemFontOfSize:16] color:UIColor.blackColor]];
        [mAttributedString appendAttributedString:
         [EMsgTableViewFunctions attributedString:[NSString stringWithFormat:@"\n(%@)",uid] font:[UIFont systemFontOfSize:13] color:UIColor.grayColor]];
        self.cardNameLabel.attributedText = mAttributedString;
    }else{
        self.cardNameLabel.attributedText = [EMsgTableViewFunctions attributedString:[NSString stringWithFormat:@"(%@)",uid] font:[UIFont systemFontOfSize:13] color:UIColor.grayColor];
    }
    
    [self.cardHeadImageView Ease_setImageWithURL:[NSURL URLWithString:strUrl]
                       placeholderImage:[UIImage imageNamed:@"defaultAvatar"]];
//    if (strUrl.length) {
//        [self.cardHeadImageView Ease_setImageWithURL:[NSURL URLWithString:strUrl]
//                           placeholderImage:[UIImage imageNamed:@"defaultAvatar"]];
//    }else{
//        self.cardHeadImageView.image = [UIImage imageNamed:@"defaultAvatar"];
//    }

}

@end

