//
//  EMsgUserVoiceCell.m
//  EaseIMKit
//
//  Created by yangjian on 2022/5/26.
//

#import "EMsgUserVoiceCell.h"




@interface EMsgUserVoiceCell ()

//@property (nonatomic,strong)UIView *msgContentView;

@property (nonatomic,strong)UIView *voiceContentView;
@property (nonatomic,strong)UIView *convertTextContentView;


@property (nonatomic,strong)UIImageView *bubbleView;

@property (nonatomic)EMVoiceConvertTextState voiceConvertTextState;
//@property (nonatomic)BOOL converted;
//@property (nonatomic)

@end

@implementation EMsgUserVoiceCell

+ (UIImage *)waveDefaultImage:(EMMessageDirection)direction{
    switch (direction) {
        case EMMessageDirectionSend:
            return [UIImage imageNamed:@"m_voice_send_2"];
        case EMMessageDirectionReceive:
            return [UIImage imageNamed:@"m_voice_receive_2"];
        default:
            return UIImage.new;
    }
}

+ (NSArray<UIImage *> *)waveImages:(EMMessageDirection)direction{
    switch (direction) {
        case EMMessageDirectionSend:
            return @[
                [UIImage imageNamed:@"m_voice_send_0"],
                [UIImage imageNamed:@"m_voice_send_1"],
                [UIImage imageNamed:@"m_voice_send_2"],
            ];
        case EMMessageDirectionReceive:
            return @[
                [UIImage imageNamed:@"m_voice_receive_0"],
                [UIImage imageNamed:@"m_voice_receive_1"],
                [UIImage imageNamed:@"m_voice_receive_2"],
            ];
        default:
            return @[
            ];
    }
}

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
//    self.msgContentView = UIView.new;
//    [self.msgBackgroundView addSubview:self.msgContentView];

    UIView *voiceContentView = UIView.new;
    [self.msgBackgroundView addSubview:voiceContentView];
    {
        float fontSize = 18;
        UILabel *label = UILabel.new;
        label.font = [UIFont systemFontOfSize:fontSize];
        label.textColor = UIColor.blackColor;
        [voiceContentView addSubview:label];
        self.durationLabel = label;
    }
    {
        UIImageView *imageView = UIImageView.new;
        imageView.animationDuration = 1.0;
        imageView.animationRepeatCount = 0;
        [voiceContentView addSubview:imageView];
        self.waveImageView = imageView;
    }
    self.voiceContentView = voiceContentView;
    
    UIView *convertTextContentView = UIView.new;
    convertTextContentView.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
    convertTextContentView.layer.cornerRadius = 6;
    convertTextContentView.layer.masksToBounds = true;
    [self.msgBackgroundView addSubview:convertTextContentView];
    {
        UILabel *label = UILabel.new;
        label.font = EMsgTableViewConfig.shared.voiceConvertTextFont;
        label.numberOfLines = 0;
        [convertTextContentView addSubview:label];
        
//        int edgeValue = 8;
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(EMsgCellOtherLayoutAdapterConfigs.shared.voiceConvertTextEdgeSpacing);
            make.left.mas_equalTo(EMsgCellOtherLayoutAdapterConfigs.shared.voiceConvertTextEdgeSpacing);
            make.bottom.mas_equalTo(- EMsgCellOtherLayoutAdapterConfigs.shared.voiceConvertTextEdgeSpacing);
            make.right.mas_equalTo(- EMsgCellOtherLayoutAdapterConfigs.shared.voiceConvertTextEdgeSpacing);
        }];
        self.convertTextLabel = label;
    }

    self.convertTextContentView = convertTextContentView;
    
    [self configBubble];
    
    self.durationLabel.backgroundColor = UIColor.yellowColor;
    
}

- (void)configBubble{
    self.bubbleView = UIImageView.new;
    [self.msgBackgroundView insertSubview:self.bubbleView belowSubview:self.voiceContentView];
}

- (void)resetSubViewsLayout:(EMMessageDirection)direction showHead:(BOOL)showHead showName:(BOOL)showName{
    [super resetSubViewsLayout:direction showHead:showHead showName:showName];
    UIEdgeInsets msgContentEdgeInsets =
    [EMsgCellLayoutAdapterConfigs.shared
     convertToEdgeInsets_direction:direction
     top:EMsgCellLayoutAdapterConfigs.shared.contentLayoutAdapter.top
     fromSide:EMsgCellLayoutAdapterConfigs.shared.contentLayoutAdapter.fromSide
     toSide:EMsgCellLayoutAdapterConfigs.shared.contentLayoutAdapter.toSide
     bottom:EMsgCellLayoutAdapterConfigs.shared.contentLayoutAdapter.bottom];

    int waveAndDurationSpacing = 4;
    switch (direction) {
        case EMMessageDirectionSend:{
            [self.voiceContentView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(msgContentEdgeInsets.top);
                make.left.mas_greaterThanOrEqualTo(msgContentEdgeInsets.left);
                make.right.mas_equalTo(-msgContentEdgeInsets.right);
                make.height.mas_equalTo(EMsgCellOtherLayoutAdapterConfigs.shared.voiceContentViewHeight);
            }];
            [self.durationLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(0);
                make.left.mas_equalTo(0);
                make.right.mas_equalTo(-(EMsgCellOtherLayoutAdapterConfigs.shared.voiceContentViewHeight + waveAndDurationSpacing));
            }];
            [self.waveImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(0);
                make.width.mas_equalTo(EMsgCellOtherLayoutAdapterConfigs.shared.voiceContentViewHeight);
                make.height.mas_equalTo(EMsgCellOtherLayoutAdapterConfigs.shared.voiceContentViewHeight);
                make.right.mas_equalTo(0);
            }];
            self.durationLabel.textAlignment = NSTextAlignmentRight;
            break;
        }
        case EMMessageDirectionReceive:{
            [self.voiceContentView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(msgContentEdgeInsets.top);
                make.left.mas_equalTo(msgContentEdgeInsets.left);
                make.right.mas_lessThanOrEqualTo(-msgContentEdgeInsets.right);
                make.height.mas_equalTo(EMsgCellOtherLayoutAdapterConfigs.shared.voiceContentViewHeight);
            }];
            [self.durationLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(0);
                make.left.mas_equalTo(EMsgCellOtherLayoutAdapterConfigs.shared.voiceContentViewHeight + waveAndDurationSpacing);
                make.right.mas_equalTo(0);
            }];
            [self.waveImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(0);
                make.width.mas_equalTo(EMsgCellOtherLayoutAdapterConfigs.shared.voiceContentViewHeight);
                make.height.mas_equalTo(EMsgCellOtherLayoutAdapterConfigs.shared.voiceContentViewHeight);
                make.left.mas_equalTo(0);
            }];
            self.durationLabel.textAlignment = NSTextAlignmentLeft;
            break;
        }
        default:
            break;
    }
    self.waveImageView.image = [EMsgUserVoiceCell waveDefaultImage:direction];
    self.waveImageView.animationImages = [EMsgUserVoiceCell waveImages:direction];
    
    switch (self.voiceConvertTextState) {
        case EMVoiceConvertTextStateNone:{
            self.convertTextContentView.hidden = true;
            [self.voiceContentView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(- msgContentEdgeInsets.bottom);
            }];
            break;
        }
        default:{
            self.convertTextContentView.hidden = false;
            [self.convertTextContentView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.voiceContentView.mas_bottom).offset(msgContentEdgeInsets.bottom + EMsgCellOtherLayoutAdapterConfigs.shared.voiceContentToVoiceConvertTextContentSpacing);
                make.bottom.mas_equalTo(0);
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
                
            }];
                
            break;
        }
    }
    
    UIEdgeInsets bubbleEdgeInsets =
    [EMsgCellLayoutAdapterConfigs.shared
     convertToEdgeInsets_direction:direction
     top:EMsgCellBubbleLayoutAdapterConfigs.shared.catAdapter.top
     fromSide:EMsgCellBubbleLayoutAdapterConfigs.shared.catAdapter.fromSide
     toSide:EMsgCellBubbleLayoutAdapterConfigs.shared.catAdapter.toSide
     bottom:EMsgCellBubbleLayoutAdapterConfigs.shared.catAdapter.bottom];
    
    [self.bubbleView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.voiceContentView).offset(-bubbleEdgeInsets.top);
        make.left.mas_equalTo(self.voiceContentView).offset(-bubbleEdgeInsets.left);
        make.bottom.mas_equalTo(self.voiceContentView).offset(bubbleEdgeInsets.bottom);
        make.right.mas_equalTo(self.voiceContentView).offset(bubbleEdgeInsets.right);
    }];
    self.bubbleView.image = [EMsgCellBubbleLayoutAdapterConfigs.shared.catAdapter bubbleImage:direction];
}

- (void)bindViewModel:(EMsgBaseCellModel *)model{
    self.voiceConvertTextState = model.voiceConvertTextState;
    [self resetSubViewsLayout:model.direction
                     showHead:[EMsgTableViewConfig.shared showHead_chatType:model.message.chatType direction:model.direction]
                     showName:[EMsgTableViewConfig.shared showName_chatType:model.message.chatType direction:model.direction]];
    EMVoiceMessageBody *body = (EMVoiceMessageBody *)model.message.body;
    
    self.durationLabel.text = [NSString stringWithFormat:@"%d",body.duration];
//    [self.waveImageView startAnimating];
    
    switch (self.voiceConvertTextState) {
        case EMVoiceConvertTextStateNone:{
            break;
        }
        case EMVoiceConvertTextStateDoing:{
    //        self.convertTextLabel.text = [NSString stringWithFormat:@"%@...", model.voiceConvertText];
            self.convertTextLabel.text = model.voiceConvertText;
            self.convertTextLabel.textColor = UIColor.grayColor;
            break;
        }
        case EMVoiceConvertTextStateSuccess:{
            self.convertTextLabel.text = model.voiceConvertText;
            self.convertTextLabel.textColor = UIColor.blackColor;
            break;
        }
        case EMVoiceConvertTextStateFailure:{
            self.convertTextLabel.text = MSG_VOICE_CONVERTFAILURETEXT;
            self.convertTextLabel.textColor = UIColor.redColor;
            break;
        }
        default:{
            break;
        }
    }
    
}

@end


