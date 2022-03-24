//
//  EMBottomMoreFunctionViewEmojiCell.m
//  EaseIMKit
//
//  Created by 冯钊 on 2022/2/22.
//

#import "EMBottomMoreFunctionViewEmojiCell.h"

#import "UIImage+EaseUI.h"

@interface EMBottomMoreFunctionViewEmojiCell ()

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation EMBottomMoreFunctionViewEmojiCell

- (void)setImageName:(NSString *)imageName {
    _imageName = imageName;
    _imageView.image = [UIImage easeUIImageNamed:imageName];
}

- (void)setAdded:(BOOL)added {
    _added = added;
    _bgView.hidden = !added;
}

@end
