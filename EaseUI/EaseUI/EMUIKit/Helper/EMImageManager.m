//
//  EMImageManager.m
//  EaseUI
//
//  Created by XieYajie on 06/11/2017.
//  Copyright © 2017 easemob. All rights reserved.
//

#import "EMImageManager.h"

static EMImageManager *sharedManager = nil;

@interface EMImageManager()

@end

@implementation EMImageManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[EMImageManager alloc] init];
    });
    
    return sharedManager;
}

- (void)showImageWithView:(UIImageView *)aImgView
                 imageUrl:(NSString *)aUrl
             defaultImage:(UIImage *)aDefaultImg
{
    if (self.delegate) {
        [self.delegate didShowImageWithView:aImgView imageUrl:aUrl defaultImage:aDefaultImg];
    }
}

- (UIImage *)getGIFImageWithEmotion:(EaseEmotion *)aEmotion
{
    if (self.delegate) {
        return [self.delegate getGIFImageWithEmotion:aEmotion];
    }
    
    return nil;
}

// UIImage, NSString, NSURL
- (void)showBrowserWithImages:(NSArray *)aImages
                 currentIndex:(NSInteger)aIndex
{
    if (self.delegate) {
        [self.delegate didShowBrowserWithImages:aImages currentIndex:aIndex];
    }
}

@end
