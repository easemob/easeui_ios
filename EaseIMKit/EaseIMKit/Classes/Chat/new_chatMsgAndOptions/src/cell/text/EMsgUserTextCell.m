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

    [self.textView Ease_remakeConstraints:^(EaseConstraintMaker *make) {
        make.top.Ease_equalTo(0);
        switch (direction) {
            case EMMessageDirectionSend:
                make.left.Ease_greaterThanOrEqualTo(0);
                make.right.Ease_equalTo(0);
                break;
            case EMMessageDirectionReceive:
                make.left.Ease_equalTo(0);
                make.right.Ease_lessThanOrEqualTo(0);
                break;
            default:
                break;
        }
        make.bottom.Ease_equalTo(0);
    }];

    UIEdgeInsets bubbleEdgeInsets =
    [EMsgTableViewFunctions
                                         convertToEdgeInsets_direction:direction
     top:EMsgCellBubbleLayoutAdapterConfigs.shared.currentAdapter.top
     fromSide:EMsgCellBubbleLayoutAdapterConfigs.shared.currentAdapter.fromSide
     toSide:EMsgCellBubbleLayoutAdapterConfigs.shared.currentAdapter.toSide
     bottom:EMsgCellBubbleLayoutAdapterConfigs.shared.currentAdapter.bottom];
    
    [self.bubbleView Ease_remakeConstraints:^(EaseConstraintMaker *make) {
        make.top.Ease_equalTo(self.textView).offset(-bubbleEdgeInsets.top);
        make.left.Ease_equalTo(self.textView).offset(-bubbleEdgeInsets.left);
        make.bottom.Ease_equalTo(self.textView).offset(bubbleEdgeInsets.bottom);
        make.right.Ease_equalTo(self.textView).offset(bubbleEdgeInsets.right);
    }];
    self.bubbleView.image = [EMsgCellBubbleLayoutAdapterConfigs.shared.currentAdapter bubbleImage:direction];
}


- (void)bindDataFromViewModel:(EMsgBaseCellModel *)model{
    [self resetSubViewsLayout:model.direction
                     showHead:[EMsgTableViewConfig.shared showHead_chatType:model.message.chatType direction:model.direction]
                     showName:[EMsgTableViewConfig.shared showName_chatType:model.message.chatType direction:model.direction]];
    [super bindDataFromViewModel:model];

    EMTextMessageBody *body = (EMTextMessageBody *)model.message.body;
    self.textView.attributedText =
    [EMsgTableViewFunctions attributedString:body.text font:EMsgTableViewConfig.shared.textFont color:UIColor.blackColor];
    
//    attributedString(body.text, EMsgTableViewConfig.shared.textFont, UIColor.blackColor);
}

@end




