//
//  EaseConversationModel.m
//  EaseIMKit
//
//  Created by 娜塔莎 on 2020/11/10.
//

#import "EaseConversationModel.h"
#import "EaseConversationModelUtil.h"
#import "EMDefines.h"

@implementation EaseConversationModel

- (instancetype)initWithEMConversation:(EMConversation *)conversation
{
    self = [super init];
    if (self) {
        _conversationModelType = EaseConversation;
        _conversationTheme = [self getConversationTheme:conversation];
        if (!_conversationTheme)
            _conversationTheme = conversation.conversationId;
        _timestamp = conversation.latestMessage.timestamp;
        _stickTime = [self getConversationStickTime:conversation];
        _isStick = [self isConversationStick:conversation];
        
        _conversationId = conversation.conversationId;
        _conversationType = conversation.type;
        _unreadMessagesCount = conversation.unreadMessagesCount;
        _ext = conversation.ext;
        _latestMessage = conversation.latestMessage;
    }
    
    return self;
}

//更新会话列表model
- (id<EaseConversationModelDelegate>)renewalModelWithModel:(id<EaseConversationModelDelegate>)model
{
    if (model.conversationModelType != EaseConversation)
        return nil;
    EaseConversationModel *conversationModel = (EaseConversationModel *)model;
    [self renewalModelWithConversationModel:conversationModel];
    return conversationModel;
}

//更新操作
- (void)renewalModelWithConversationModel:(EaseConversationModel *)conversationModel
{
    EMConversation *conversation = [EaseConversationModelUtil getConversationWithConversationModel:conversationModel];
    conversationModel.conversationTheme = [self getConversationTheme:conversation];
    if (!conversationModel.conversationTheme)
        conversationModel.conversationTheme = conversation.conversationId;
    conversationModel.timestamp = conversation.latestMessage.timestamp;
    conversationModel.stickTime = [self getConversationStickTime:conversation];
    conversationModel.isStick = [self isConversationStick:conversation];
    
    conversationModel.unreadMessagesCount = conversation.unreadMessagesCount;
    conversationModel.ext = conversation.ext;
    conversationModel.latestMessage = conversation.latestMessage;
}

//会话主题
- (NSString *)getConversationTheme:(EMConversation*)conversation
{
    NSString *theme = nil;
    if (conversation.type == EMConversationTypeGroupChat || conversation.type == EMConversationTypeChatRoom) {
        theme = [conversation.ext objectForKey:@"subject"];
        if ([theme length] == 0 && conversation.type == EMConversationTypeGroupChat) {
            NSArray *groupArray = [[EMClient sharedClient].groupManager getJoinedGroups];
            for (EMGroup *group in groupArray) {
                if ([group.groupId isEqualToString:conversation.conversationId]) {
                    NSMutableDictionary *ext = [NSMutableDictionary dictionaryWithDictionary:conversation.ext];
                    [ext setObject:group.groupName forKey:@"subject"];
                    [ext setObject:[NSNumber numberWithBool:group.isPublic] forKey:@"isPublic"];
                    conversation.ext = ext;
                    theme = group.groupName;
                    break;
                }
            }
        }
    }
    return theme;
}

//是否置顶
- (BOOL)isConversationStick:(EMConversation*)conversation
{
    if ([conversation.ext objectForKey:CONVERSATION_STICK] && ![(NSNumber *)[conversation.ext objectForKey:CONVERSATION_STICK] isEqualToNumber:[NSNumber numberWithLong:0]]) {
        return YES;
    }
    return NO;
}

//置顶时间
- (long)getConversationStickTime:(EMConversation*)conversation
{
    long stickTime = [(NSNumber *)[conversation.ext objectForKey:CONVERSATION_STICK] longValue];
    return stickTime;
}

@end
