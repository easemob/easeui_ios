//
//  EMsgUserBigEmojiCell.m
//  EaseIMKit
//
//  Created by yangjian on 2022/5/28.
//

#import "EMsgUserBigEmojiCell.h"


@interface EMsgUserBigEmojiCell ()
@property (nonatomic,strong)UIView *msgContentView;
@property (nonatomic,strong)UIImageView *bubbleView;

@end


@implementation EMsgUserBigEmojiCell

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
        EaseAnimatedImgView *imageView = EaseAnimatedImgView.new;
        [self.msgContentView addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.size.mas_equalTo(EMsgCellOtherLayoutAdapterConfigs.shared.bigEmojiContentSize);
            make.bottom.mas_equalTo(0);
        }];
        self.gifView = imageView;
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

- (void)bindDataFromViewModel:(EMsgBaseCellModel *)model{
    [self resetSubViewsLayout:model.direction
                     showHead:[EMsgTableViewConfig.shared
                               showHead_chatType:model.message.chatType
                               direction:model.direction]
                     showName:[EMsgTableViewConfig.shared
                               showName_chatType:model.message.chatType
                               direction:model.direction]];
    
    [super bindDataFromViewModel:model];

//    EMTextMessageBody *body = (EMTextMessageBody *)model.message.body;
    
    NSString *localeLanguageCode = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];;
    NSString *name = [(EMTextMessageBody *)model.message.body text];
    if ([localeLanguageCode isEqualToString:@"zh"] && [name containsString:@"Example"]) {
        name = [name stringByReplacingOccurrencesOfString:@"Example" withString:@"示例"];
    }
    if ([localeLanguageCode isEqualToString:@"en"] && [name containsString:@"示例"]) {
        name = [name stringByReplacingOccurrencesOfString:@"示例" withString:@"Example"];
    }
    EaseEmoticonGroup *group = [EaseEmoticonGroup getGifGroup];
    for (EaseEmoticonModel *model in group.dataArray) {
        if ([model.name isEqualToString:name]) {
            NSString *path = [[NSBundle mainBundle] pathForResource:@"EaseIMKit" ofType:@"bundle"];
            NSString *gifPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.gif",model.original]];
            NSData *imageData = [NSData dataWithContentsOfFile:gifPath];
            self.gifView.animatedImage = [EaseAnimatedImg animatedImageWithGIFData:imageData];
            break;
        }
    }
    
    
//    UIImage *img = [UIImage imageWithContentsOfFile:body.thumbnailLocalPath];
//    if (img == nil) {
//        img = [UIImage imageNamed:@"alert_error"];
//    }
//    self.msgVideoCoverView.image = img;
        
    
}

@end
