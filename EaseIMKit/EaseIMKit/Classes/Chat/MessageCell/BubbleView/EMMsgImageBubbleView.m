//
//  EMMsgImageBubbleView.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/2/14.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "UIImageView+EaseWebCache.h"
#import "EMMsgImageBubbleView.h"
#import "EaseHeaders.h"

#define kEMMsgImageDefaultSize 120
#define kEMMsgImageMinWidth 50
#define kEMMsgImageMaxWidth 120
#define kEMMsgImageMaxHeight 260

@implementation EMMsgImageBubbleView

- (instancetype)initWithDirection:(EMMessageDirection)aDirection
                             type:(EMMessageType)aType
                        viewModel:(EaseChatViewModel*)viewModel;
{
    self = [super initWithDirection:aDirection type:aType viewModel:viewModel];
    if (self) {
        self.layer.cornerRadius = 2;
        self.contentMode = UIViewContentModeScaleAspectFill;
    }
    
    return self;
}

#pragma mark - Private

- (CGSize)_getImageSize:(CGSize)aSize
{
    CGSize retSize = CGSizeZero;
    do {
        if (aSize.width == 0 || aSize.height == 0) {
            break;
        }
        CGFloat maxWidth = [UIScreen mainScreen].bounds.size.width / 2 - 60.0;
        NSInteger tmpWidth = aSize.width;
        if (aSize.width < kEMMsgImageMinWidth) {
            tmpWidth = kEMMsgImageMinWidth;
        }
        if (aSize.width > kEMMsgImageMaxWidth) {
            tmpWidth = kEMMsgImageMaxWidth;
        }
        
        NSInteger tmpHeight = tmpWidth / aSize.width * aSize.height;
        if (tmpHeight > kEMMsgImageMaxHeight) {
            tmpHeight = kEMMsgImageMaxHeight;
        }
        retSize = CGSizeMake(tmpWidth, tmpHeight);
        
    } while (0);
    
    return retSize;
}

- (void)setThumbnailImageWithLocalPath:(NSString *)aLocalPath
                            remotePath:(NSString *)aRemotePath
                          thumbImgSize:(CGSize)aThumbSize
                               imgSize:(CGSize)aSize
{
    UIImage *img = nil;
    if ([aLocalPath length] > 0) {
        img = [UIImage imageWithContentsOfFile:aLocalPath];
    }
    
    __weak typeof(self) weakself = self;
    void (^block)(CGSize aSize) = ^(CGSize aSize) {
        CGSize layoutSize = [weakself _getImageSize:aSize];
        [weakself Ease_updateConstraints:^(EaseConstraintMaker *make) {
            make.width.Ease_equalTo(layoutSize.width);
            make.height.Ease_equalTo(layoutSize.height);
        }];
    };
    
    CGSize size = aThumbSize;
    if (aThumbSize.width == 0 || aThumbSize.height == 0) 
        size = aSize;
    if (size.width == 0 || size.height == 0)
        size = CGSizeMake(70, 70);
    
    if (img) {
        self.image = img;
        size = img.size;
        block(size);
    } else {
        block(size);
        BOOL isAutoDownloadThumbnail = ([EMClient sharedClient].options.isAutoDownloadThumbnail);
        if (isAutoDownloadThumbnail) {
            [self Ease_setImageWithURL:[NSURL URLWithString:aRemotePath] placeholderImage:[UIImage easeUIImageNamed:@"msg_img_broken"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, EaseImageCacheType cacheType, NSURL * _Nullable imageURL) {}];
        } else {
            self.image = [UIImage easeUIImageNamed:@"msg_img_broken"];
        }
    }
}

#pragma mark - Setter

- (void)setModel:(EaseMessageModel *)model
{
    EMMessageType type = model.type;
    if (type == EMMessageTypeImage) {
        EMImageMessageBody *body = (EMImageMessageBody *)model.message.body;
        NSString *imgPath = body.thumbnailLocalPath;
        if ([imgPath length] == 0 && model.direction == EMMessageDirectionSend) {
            imgPath = body.localPath;
        }
        [self setThumbnailImageWithLocalPath:imgPath remotePath:body.thumbnailRemotePath thumbImgSize:body.thumbnailSize imgSize:body.size];
    }
}

@end
