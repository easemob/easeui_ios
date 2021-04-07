//
//  EMMsgTextBubbleView.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/2/14.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMMsgTextBubbleView.h"

@interface EMMsgTextBubbleView ()
{
    EaseChatViewModel *_viewModel;
}

@end
@implementation EMMsgTextBubbleView

- (instancetype)initWithDirection:(EMMessageDirection)aDirection
                             type:(EMMessageType)aType
                        viewModel:(EaseChatViewModel *)viewModel
{
    self = [super initWithDirection:aDirection type:aType viewModel:viewModel];
    if (self) {
        _viewModel = viewModel;
        [self _setupSubviews];
    }
    
    return self;
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    [self setupBubbleBackgroundImage];
    
    self.textLabel = [[UILabel alloc] init];
    self.textLabel.font = [UIFont systemFontOfSize:_viewModel.contentFontSize];
    self.textLabel.numberOfLines = 0;
    [self addSubview:self.textLabel];
    [self.textLabel Ease_makeConstraints:^(EaseConstraintMaker *make) {
        make.top.equalTo(self.ease_top).offset(10);
        make.bottom.equalTo(self.ease_bottom).offset(-10);
    }];
    self.textLabel.textColor = _viewModel.contentFontColor;
    if (self.direction == EMMessageDirectionSend) {
        [self.textLabel Ease_makeConstraints:^(EaseConstraintMaker *make) {
            make.left.equalTo(self.ease_left).offset(10);
            make.right.equalTo(self.ease_right).offset(-10);
        }];
    } else {
        [self.textLabel Ease_makeConstraints:^(EaseConstraintMaker *make) {
            make.left.equalTo(self.ease_left).offset(10);
            make.right.equalTo(self.ease_right).offset(-10);
        }];
    }
}

#pragma mark - Setter

- (void)setModel:(EaseMessageModel *)model
{
    EMTextMessageBody *body = (EMTextMessageBody *)model.message.body;
    NSString *text = [EaseEmojiHelper convertEmoji:body.text];
    NSMutableAttributedString *attaStr = [[NSMutableAttributedString alloc] initWithString:text];
    /*
    //下滑线
    NSMutableAttributedString *underlineStr = [[NSMutableAttributedString alloc] initWithString:@"下滑线"];
    [underlineStr addAttributes:@{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
                                  NSUnderlineColorAttributeName: [UIColor redColor]
                                  } range:NSMakeRange(0, 3)];
    [attaStr appendAttributedString:underlineStr];
    //删除线
    NSMutableAttributedString *throughlineStr = [[NSMutableAttributedString alloc] initWithString:@"删除线"];
    [throughlineStr addAttributes:@{NSStrikethroughStyleAttributeName: @(NSUnderlineStyleSingle),
                                    NSStrikethroughColorAttributeName: [UIColor orangeColor]
                                    } range:NSMakeRange(0, 3)];
    [attaStr appendAttributedString:throughlineStr];*/
    //超链接
    NSDataDetector *detector= [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink error:nil];
    NSArray *checkArr = [detector matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    for (NSTextCheckingResult *result in checkArr) {
        NSString *urlStr = result.URL.absoluteString;
        NSRange range = [text rangeOfString:urlStr options:NSCaseInsensitiveSearch];
        if(range.length > 0) {
            [attaStr setAttributes:@{NSLinkAttributeName : [NSURL URLWithString:urlStr]} range:NSMakeRange(range.location, urlStr.length)];
        }
    }
    /*
    NSString *urlStr = @"http://www.baidu.com";
    NSMutableAttributedString *linkStr = [[NSMutableAttributedString alloc] initWithString:urlStr];
    [linkStr addAttributes:@{NSLinkAttributeName: [NSURL URLWithString:urlStr]} range:NSMakeRange(0, urlStr.length)];
    [attaStr appendAttributedString:linkStr];*/
    //图片
    /*
    NSTextAttachment *imgAttach =  [[NSTextAttachment alloc] init];
    imgAttach.image = [UIImage imageNamed:@"dribbble64_imageio"];
    imgAttach.bounds = CGRectMake(0, 0, 30, 30);
    NSAttributedString *attachStr = [NSAttributedString attributedStringWithAttachment:imgAttach];
    [attaStr appendAttributedString:attachStr];*/
    
    self.textLabel.attributedText = attaStr;
}

@end
