//
//  EMsgUserImageCell.m
//  EaseIMKit
//
//  Created by yangjian on 2022/5/20.
//

#import "EMsgUserImageCell.h"
@interface EMsgUserImageCell ()
@property (nonatomic,strong)UIView *msgContentView;
@property (nonatomic,strong)UIImageView *bubbleView;

@end


@implementation EMsgUserImageCell

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
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
        }];
        self.msgImageView = imageView;
    }
    [self configStateView];
    [self configBubble];
}

- (void)configStateView{
    [self.stateLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.msgContentView.mas_bottom);
        make.right.mas_equalTo(self.msgContentView.mas_left).offset(-20);
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
    [EMsgTableViewFunctions
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
    [self resetSubViewsLayout:model.direction
                     showHead:[EMsgTableViewConfig.shared
                               showHead_chatType:model.message.chatType
                               direction:model.direction]
                     showName:[EMsgTableViewConfig.shared
                               showName_chatType:model.message.chatType
                               direction:model.direction]];
    
    [super bindViewModel:model];

    EMImageMessageBody *body = (EMImageMessageBody *)model.message.body;
    [self.msgImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        /*
         这里说明一下,当滑动列表,触发复用时,会遇到约束冲突,
         其实是系统自动给 UITableViewCellContentView 这个添加了一个高度约束,
         而不同图片高度是变化的,从而导致复用时,重新给定高度,产生约束冲突.
         对此,我当前不知道如何解决(以前并没有遇到过这个问题,现在却有,很奇怪)
         
         不过,如果改用手动计算高度之后,估计这个问题就不再存在了.
         */
        make.size.mas_equalTo(model.imageFitSize);
    }];
    
    UIImage *img = nil;
    if (body.thumbnailLocalPath.length) {
        img = [UIImage imageWithContentsOfFile:body.thumbnailLocalPath];
    }
    if (img) {
        self.msgImageView.image = img;
    }else{
        if (body.localPath.length) {
            img = [UIImage imageWithContentsOfFile:body.localPath];
        }
        if (img) {
            self.msgImageView.image = img;
        }else{
            BOOL isAutoDownloadThumbnail = EMClient.sharedClient.options.autoDownloadThumbnail;
            if (isAutoDownloadThumbnail) {
                [self.msgImageView
                 Ease_setImageWithURL:[NSURL URLWithString:body.thumbnailRemotePath]
                 placeholderImage:[UIImage easeUIImageNamed:@"msg_img_broken"]
                 completed:^(UIImage * _Nullable image, NSError * _Nullable error, EaseImageCacheType cacheType, NSURL * _Nullable imageURL) {}];
            } else {
                self.msgImageView.image = [UIImage easeUIImageNamed:@"msg_img_broken"];
            }
        }
    }
}

@end
