//
//  EMImageManager.h
//  EaseUI
//
//  Created by XieYajie on 06/11/2017.
//  Copyright © 2017 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EaseEmotion;

@protocol EMImageManagerDelegate

@optional

- (void)didShowImageWithView:(UIImageView *)aImgView
                    imageUrl:(NSString *)aUrl
                defaultImage:(UIImage *)aDefaultImg;

// UIImage, NSString, NSURL
- (void)didShowBrowserWithImages:(NSArray *)aImages
                    currentIndex:(NSInteger)aIndex;

- (UIImage *)getGIFImageWithEmotion:(EaseEmotion *)aEmotion;

@end

@interface EMImageManager : NSObject

@property (nonatomic, weak) id<EMImageManagerDelegate> delegate;

+ (instancetype)sharedManager;

- (void)setDelegate:(id<EMImageManagerDelegate>)aDelegate;

- (void)showImageWithView:(UIImageView *)aImgView
                 imageUrl:(NSString *)aUrl
             defaultImage:(UIImage *)aDefaultImg;

- (UIImage *)getGIFImageWithEmotion:(EaseEmotion *)aEmotion;

// UIImage, NSString, NSURL
- (void)showBrowserWithImages:(NSArray *)aImages
                 currentIndex:(NSInteger)aIndex;

@end
