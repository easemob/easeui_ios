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
    long long _latestUpdateTime;
    NSMutableAttributedString *_showInfo;
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
        _showInfo = [[NSMutableAttributedString alloc] initWithString:@""];
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

- (EMConversationType)type
{
    return _conversation.type;
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

- (NSAttributedString *)showInfo {
    
    if (_latestUpdateTime == _conversation.latestMessage.timestamp) {
        return _showInfo;
    }
    
    EMMessage *msg = _conversation.latestMessage;
    _latestUpdateTime = msg.timestamp;
    NSString *msgStr = nil;
    switch (msg.body.type) {
        case EMMessageBodyTypeText:
        {
            EMTextMessageBody *body = (EMTextMessageBody *)msg.body;
            msgStr = body.text;
        }
            break;
        case EMMessageBodyTypeLocation:
        {
            msgStr = @"[位置]";
        }
            break;
        case EMMessageBodyTypeCustom:
        {
            msgStr = @"[自定义消息]";
        }
            break;
        case EMMessageBodyTypeImage:
        {
            msgStr = @"[图片]";
        }
            break;
        case EMMessageBodyTypeFile:
        {
            msgStr = @"[文件]";
        }
            break;
        case EMMessageBodyTypeVoice:
        {
            msgStr = @"[音频]";
        }
            break;
        case EMMessageBodyTypeVideo:
        {
            msgStr = @"[视频]";
        }
            break;
            
        default:
            break;
    }
    
    _showInfo = [[NSMutableAttributedString alloc] initWithString:msgStr];
    if ([_conversation draft] && ![[_conversation draft] isEqualToString:@""]) {
        msgStr = [NSString stringWithFormat:@"%@ %@", @"[草稿]", [_conversation draft]];
        _showInfo = [[NSMutableAttributedString alloc] initWithString:msgStr];
        [_showInfo setAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:255/255.0 green:43/255.0 blue:43/255.0 alpha:1.0]} range:NSMakeRange(0, msgStr.length)];
    }
    if ([_conversation remindMe]) {
        msgStr = [NSString stringWithFormat:@"%@ %@", @"[有人@我]", msgStr];
        _showInfo = [[NSMutableAttributedString alloc] initWithString:msgStr];
        [_showInfo setAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:255/255.0 green:43/255.0 blue:43/255.0 alpha:1.0]} range:NSMakeRange(0, msgStr.length)];
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
