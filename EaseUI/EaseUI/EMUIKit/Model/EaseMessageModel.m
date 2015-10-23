//
//  EaseMessageModel.m
//  ChatDemo-UI3.0
//
//  Created by dhc on 15/6/26.
//  Copyright (c) 2015年 easemob.com. All rights reserved.
//

#import "EaseMessageModel.h"

#import "EaseMob.h"
#import "EaseEmotionEscape.h"
#import "EaseConvertToCommonEmoticonsHelper.h"

@implementation EaseMessageModel

- (instancetype)initWithMessage:(EMMessage *)message
{
    self = [super init];
    if (self) {
        _cellHeight = -1;
        _message = message;
        _firstMessageBody = [message.messageBodies firstObject];
        _isMediaPlaying = NO;
        
        NSDictionary *userInfo = [[EaseMob sharedInstance].chatManager loginInfo];
        NSString *login = [userInfo objectForKey:kSDKUsername];
        _nickname = (message.messageType == eMessageTypeChat) ? message.from : message.groupSenderName;
        _isSender = [login isEqualToString:_nickname] ? YES : NO;
        
        switch (_firstMessageBody.messageBodyType) {
            case eMessageBodyType_Text:
            {
                EMTextMessageBody *textBody = (EMTextMessageBody *)_firstMessageBody;
                // 表情映射。
                NSString *didReceiveText = [EaseConvertToCommonEmoticonsHelper convertToSystemEmoticons:textBody.text];
                self.attrBody = [EaseEmotionEscape attStringFromTextForChatting:didReceiveText];
                self.text = didReceiveText;
            }
                break;
            case eMessageBodyType_Image:
            {
                EMImageMessageBody *imgMessageBody = (EMImageMessageBody *)_firstMessageBody;
                self.thumbnailImageSize = imgMessageBody.thumbnailSize;
                self.thumbnailImage = [UIImage imageWithContentsOfFile:imgMessageBody.thumbnailLocalPath];
                self.imageSize = imgMessageBody.size;
                self.fileLocalPath = imgMessageBody.localPath;
                if (_isSender) {
                    self.image = [UIImage imageWithContentsOfFile:imgMessageBody.thumbnailLocalPath];
                } else {
                    self.fileURLPath = imgMessageBody.remotePath;
                }
            }
                break;
            case eMessageBodyType_Location:
            {
                EMLocationMessageBody *locationBody = (EMLocationMessageBody *)_firstMessageBody;
                self.address = locationBody.address;
                self.latitude = locationBody.latitude;
                self.longitude = locationBody.longitude;
            }
                break;
            case eMessageBodyType_Voice:
            {
                EMVoiceMessageBody *voiceBody = (EMVoiceMessageBody *)_firstMessageBody;
                self.mediaDuration = voiceBody.duration;
                self.isMediaPlayed = NO;
                if (message.ext) {
                    self.isMediaPlayed = [[message.ext objectForKey:@"isPlayed"] boolValue];
                }
                
                // 音频路径
                self.fileLocalPath = voiceBody.localPath;
                self.fileURLPath = voiceBody.remotePath;
            }
                break;
            case eMessageBodyType_Video:
            {
                EMVideoMessageBody *videoBody = (EMVideoMessageBody *)_firstMessageBody;
                self.thumbnailImageSize = videoBody.size;
                self.thumbnailImage = [UIImage imageWithContentsOfFile:videoBody.thumbnailLocalPath];
                self.imageSize = videoBody.size;
                self.image = self.thumbnailImage;
                
                // 视频路径
                self.fileLocalPath = videoBody.localPath;
                self.fileURLPath = videoBody.remotePath;
            }
                break;
                case eMessageBodyType_File:
            {
                EMFileMessageBody *fileMessageBody = (EMFileMessageBody *)_firstMessageBody;
                self.fileIconName = @"chat_item_file";
                self.fileName = fileMessageBody.displayName;
                self.fileSize = fileMessageBody.fileLength;
                
                if (self.fileSize < 1024) {
                    self.fileSizeDes = [NSString stringWithFormat:@"%fB", self.fileSize];
                }
                else if(self.fileSize < 1024 * 1024){
                    self.fileSizeDes = [NSString stringWithFormat:@"%.2fkB", self.fileSize / 1024];
                }
                else if (self.fileSize < 2014 * 1024 * 1024){
                    self.fileSizeDes = [NSString stringWithFormat:@"%.2fMB", self.fileSize / (1024 * 1024)];
                }
            }
                break;
            default:
                break;
        }
    }
    
    return self;
}

- (NSString *)messageId
{
    return _message.messageId;
}

- (MessageDeliveryState)messageStatus
{
    return _message.deliveryState;
}

- (EMMessageType)messageType
{
    return _message.messageType;
}

- (MessageBodyType)bodyType
{
    return self.firstMessageBody.messageBodyType;
}

- (BOOL)isMessageRead
{
    return _message.isReadAcked;
}

@end
