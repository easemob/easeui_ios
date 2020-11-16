//
//  EaseConversationModel.m
//  EaseIMKit
//
//  Created by 娜塔莎 on 2020/11/10.
//

#import "EaseConversationModel.h"
#import "EMDefines.h"
#import "UIImage+EaseUI.h"


#import "EMConversation+EaseUI.h"

@interface EaseConversationModel()

{
    EMConversation *_conversation;
    NSString *_showName;
    EaseConversationModelType _type;
    long long _latestUpdateTime;
    NSString *_showInfo;
}

@end

@implementation EaseConversationModel

@synthesize draft;
@synthesize defaultAvatar;
@synthesize avatarURL;
@synthesize lastestUpdateTime;

- (instancetype)initWithConversation:(EMConversation *)conversation
{
    self = [super init];
    if (self) {
        _conversation = conversation;
        _type = EaseConversationModelType_Conversation;
        _showInfo = @"";
    }
    
    return self;
}

- (UIImage *)defaultAvatar {
    return [UIImage imageNamed:@"defaultAvatar"];
}


- (NSString*)itemId
{
    return _conversation.conversationId;
}

- (void)setIsTop:(BOOL)isTop {
    [_conversation setTop:isTop];
}

- (BOOL)isTop {
    return [_conversation isTop];
}

- (void)setShowName:(NSString *)showName {
    [_conversation setShowName:showName];
}

- (NSString *)showName
{
    return [_conversation showName];
}

- (void)setDraft:(NSString *)draft {
    [_conversation setDraft:draft];
}

- (NSString *)draft {
    return [_conversation draft];
}

- (int)unreadMessagesCount {
    return _conversation.unreadMessagesCount;
}

- (EaseConversationModelType)type {
    return _type;
}

- (NSString *)showInfo {
    
    if (_latestUpdateTime == _conversation.latestMessage.timestamp) {
        return _showInfo;
    }
    
    EMMessage *msg = _conversation.latestMessage;
    _latestUpdateTime = msg.timestamp;
    switch (msg.body.type) {
        case EMMessageBodyTypeText:
        {
            EMTextMessageBody *body = (EMTextMessageBody *)msg.body;
            _showInfo = body.text;
        }
            break;
        case EMMessageBodyTypeLocation:
        {
            _showInfo = @"[位置]";
        }
            break;
        case EMMessageBodyTypeCustom:
        {
            _showInfo = @"[自定义消息]";
        }
            break;
        case EMMessageBodyTypeImage:
        {
            _showInfo = @"[图片]";
        }
            break;
        case EMMessageBodyTypeFile:
        {
            _showInfo = @"[文件]";
        }
            break;
        case EMMessageBodyTypeVoice:
        {
            _showInfo = @"[音频]";
        }
            break;
        case EMMessageBodyTypeVideo:
        {
            _showInfo = @"[视频]";
        }
            break;
            
        default:
            break;
    }
    
    return _showInfo;
}

- (BOOL)remindMe {
    return [_conversation remindMe];
}

- (void)markAllAsRead {
    [_conversation markAllMessagesAsRead:nil];
}


@end
