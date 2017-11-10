/************************************************************
 *  * Hyphenate CONFIDENTIAL
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Hyphenate Inc.
 */

#import "EaseMessageReadManager.h"
#import "EMCDDeviceManager.h"

#import "EMImageManager.h"

#define IMAGE_MAX_SIZE_5k 5120*2880

static EaseMessageReadManager *detailInstance = nil;

@interface EaseMessageReadManager()

@property (strong, nonatomic) UIWindow *keyWindow;

@property (strong, nonatomic) UIAlertView *textAlertView;

@end

@implementation EaseMessageReadManager

+ (id)defaultManager
{
    @synchronized(self){
        static dispatch_once_t pred;
        dispatch_once(&pred, ^{
            detailInstance = [[self alloc] init];
        });
    }
    
    return detailInstance;
}


#pragma mark - public

- (void)showBrowserWithImages:(NSArray *)imageArray
{
    [[EMImageManager sharedManager] showBrowserWithImages:imageArray currentIndex:0];
}

- (BOOL)prepareMessageAudioModel:(EaseMessageModel *)messageModel
                      updateViewCompletion:(void (^)(EaseMessageModel *prevAudioModel, EaseMessageModel *currentAudioModel))updateCompletion
{
    BOOL isPrepare = NO;
    
    if(messageModel.bodyType == EMMessageBodyTypeVoice)
    {
        EaseMessageModel *prevAudioModel = self.audioMessageModel;
        EaseMessageModel *currentAudioModel = messageModel;
        self.audioMessageModel = messageModel;
        
        BOOL isPlaying = messageModel.isMediaPlaying;
        if (isPlaying) {
            messageModel.isMediaPlaying = NO;
            self.audioMessageModel = nil;
            currentAudioModel = nil;
            [[EMCDDeviceManager sharedInstance] stopPlaying];
        }
        else {
            messageModel.isMediaPlaying = YES;
            prevAudioModel.isMediaPlaying = NO;
            isPrepare = YES;
            
            if (!messageModel.isMediaPlayed) {
                messageModel.isMediaPlayed = YES;
                EMMessage *chatMessage = messageModel.message;
                if (chatMessage.ext) {
                    NSMutableDictionary *dict = [chatMessage.ext mutableCopy];
                    if (![[dict objectForKey:@"isPlayed"] boolValue]) {
                        [dict setObject:@YES forKey:@"isPlayed"];
                        chatMessage.ext = dict;
                        [[EMClient sharedClient].chatManager updateMessage:chatMessage completion:nil];
                    }
                } else {
                    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:chatMessage.ext];
                    [dic setObject:@YES forKey:@"isPlayed"];
                    chatMessage.ext = dic;
                    [[EMClient sharedClient].chatManager updateMessage:chatMessage completion:nil];
                }
            }
        }
        
        if (updateCompletion) {
            updateCompletion(prevAudioModel, currentAudioModel);
        }
    }
    
    return isPrepare;
}

- (EaseMessageModel *)stopMessageAudioModel
{
    EaseMessageModel *model = nil;
    if (self.audioMessageModel.bodyType == EMMessageBodyTypeVoice) {
        if (self.audioMessageModel.isMediaPlaying) {
            model = self.audioMessageModel;
        }
        self.audioMessageModel.isMediaPlaying = NO;
        self.audioMessageModel = nil;
    }
    
    return model;
}

- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

@end
