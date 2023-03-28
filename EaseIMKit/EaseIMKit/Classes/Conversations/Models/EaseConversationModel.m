//
//  EaseConversationModel.m
//  EaseIMKit
//
//  Created by 娜塔莎 on 2020/11/10.
//

#import "EaseConversationModel.h"
#import "EaseDefines.h"
#import "UIImage+EaseUI.h"
#import "EMConversation+EaseUI.h"
#import "EaseEmojiHelper.h"
#import "EaseIMKitManager.h"

@interface EaseConversationModel()

{
    EMConversation *_conversation;
    NSString *_showName;
    long long _latestUpdateTime;
    NSMutableAttributedString *_showInfo;
}

@end

@implementation EaseConversationModel


- (instancetype)initWithConversation:(EMConversation *)conversation
{
    self = [super init];
    if (self) {
        _conversation = conversation;
        _showInfo = [[NSMutableAttributedString alloc] initWithString:@""];
    }
    
    return self;
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

- (void)setDraft:(NSString *)draft {
    [_conversation setDraft:draft];
}

- (BOOL)showBadgeValue {
    return ![[EaseIMKitManager shared] conversationUndisturb:_conversation.conversationId];
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
    
    EMChatMessage *msg = _conversation.latestMessage;
    _latestUpdateTime = msg.timestamp;
    NSString *msgStr = nil;
    switch (msg.body.type) {
        case EMMessageBodyTypeText:
        {
            EMTextMessageBody *body = (EMTextMessageBody *)msg.body;
            msgStr = body.text;
            EMChatMessage *lastMessage = [_conversation latestMessage];
            if ([msgStr isEqualToString:EMCOMMUNICATE_CALLER_MISSEDCALL]) {
                msgStr = EaseLocalizableString(@"noRespond", nil);
                if ([lastMessage.from isEqualToString:[EMClient sharedClient].currentUsername])
                    msgStr = EaseLocalizableString(@"canceled", nil);
            }
            if ([msgStr isEqualToString:EMCOMMUNICATE_CALLED_MISSEDCALL]) {
                msgStr = EaseLocalizableString(@"remoteCancel", nil);
                if ([lastMessage.from isEqualToString:[EMClient sharedClient].currentUsername])
                    msgStr = EaseLocalizableString(@"remoteRefuse", nil);
            }
            if (lastMessage.ext && [lastMessage.ext objectForKey:EMCOMMUNICATE_TYPE]) {
                NSString *communicateStr = @"";
                if ([[lastMessage.ext objectForKey:EMCOMMUNICATE_TYPE] isEqualToString:EMCOMMUNICATE_TYPE_VIDEO])
                    communicateStr = EaseLocalizableString(@"[videoCall]", nil);
                if ([[lastMessage.ext objectForKey:EMCOMMUNICATE_TYPE] isEqualToString:EMCOMMUNICATE_TYPE_VOICE])
                    communicateStr = EaseLocalizableString(@"[audioCall]", nil);
                msgStr = [NSString stringWithFormat:@"%@ %@", communicateStr, msgStr];
            }
        }
            break;
        case EMMessageBodyTypeLocation:
        {
            msgStr = EaseLocalizableString(@"[location]", nil);
        }
            break;
        case EMMessageBodyTypeCustom:
        {
            msgStr = EaseLocalizableString(@"[customemsg]", nil);
        }
            break;
        case EMMessageBodyTypeImage:
        {
            msgStr = EaseLocalizableString(@"[image]", nil);
        }
            break;
        case EMMessageBodyTypeFile:
        {
            msgStr = EaseLocalizableString(@"[file]", nil);
        }
            break;
        case EMMessageBodyTypeVoice:
        {
            msgStr = EaseLocalizableString(@"[audio]", nil);
        }
            break;
        case EMMessageBodyTypeVideo:
        {
            msgStr = EaseLocalizableString(@"[video]", nil);
        }
            break;
            
        default:
            break;
    }
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] init];
    if (self.hasAtMessage) {
        [result appendAttributedString:[[NSAttributedString alloc] initWithString:EaseLocalizableString(@"[someone@me]", nil) attributes:@{
            NSForegroundColorAttributeName: [UIColor colorWithRed:255/255.0 green:43/255.0 blue:43/255.0 alpha:1.0]
        }]];
    }
    [result appendAttributedString:[[NSAttributedString alloc] initWithString:msgStr]];
    _showInfo = result;
    
//    _showInfo = [[NSMutableAttributedString alloc] initWithString:msgStr];
    /*
    if ([_conversation draft] && ![[_conversation draft] isEqualToString:@""]) {
        msgStr = [NSString stringWithFormat:@"%@ %@", @"[草稿]", [_conversation draft]];
        _showInfo = [[NSMutableAttributedString alloc] initWithString:msgStr];
        [_showInfo setAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:255/255.0 green:43/255.0 blue:43/255.0 alpha:1.0]} range:NSMakeRange(0, msgStr.length)];
    }*/
    return _showInfo;
}

- (void)markAllAsRead {
    [_conversation markAllMessagesAsRead:nil];
}

- (long long)lastestUpdateTime {
    return _conversation.latestUpdateTime;
}

- (NSString*)easeId
{
    if (_userDelegate && [_userDelegate respondsToSelector:@selector(easeId)]) {
        return _userDelegate.easeId;
    }
    
    return _conversation.conversationId;
}


- (UIImage *)defaultAvatar {
    if (_userDelegate && [_userDelegate respondsToSelector:@selector(defaultAvatar)]) {
        if (_userDelegate.defaultAvatar) {
            return _userDelegate.defaultAvatar;
        }
    }
    if (self.type == EMConversationTypeChat) {
        if ([self.easeId isEqualToString:EMSYSTEMNOTIFICATIONID]) {
            return [UIImage easeUIImageNamed:@"systemNoti"];;
        }
        return [UIImage easeUIImageNamed:@"defaultAvatar"];
    }
    if (self.type == EMConversationTypeGroupChat) {
        return [UIImage easeUIImageNamed:@"groupChat"];
    }
    if (self.type == EMConversationTypeChatRoom) {
        return [UIImage easeUIImageNamed:@"chatRoom"];
    }
    return nil;
}

- (NSString *)avatarURL {
    if (_userDelegate && [_userDelegate respondsToSelector:@selector(avatarURL)]) {
        return _userDelegate.avatarURL ?: @"";
    }
    
    return nil;
}

- (NSString *)showName {
    if (_userDelegate && [_userDelegate respondsToSelector:@selector(showName)]) {
        return _userDelegate.showName;
    }
    
    if (self.type == EMConversationTypeGroupChat) {
        NSString *str = [EMGroup groupWithId:_conversation.conversationId].groupName;
        return str.length != 0 ? str : _conversation.showName;
    }
    
    if (self.type == EMConversationTypeChatRoom) {
        NSString *str = [EMChatroom chatroomWithId:_conversation.conversationId].subject;
        return str.length != 0 ? str : _conversation.showName;
    }
    
    if ([self.easeId isEqualToString:EMSYSTEMNOTIFICATIONID]) {
        return @"系统通知";
    }
    return _conversation.showName;
}

@end
