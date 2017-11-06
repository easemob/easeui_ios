//
//  EMImageManager.h
//  EaseUI
//
//  Created by XieYajie on 06/11/2017.
//  Copyright © 2017 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EMImageManagerDelegate

@optional

- (void)didShowImageWithView:(UIImageView *)aImgView
                    imageUrl:(NSString *)aUrl
                defaultImage:(UIImage *)aDefaultImg;

@end

@class EaseEmotion;
@interface EMImageManager : NSObject

+ (instancetype)sharedManager;

- (void)addDelegate:(id<EMImageManagerDelegate>)aDelegate
              queue:(dispatch_queue_t)aQueue;

- (void)removeDelegate:(id<EMImageManagerDelegate>)aDelegate;

- (void)showImageWithView:(UIImageView *)aImgView
                 imageUrl:(NSString *)aUrl
             defaultImage:(UIImage *)aDefaultImg;

- (UIImage *)getGIFImageWithEmotion:(EaseEmotion *)aEmotion;

// UIImage, NSString, NSURL
- (void)showBrowserWithImages:(NSArray *)aImages
                 currentIndex:(NSInteger)aIndex;

@end
