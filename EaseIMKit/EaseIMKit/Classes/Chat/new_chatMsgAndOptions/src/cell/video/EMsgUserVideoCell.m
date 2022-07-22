//
//  EMsgUserVideoCell.m
//  EaseIMKit
//
//  Created by yangjian on 2022/5/20.
//

#import "EMsgUserVideoCell.h"

@interface EMsgUserVideoCell ()
@property (nonatomic,strong)UIView *msgContentView;
@property (nonatomic,strong)UIImageView *bubbleView;

@end


@implementation EMsgUserVideoCell

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
        [imageView Ease_makeConstraints:^(EaseConstraintMaker *make) {
            make.top.Ease_equalTo(0);
            make.left.Ease_equalTo(0);
            make.right.Ease_equalTo(0);
//            make.size.Ease_equalTo(CGSizeMake(80, 80));
            make.bottom.Ease_equalTo(0);
        }];
        self.msgVideoCoverView = imageView;
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
                     showHead:[EMsgTableViewConfig.shared
                               showHead_chatType:model.message.chatType
                               direction:model.direction]
                     showName:[EMsgTableViewConfig.shared
                               showName_chatType:model.message.chatType
                               direction:model.direction]];
    [super bindDataFromViewModel:model];

    EMVideoMessageBody *body = (EMVideoMessageBody *)model.message.body;
    [self.msgVideoCoverView Ease_updateConstraints:^(EaseConstraintMaker *make) {
        /*
         这里说明一下,当滑动列表,触发复用时,会遇到约束冲突,
         其实是系统自动给 UITableViewCellContentView 这个添加了一个高度约束,
         而不同图片高度是变化的,从而导致复用时,重新给定高度,产生约束冲突.
         对此,我当前不知道如何解决(以前并没有遇到过这个问题,现在却有,很奇怪)
         */
        make.size.Ease_equalTo(model.imageFitSize);
    }];
//    UIImage *img = [UIImage imageWithContentsOfFile:body.thumbnailLocalPath];
//    if (img == nil) {
//        img = [UIImage imageNamed:@"alert_error"];
//    }
//    self.msgVideoCoverView.image = img;
    
    UIImage *img = nil;
    if (body.thumbnailLocalPath.length) {
        img = [UIImage imageWithContentsOfFile:body.thumbnailLocalPath];
    }
    if (img) {
        self.msgVideoCoverView.image = img;
    }else{
        BOOL isAutoDownloadThumbnail = EMClient.sharedClient.options.autoDownloadThumbnail;
        if (isAutoDownloadThumbnail) {
            [self.msgVideoCoverView
             Ease_setImageWithURL:[NSURL URLWithString:body.thumbnailRemotePath]
             placeholderImage:[UIImage easeUIImageNamed:@"msg_img_broken"]
             completed:^(UIImage * _Nullable image, NSError * _Nullable error, EaseImageCacheType cacheType, NSURL * _Nullable imageURL) {}];
        } else {
            self.msgVideoCoverView.image = [UIImage easeUIImageNamed:@"msg_img_broken"];
        }
    }
    
    
}

@end
