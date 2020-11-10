//
//  EMConversationHelper.m
//  EaseUIKit
//
//  Created by XieYajie on 2019/1/14.
//  Update © 2020 zhangchong. All rights reserved.
//

#import "EMConversationHelper.h"
#import "EMMulticastDelegate.h"
#import "EaseConversationStickController.h"

@implementation EMConversationModel

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
    EMConversationModel *conversationModel = (EMConversationModel *)model;
    [self renewalModelWithConversationModel:conversationModel];
    return conversationModel;
}

//更新操作
- (void)renewalModelWithConversationModel:(EMConversationModel *)conversationModel
{
    EMConversation *conversation = [EMConversationHelper getConversationWithConversationModel:conversationModel];
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

@implementation EMSystemNotificationModel

- (instancetype)initNotificationModel
{
    self = [super init];
    if (self) {
        _conversationTheme = @"系统通知";
        _conversationModelType = EaseSystemNotification;
        EMNotificationModel* notifcationModel = [EMNotificationHelper.shared.notificationList objectAtIndex:0];
        _latestNotificTime = notifcationModel.time;
        _stickTime = [self getNotificationStickTime];
        _timestamp = [self getLatestNotificTimestamp:notifcationModel.time];
        _isStick = [self isNotificationStick];
        _notificationSender = notifcationModel.sender;
        _notificationType = notifcationModel.type;
    }
    
    return self;
}

//更新系统通知model
- (id<EaseConversationModelDelegate>)renewalModelWithModel:(id<EaseConversationModelDelegate>)model
{
    if (model.conversationModelType != EaseSystemNotification)
        return nil;
    EMSystemNotificationModel* notificModel = (EMSystemNotificationModel*)model;
    [self renewalNotificationModel:notificModel];
    return notificModel;
}

//更新
- (void)renewalNotificationModel:(EMSystemNotificationModel*)notificModel{
    EMNotificationModel* notifcationModel = [EMNotificationHelper.shared.notificationList objectAtIndex:0];
    notificModel.latestNotificTime = notifcationModel.time;
    notificModel.stickTime = [self getNotificationStickTime];
    notificModel.timestamp = [self getLatestNotificTimestamp:notifcationModel.time];
    notificModel.isStick = [self isNotificationStick];
    notificModel.notificationSender = notifcationModel.sender;
    notificModel.notificationType = notifcationModel.type;
}

- (long long)getLatestNotificTimestamp:(NSString*)timestamp
{
    //最后一个系统通知信息时间
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *notiTime = [dateFormatter dateFromString:timestamp];
    NSTimeInterval notiTimeInterval = [notiTime timeIntervalSince1970];
    return [[NSNumber numberWithDouble:notiTimeInterval] longLongValue];
}

//是否置顶
- (BOOL)isNotificationStick
{
    EMNotificationModel* notifcationModel = [EMNotificationHelper.shared.notificationList objectAtIndex:0];
    if (notifcationModel.stickTime && ![notifcationModel.stickTime isEqualToNumber:[NSNumber numberWithLong:0]])
        return YES;
    return NO;
}

//置顶时间
- (long)getNotificationStickTime
{
    EMNotificationModel* notifcationModel = [EMNotificationHelper.shared.notificationList objectAtIndex:0];
    long stickTime = [notifcationModel.stickTime longValue];
    return stickTime;
}

@end


static EMConversationHelper *shared = nil;
@interface EMConversationHelper()

@property (nonatomic, strong) EMMulticastDelegate<EMConversationsDelegate> *delegates;

@end

@implementation EMConversationHelper

- (instancetype)init
{
    self = [super init];
    if (self) {
        _delegates = (EMMulticastDelegate<EMConversationsDelegate> *)[[EMMulticastDelegate alloc] init];
    }
    
    return self;
}

+ (instancetype)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[EMConversationHelper alloc] init];
    });
    
    return shared;
}

- (void)dealloc
{
    [self.delegates removeAllDelegates];
}

#pragma mark - Delegate

- (void)addDelegate:(id<EMConversationsDelegate>)aDelegate
{
    [self.delegates addDelegate:aDelegate delegateQueue:dispatch_get_main_queue()];
}

- (void)removeDelegate:(id<EMConversationsDelegate>)aDelegate
{
    [self.delegates removeDelegate:aDelegate];
}

#pragma mark - Class Methods

+ (NSArray<EMConversationModel *> *)modelsFromEMConversations:(NSArray<EMConversation *> *)aConversations
{
    NSMutableArray *retArray = [[NSMutableArray alloc] init];

    for (int i = 0; i < [aConversations count]; i++) {
        EMConversation *conversation = aConversations[i];
        id<EaseConversationModelDelegate> conversationModel = [[EMConversationModel alloc] initWithEMConversation:conversation];
        [retArray addObject:conversationModel];
    }
    
    return retArray;
}

+ (EMConversation *)getConversationWithConversationModel:(EMConversationModel *)conversationModel
{
    EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:conversationModel.conversationId type:conversationModel.conversationType createIfNotExist:YES];
    return conversation;
}

+ (EMConversationModel *)modelFromContact:(NSString *)aContact
{
    EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:aContact type:EMConversationTypeChat createIfNotExist:YES];
    EMConversationModel *model = [[EMConversationModel alloc] initWithEMConversation:conversation];
    return model;
}

+ (EMConversationModel *)modelFromGroup:(EMGroup *)aGroup
{
    EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:aGroup.groupId type:EMConversationTypeGroupChat createIfNotExist:YES];
    EMConversationModel *model = [[EMConversationModel alloc] initWithEMConversation:conversation];
    model.conversationTheme = aGroup.groupName;
    
    NSMutableDictionary *ext = [NSMutableDictionary dictionaryWithDictionary:conversation.ext];
    [ext setObject:aGroup.groupName forKey:@"subject"];
    [ext setObject:[NSNumber numberWithBool:aGroup.isPublic] forKey:@"isPublic"];
    conversation.ext = ext;
    
    return model;
}

+ (EMConversationModel *)modelFromChatroom:(EMChatroom *)aChatroom
{
    EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:aChatroom.chatroomId type:EMConversationTypeChatRoom createIfNotExist:YES];
    EMConversationModel *model = [[EMConversationModel alloc] initWithEMConversation:conversation];
    model.conversationTheme = aChatroom.subject;
    
    NSMutableDictionary *ext = [NSMutableDictionary dictionaryWithDictionary:conversation.ext];
    [ext setObject:aChatroom.subject forKey:@"subject"];
    conversation.ext = ext;
    
    return model;
}

+ (void)markAllAsRead:(EMConversationModel *)aConversationModel
{
    [[EMConversationHelper getConversationWithConversationModel:aConversationModel] markAllMessagesAsRead:nil];
    
    EMConversationHelper *helper = [EMConversationHelper shared];
    [helper.delegates didConversationUnreadCountToZero:aConversationModel];
}

+ (void)resortConversationsLatestMessage
{
    EMConversationHelper *helper = [EMConversationHelper shared];
    [helper.delegates didResortConversationsLatestMessage];
}

@end
