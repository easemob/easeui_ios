//
//  EaseSDKHelper.h
//  ChatDemo-UI3.0
//
//  Created by dhc on 15/6/24.
//  Copyright (c) 2015年 easemob.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#define KNOTIFICATION_LOGINCHANGE @"loginStateChange"
#define KNOTIFICATION_CALL @"callOutWithChatter"
#define KNOTIFICATION_CALL_CLOSE @"callControllerClose"

#define kSDKConfigEnableConsoleLogger @"SDKConfigEnableConsoleLogger"
#define kEaseUISDKConfigIsUseLite @"isUselibEaseMobClientSDKLite"

@interface EaseSDKHelper : NSObject<EMClientDelegate>

@property (nonatomic) BOOL isShowingimagePicker;

@property (nonatomic) BOOL isLite;

+ (instancetype)shareHelper;

#pragma mark - init easemob

- (void)easemobApplication:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
                    appkey:(NSString *)appkey
              apnsCertName:(NSString *)apnsCertName
               otherConfig:(NSDictionary *)otherConfig;

#pragma mark - send message

+ (EMMessage *)sendTextMessage:(NSString *)text
                            to:(NSString *)to
                   messageType:(EMChatType)messageType
                    messageExt:(NSDictionary *)messageExt;

+ (EMMessage *)sendLocationMessageWithLatitude:(double)latitude
                                     longitude:(double)longitude
                                       address:(NSString *)address
                                            to:(NSString *)to
                                   messageType:(EMChatType)messageType
                             requireEncryption:(BOOL)requireEncryption
                                    messageExt:(NSDictionary *)messageExt;

+ (EMMessage *)sendImageMessageWithImageData:(NSData *)imageData
                                          to:(NSString *)to
                                 messageType:(EMChatType)messageType
                           requireEncryption:(BOOL)requireEncryption
                                  messageExt:(NSDictionary *)messageExt
                                    progress:(id)progress;

+ (EMMessage *)sendImageMessageWithImage:(UIImage *)image
                                      to:(NSString *)to
                             messageType:(EMChatType)messageType
                       requireEncryption:(BOOL)requireEncryption
                              messageExt:(NSDictionary *)messageExt
                                progress:(id)progress;

+ (EMMessage *)sendVoiceMessageWithLocalPath:(NSString *)localPath
                                    duration:(NSInteger)duration
                                          to:(NSString *)to
                           messageType:(EMChatType)messageType
                     requireEncryption:(BOOL)requireEncryption
                            messageExt:(NSDictionary *)messageExt
                                    progress:(id)progress;

+ (EMMessage *)sendVideoMessageWithURL:(NSURL *)url
                                    to:(NSString *)to
                           messageType:(EMChatType)messageType
                     requireEncryption:(BOOL)requireEncryption
                            messageExt:(NSDictionary *)messageExt
                              progress:(id)progress;

#pragma mark - call

@end
