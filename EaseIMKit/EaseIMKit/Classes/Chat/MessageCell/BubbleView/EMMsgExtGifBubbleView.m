//
//  EMMsgExtGifBubbleView.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/2/14.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMMsgExtGifBubbleView.h"
#import "EaseEmoticonGroup.h"

@implementation EMMsgExtGifBubbleView

- (instancetype)initWithDirection:(EMMessageDirection)aDirection
                             type:(EMMessageType)aType
                        viewModel:(EaseChatViewModel *)viewModel
{
    self = [super initWithDirection:aDirection type:aType viewModel:viewModel];
    if (self) {
        self.gifView = [[EaseAnimatedImgView alloc] init];
        [self addSubview:self.gifView];
        [self.gifView Ease_makeConstraints:^(EaseConstraintMaker *make) {
            make.edges.equalTo(self);
            make.width.height.lessThanOrEqualTo(@100);
        }];
    }
    
    return self;
}

#pragma mark - Setter

- (void)setModel:(EaseMessageModel *)model
{
    EMMessageType type = model.type;
    if (type == EMMessageTypeExtGif) {
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
    }
}

@end
