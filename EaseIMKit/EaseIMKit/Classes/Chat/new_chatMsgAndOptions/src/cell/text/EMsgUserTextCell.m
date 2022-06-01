//
//  EMsgUserTextCell.m
//  EaseIMKit
//
//  Created by yangjian on 2022/5/18.
//

#import "EMsgUserTextCell.h"
@interface EMsgUserTextCell ()

@property (nonatomic,strong)UIView *msgContentView;
@property (nonatomic,strong)UIImageView *bubbleView;

@end

@implementation EMsgUserTextCell


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

    self.textView = UITextView.new;
    self.textView.backgroundColor = UIColor.clearColor;
    self.textView.textContainer.lineFragmentPadding = 0;
    self.textView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.textView.editable = false;
    self.textView.scrollEnabled = false;
    self.textView.userInteractionEnabled = false;
    [self.textView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.textView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.textView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.textView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];

    [self.msgContentView addSubview:self.textView];
    
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

    [self.textView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        switch (direction) {
            case EMMessageDirectionSend:
                make.left.mas_greaterThanOrEqualTo(0);
                make.right.mas_equalTo(0);
                break;
            case EMMessageDirectionReceive:
                make.left.mas_equalTo(0);
                make.right.mas_lessThanOrEqualTo(0);
                break;
            default:
                break;
        }
        make.bottom.mas_equalTo(0);
    }];

    UIEdgeInsets bubbleEdgeInsets =
    [EMsgCellLayoutAdapterConfigs.shared
     convertToEdgeInsets_direction:direction
     top:EMsgCellBubbleLayoutAdapterConfigs.shared.catAdapter.top
     fromSide:EMsgCellBubbleLayoutAdapterConfigs.shared.catAdapter.fromSide
     toSide:EMsgCellBubbleLayoutAdapterConfigs.shared.catAdapter.toSide
     bottom:EMsgCellBubbleLayoutAdapterConfigs.shared.catAdapter.bottom];
    
    [self.bubbleView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.textView).offset(-bubbleEdgeInsets.top);
        make.left.mas_equalTo(self.textView).offset(-bubbleEdgeInsets.left);
        make.bottom.mas_equalTo(self.textView).offset(bubbleEdgeInsets.bottom);
        make.right.mas_equalTo(self.textView).offset(bubbleEdgeInsets.right);
    }];
    self.bubbleView.image = [EMsgCellBubbleLayoutAdapterConfigs.shared.catAdapter bubbleImage:direction];
}


- (void)bindViewModel:(EMsgBaseCellModel *)model{
    model.weakCell = self;
    self.weakModel = model;
    [self resetSubViewsLayout:model.direction
                     showHead:[EMsgTableViewConfig.shared showHead_chatType:model.message.chatType direction:model.direction]
                     showName:[EMsgTableViewConfig.shared showName_chatType:model.message.chatType direction:model.direction]];

    EMTextMessageBody *body = (EMTextMessageBody *)model.message.body;
    self.textView.attributedText =
    [EMsgTableViewFunctions attributedString:body.text font:EMsgTableViewConfig.shared.textFont color:UIColor.blackColor];
    
//    attributedString(body.text, EMsgTableViewConfig.shared.textFont, UIColor.blackColor);
}

@end




