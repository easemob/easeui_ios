//
//  EaseMessageQuoteView.m
//  EaseIMKit
//
//  Created by 冯钊 on 2023/4/26.
//

#import "EaseMessageQuoteView.h"
#import <HyphenateChat/HyphenateChat.h>
#import "EMChatMessage+EaseUIExt.h"
#import "Easeonry.h"
#import "UIImageView+EaseWebCache.h"
#import "UIImage+EaseUI.h"
#import "EaseUserUtils.h"
#import "EaseEmoticonGroup.h"
#import "EaseEmojiHelper.h"

@interface EaseMessageQuoteView ()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *videoImageView;
@property (nonatomic, strong) UILabel *contentLabel;

@end

@implementation EaseMessageQuoteView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithRed:0.902 green:0.902 blue:0.902 alpha:1];
        self.layer.cornerRadius = 8;
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
        _nameLabel.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1];
        [self addSubview:_nameLabel];
        
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.layer.cornerRadius = 2;
        _imageView.layer.masksToBounds = YES;
        [self addSubview:_imageView];
        
        _videoImageView = [[UIImageView alloc] init];
        _videoImageView.image = [UIImage easeUIImageNamed:@"msg_video_white"];
        [_imageView addSubview:_videoImageView];
        [_videoImageView Ease_makeConstraints:^(EaseConstraintMaker *make) {
            make.size.equalTo(@20);
            make.center.equalTo(_imageView);
        }];
        
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightRegular];
        _contentLabel.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1];
        _contentLabel.numberOfLines = 1;
        _contentLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [self addSubview:_contentLabel];
    }
    return self;
}

- (void)setMessage:(EMChatMessage *)message
{
    NSDictionary *quoteInfo = [message.ext objectForKey:@"msgQuote"];
    if (!quoteInfo || ![quoteInfo isKindOfClass:[NSDictionary class]]) {
        return;
    }
    if (quoteInfo) {
        NSDictionary <NSString *, NSNumber *>*msgTypeDict = @{
            @"txt": @(EMMessageBodyTypeText),
            @"img": @(EMMessageBodyTypeImage),
            @"video": @(EMMessageBodyTypeVideo),
            @"audio": @(EMMessageBodyTypeVoice),
            @"custom": @(EMMessageBodyTypeCustom),
            @"cmd": @(EMMessageBodyTypeCmd),
            @"file": @(EMMessageBodyTypeFile),
            @"location": @(EMMessageBodyTypeLocation)
        };
        NSString *quoteMsgId = [quoteInfo objectForKey:@"msgID"];
        NSString *msgType = [quoteInfo objectForKey:@"msgType"];
        NSString *msgSender = [quoteInfo objectForKey:@"msgSender"];
        NSString *msgPreview = [quoteInfo objectForKey:@"msgPreview"];
        if(quoteMsgId.length <= 0 || msgType.length <= 0 || msgSender.length <= 0 || msgPreview.length <= 0) {
            return;
        }
        EMMessageBodyType msgBodyType = [msgTypeDict objectForKey:msgType].intValue;
        EMChatMessage *quoteMessage = [EMClient.sharedClient.chatManager getMessageWithMessageId:quoteMsgId];
        
        _videoImageView.hidden = YES;
        _nameLabel.hidden = NO;
        _contentLabel.hidden = YES;
        _nameLabel.numberOfLines = 1;
        
        id<EaseUserDelegate> userInfo = [EaseUserUtils.shared getUserInfo:msgSender moduleType:quoteMessage.chatType == EMChatTypeChat ? EaseUserModuleTypeChat : EaseUserModuleTypeGroupChat];
        NSString *showName = userInfo.showName.length > 0 ? userInfo.showName : msgSender;
        NSMutableAttributedString *result = [[NSMutableAttributedString alloc] init];
        [result appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@:", showName] attributes:@{
            NSFontAttributeName: [UIFont systemFontOfSize:13 weight:UIFontWeightMedium]
        }]];
        
        if (_delegate && [_delegate respondsToSelector:@selector(quoteViewShowContent:)]) {
            NSAttributedString *content = [_delegate quoteViewShowContent:message];
            if (content) {
                [self setupTextLayout:2];
                [result appendAttributedString:content];
                self.nameLabel.attributedText = result;
                return;
            }
        }
        
        {
            switch (msgBodyType) {
                case EMMessageBodyTypeImage: {
                    [self setupImageLayout];
                    UIImage *img = nil;
                    if ([((EMImageMessageBody *)quoteMessage.body).localPath length] > 0) {
                        img = [UIImage imageWithContentsOfFile:((EMImageMessageBody *)quoteMessage.body).localPath];
                    }
                    if (img) {
                        _imageView.image = img;
                    } else {
                        [_imageView Ease_setImageWithURL:[NSURL URLWithString:((EMImageMessageBody *)quoteMessage.body).thumbnailRemotePath] placeholderImage:[UIImage easeUIImageNamed:@"msg_img_broken"]];
                    }
                    _nameLabel.attributedText = result;
                    break;
                }
                case EMMessageBodyTypeVideo: {
                    [self setupImageLayout];
                    _videoImageView.hidden = NO;
                    if ([quoteMessage.from isEqualToString:EMClient.sharedClient.currentUsername]) {
                        [_imageView Ease_setImageWithURL:[NSURL fileURLWithPath:((EMVideoMessageBody *)quoteMessage.body).thumbnailLocalPath] placeholderImage:[UIImage easeUIImageNamed:@"msg_img_broken"]];
                    } else {
                        [_imageView Ease_setImageWithURL:[NSURL URLWithString:((EMVideoMessageBody *)quoteMessage.body).thumbnailRemotePath] placeholderImage:[UIImage easeUIImageNamed:@"msg_img_broken"]];
                    }
                    _nameLabel.attributedText = result;
                    break;
                }
                case EMMessageBodyTypeFile: {
                    [self setupTextImageTextLayout];
                    _nameLabel.attributedText = result;
                    if (quoteMessage) {
                        _contentLabel.text = ((EMFileMessageBody *)quoteMessage.body).displayName;
                    } else {
                        _contentLabel.text = [NSString stringWithFormat:@"%@", msgPreview];
                    }
                    _imageView.image = [UIImage easeUIImageNamed:@"quote_file"];
                    break;
                }
                case EMMessageBodyTypeVoice: {
                    [self setupTextImageTextLayout];
                    _nameLabel.attributedText = result;
                    if (quoteMessage) {
                        _contentLabel.text = [NSString stringWithFormat:@"%d\"", ((EMVoiceMessageBody *)quoteMessage.body).duration];
                    } else {
                        _contentLabel.text = [NSString stringWithFormat:@"%@", msgPreview];
                    }
                    
                    _imageView.image = [UIImage easeUIImageNamed:@"quote_voice"];
                    break;
                }
                case EMMessageBodyTypeLocation: {
                    [self setupTextLayout:2];
                    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
                    attachment.image = [UIImage easeUIImageNamed:@"quote_location"];
                    attachment.bounds = CGRectMake(0, -4, attachment.image.size.width, attachment.image.size.height);
                    [result appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
                    if (quoteMessage)
                        [result appendAttributedString:[[NSAttributedString alloc] initWithString:((EMLocationMessageBody *)quoteMessage.body).address attributes:@{
                            NSFontAttributeName: [UIFont systemFontOfSize:13 weight:UIFontWeightRegular]
                        }]];
                    else
                        [result appendAttributedString:[[NSAttributedString alloc] initWithString:msgPreview]];
                    _nameLabel.attributedText = result;
                    break;
                }
                case EMMessageBodyTypeCustom: {
                    [self setupTextLayout:2];
                    NSString *showText = quoteMessage.easeUI_quoteShowText;
                    if (showText.length <= 0) {
                        showText = msgPreview;
                    }
                    [result appendAttributedString:[[NSAttributedString alloc] initWithString:[EaseEmojiHelper convertEmoji:showText] attributes:@{
                        NSFontAttributeName: [UIFont systemFontOfSize:13 weight:UIFontWeightRegular]
                    }]];
                    _nameLabel.attributedText = result;
                    break;
                }
                case EMMessageBodyTypeText: {
                    if (quoteMessage.ext[@"em_expression_id"]) {
                        [self setupImageLayout];
                        NSString *localeLanguageCode = [NSLocale.currentLocale objectForKey:NSLocaleLanguageCode];;
                        NSString *name = [(EMTextMessageBody *)quoteMessage.body text];
                        if ([localeLanguageCode isEqualToString:@"zh"] && [name containsString:@"Example"]) {
                            name = [name stringByReplacingOccurrencesOfString:@"Example" withString:@"示例"];
                        }
                        if ([localeLanguageCode isEqualToString:@"en"] && [name containsString:@"示例"]) {
                            name = [name stringByReplacingOccurrencesOfString:@"示例" withString:@"Example"];
                        }
                        EaseEmoticonGroup *group = [EaseEmoticonGroup getGifGroup];
                        for (EaseEmoticonModel *model in group.dataArray) {
                            if ([model.name isEqualToString:name]) {
                                NSString *path = [NSBundle.mainBundle pathForResource:@"EaseIMKit" ofType:@"bundle"];
                                NSString *gifPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.gif", model.original]];
                                NSData *imageData = [NSData dataWithContentsOfFile:gifPath];
                                self.imageView.image = [UIImage imageWithData:imageData];
                                break;
                            }
                        }
                        _nameLabel.attributedText = result;
                        break;
                    } else {
                        [self setupTextLayout:2];
                        NSString *showText = quoteMessage.easeUI_quoteShowText;
                        if (showText.length <= 0) {
                            showText = msgPreview;
                        }
                        [result appendAttributedString:[[NSAttributedString alloc] initWithString:[EaseEmojiHelper convertEmoji:showText] attributes:@{
                            NSFontAttributeName: [UIFont systemFontOfSize:13 weight:UIFontWeightRegular]
                        }]];
                        _nameLabel.attributedText = result;
                    }
                    break;
                }
                default: {
                    [self setupTextLayout:2];
                    NSString *showText = quoteMessage.easeUI_quoteShowText;
                    if (showText.length <= 0) {
                        showText = msgPreview;
                    }
                    [result appendAttributedString:[[NSAttributedString alloc] initWithString:[EaseEmojiHelper convertEmoji:showText] attributes:@{
                        NSFontAttributeName: [UIFont systemFontOfSize:13 weight:UIFontWeightRegular]
                    }]];
                    _nameLabel.attributedText = result;
                    break;
                }
            }
        }
        
    } else {
        _nameLabel.hidden = YES;
        _imageView.hidden = YES;
        _contentLabel.hidden = YES;
        [_nameLabel Ease_remakeConstraints:^(EaseConstraintMaker *make) {
            make.edges.Ease_equalTo(0);
        }];
        _nameLabel.attributedText = nil;
    }
}

- (void)setupTextLayout:(int)numberOfLines
{
    _imageView.hidden = YES;
    _nameLabel.numberOfLines = numberOfLines;
    _contentLabel.hidden = YES;
    [_nameLabel Ease_remakeConstraints:^(EaseConstraintMaker *make) {
        make.edges.Ease_equalTo(UIEdgeInsetsMake(8, 10, 8, 10));
    }];
    [_imageView Ease_remakeConstraints:^(EaseConstraintMaker *make) {
        make.size.equalTo(@0);
    }];
}

- (void)setupImageLayout
{
    _imageView.hidden = NO;
    [_nameLabel Ease_remakeConstraints:^(EaseConstraintMaker *make) {
        make.left.equalTo(@10);
        make.top.equalTo(@8);
    }];
    [_imageView Ease_remakeConstraints:^(EaseConstraintMaker *make) {
        make.size.equalTo(@36);
        make.left.equalTo(_nameLabel.ease_right).offset(4);
        make.top.equalTo(_nameLabel);
        make.right.equalTo(@-10);
        make.bottom.equalTo(@-8);
    }];
}

- (void)setupTextImageTextLayout
{
    _contentLabel.hidden = NO;
    _imageView.hidden = NO;
    [_nameLabel Ease_remakeConstraints:^(EaseConstraintMaker *make) {
        make.left.equalTo(@10);
        make.top.equalTo(@8);
        make.bottom.equalTo(@-10);
    }];
    [_imageView Ease_remakeConstraints:^(EaseConstraintMaker *make) {
        make.size.equalTo(@18);
        make.left.equalTo(_nameLabel.ease_right).offset(4);
        make.centerY.equalTo(_nameLabel);
    }];
    [_contentLabel Ease_remakeConstraints:^(EaseConstraintMaker *make) {
        make.left.equalTo(_imageView.ease_right).offset(4);
        make.right.equalTo(@-10);
        make.centerY.equalTo(_imageView);
    }];
}

@end
