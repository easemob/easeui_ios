//
//  EaseIMKitManager.m
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/10/29.
//

#import "EaseIMKitManager.h"
#import "EaseConversationsViewController.h"
#import "EaseIMKitManager+ExtFunction.h"
#import "EaseMulticastDelegate.h"
#import "EaseDefines.h"
   
bool gInit;
static EaseIMKitManager *easeIMKit = nil;
static NSString *g_UIKitVersion = @"3.9.1";

@interface EaseIMKitManager ()<EMMultiDevicesDelegate, EMContactManagerDelegate, EMGroupManagerDelegate, EMChatManagerDelegate>
@property (nonatomic, strong) EaseMulticastDelegate<EaseIMKitManagerDelegate> *delegates;
@property (nonatomic, strong) NSString *currentConversationId;  //当前会话聊天id
@property (nonatomic, assign) NSInteger currentUnreadCount; //当前未读总数
@property (nonatomic, strong) dispatch_queue_t msgQueue;
@property (nonatomic, strong) NSMutableDictionary *undisturbMaps;//免打扰会话的map
@end

#define IMKitVersion @"3.9.1"

@implementation EaseIMKitManager
+ (BOOL)initWithEMOptions:(EMOptions *)options {
    if (!gInit) {
        [EMClient.sharedClient initializeSDKWithOptions:options];
        [self shareInstance];
        gInit = YES;
    }
    
    return gInit;
}

+ (EaseIMKitManager *)shared {
    return easeIMKit;
}

+ (NSString *)EaseIMKitVersion {
    return IMKitVersion;
}

+ (EaseIMKitManager *)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (easeIMKit == nil) {
            easeIMKit = [[EaseIMKitManager alloc] init];
        }
    });
    return easeIMKit;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _delegates = (EaseMulticastDelegate<EaseIMKitManagerDelegate> *)[[EaseMulticastDelegate alloc] init];
        _currentConversationId = @"";
        _msgQueue = dispatch_queue_create("easemessage.com", NULL);
    }
    [[EMClient sharedClient] addMultiDevicesDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].contactManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].groupManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    return self;
}

- (void)dealloc
{
    [self.delegates removeAllDelegates];
    [[EMClient sharedClient] removeMultiDevicesDelegate:self];
    [[EMClient sharedClient].contactManager removeDelegate:self];
    [[EMClient sharedClient].groupManager removeDelegate:self];
}

#pragma mark - Public

- (NSString *)version
{
    return g_UIKitVersion;
}

- (void)addDelegate:(id<EaseIMKitManagerDelegate>)aDelegate
{
    [self.delegates addDelegate:aDelegate delegateQueue:dispatch_get_main_queue()];
}

- (void)removeDelegate:(id<EaseIMKitManagerDelegate>)aDelegate
{
    [self.delegates removeDelegate:aDelegate];
}

#pragma mark - EMChatManageDelegate

//收到消息
- (void)messagesDidReceive:(NSArray *)aMessages
{
    [self _resetConversationsUnreadCount];
}
 
#pragma mark - EMContactManagerDelegate

//收到好友请求
- (void)friendRequestDidReceiveFromUser:(NSString *)aUsername
                                message:(NSString *)aMessage
{
    if ([aUsername length] == 0) {
        return;
    }
    [self structureSystemNotification:aUsername userName:aUsername reason:ContanctsRequestDidReceive];
}

//收到好友请求被同意/同意
- (void)friendshipDidAddByUser:(NSString *)aUsername
{
    [self notificationMsg:aUsername aUserName:aUsername conversationType:EMConversationTypeChat];
}

#pragma mark - EMGroupManagerDelegate

//群主同意用户A的入群申请后，用户A会接收到该回调
- (void)joinGroupRequestDidApprove:(EMGroup *)aGroup
{
    [self notificationMsg:aGroup.groupId aUserName:EMClient.sharedClient.currentUsername conversationType:EMConversationTypeGroupChat];
}

//有用户加入群组
- (void)userDidJoinGroup:(EMGroup *)aGroup
                    user:(NSString *)aUsername
{
    [self notificationMsg:aGroup.groupId aUserName:aUsername conversationType:EMConversationTypeGroupChat];
}

//收到群邀请
- (void)groupInvitationDidReceive:(NSString *)aGroupId
                          inviter:(NSString *)aInviter
                          message:(NSString *)aMessage
{
    if ([aGroupId length] == 0 || [aInviter length] == 0) {
        return;
    }
    [self structureSystemNotification:aGroupId userName:aInviter reason:GroupInvitationDidReceive];
}

//收到加群申请
- (void)joinGroupRequestDidReceive:(EMGroup *)aGroup
                              user:(NSString *)aUsername
                            reason:(NSString *)aReason
{
    if ([aGroup.groupId length] == 0 || [aUsername length] == 0) {
        return;
    }
    [self structureSystemNotification:aGroup.groupId userName:aUsername reason:JoinGroupRequestDidReceive];
}

#pragma mark - private

//系统通知构造为会话
- (void)structureSystemNotification:(NSString *)conversationId userName:(NSString*)userName reason:(EaseIMKitCallBackReason)reason
{
    if (![self isNeedsSystemNoti]) {
        return;
    }
    NSString *notificationStr = nil;
    NSString *notiType = nil;
    if (reason == ContanctsRequestDidReceive) {
        notificationStr = [NSString stringWithFormat:EaseLocalizableString(@"friendApplyfrom", nil),conversationId];
        notiType = SYSTEM_NOTI_TYPE_CONTANCTSREQUEST;
    }
    if (reason == GroupInvitationDidReceive) {
        notificationStr = [NSString stringWithFormat:EaseLocalizableString(@"joinInvitefrom", nil),userName];
        notiType = SYSTEM_NOTI_TYPE_GROUPINVITATION;
    }
    if (reason == JoinGroupRequestDidReceive) {
        notificationStr = [NSString stringWithFormat:EaseLocalizableString(@"joinApplyfrom", nil),userName];
        notiType = SYSTEM_NOTI_TYPE_JOINGROUPREQUEST;
    }
    if (self.systemNotiDelegate && [self.systemNotiDelegate respondsToSelector:@selector(requestDidReceiveShowMessage:requestUser:reason:)]) {
        NSString *tempStr = [self.systemNotiDelegate requestDidReceiveShowMessage:conversationId requestUser:userName reason:reason];
        // 空字符串返回不做操作 / nil：默认操作 / 有自定义值其他长度值使用自定义值
        if (tempStr) {
            if ([tempStr isEqualToString:@""]) {
                return;
            } else if (tempStr.length > 0) {
                notificationStr = tempStr;
            }
        }
    }
    EMTextMessageBody *body = [[EMTextMessageBody alloc]initWithText:notificationStr];
    EMChatMessage *message = [[EMChatMessage alloc] initWithConversationID:EMSYSTEMNOTIFICATIONID from:userName to:EMClient.sharedClient.currentUsername body:body ext:nil];
    message.timestamp = [self getLatestMsgTimestamp];
    message.isRead = NO;
    message.chatType = EMChatTypeChat;
    message.direction = EMMessageDirectionReceive;
    EMConversation *notiConversation = [[EMClient sharedClient].chatManager getConversation:message.conversationId type:EMConversationTypeChat createIfNotExist:YES];
    NSDictionary *ext = nil;
    if (self.systemNotiDelegate && [self.systemNotiDelegate respondsToSelector:@selector(requestDidReceiveConversationExt:requestUser:reason:)]) {
        ext = [self.systemNotiDelegate requestDidReceiveConversationExt:conversationId requestUser:userName reason:reason];
    } else {
        ext = @{SYSTEM_NOTI_TYPE:notiType};
    }
    [notiConversation setExt:ext];
    [notiConversation insertMessage:message error:nil];
    [self _resetConversationsUnreadCount];
    //刷新会话列表
    [[NSNotificationCenter defaultCenter] postNotificationName:CONVERSATIONLIST_UPDATE object:nil];
}

//加好友，加群 成功通知
- (void)notificationMsg:(NSString *)itemId aUserName:(NSString *)aUserName conversationType:(EMConversationType)aType
{
    return;
    EMConversationType conversationType = aType;
    EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:itemId type:conversationType createIfNotExist:YES];
    EMTextMessageBody *body;
    NSString *to = itemId;
    EMChatMessage *message;
    if (conversationType == EMChatTypeChat) {
        body = [[EMTextMessageBody alloc] initWithText:[NSString stringWithFormat:EaseLocalizableString(@"friended", nil),aUserName]];
        message = [[EMChatMessage alloc] initWithConversationID:to from:EMClient.sharedClient.currentUsername to:to body:body ext:@{MSG_EXT_NEWNOTI:NOTI_EXT_ADDFRIEND}];
    } else if (conversationType == EMChatTypeGroupChat) {
        if ([aUserName isEqualToString:EMClient.sharedClient.currentUsername]) {
            body = [[EMTextMessageBody alloc] initWithText:EaseLocalizableString(@"joinedgroup", nil)];
        } else {
            body = [[EMTextMessageBody alloc] initWithText:[NSString stringWithFormat:EaseLocalizableString(@"userjoinGroup", nil),aUserName]];
        }
        message = [[EMChatMessage alloc] initWithConversationID:to from:aUserName to:to body:body ext:@{MSG_EXT_NEWNOTI:NOTI_EXT_ADDGROUP}];
    }
    message.chatType = (EMChatType)conversation.type;
    message.isRead = YES;
    [conversation insertMessage:message error:nil];
    //刷新会话列表
    [[NSNotificationCenter defaultCenter] postNotificationName:CONVERSATIONLIST_UPDATE object:nil];
}

//最新消息时间
- (long long)getLatestMsgTimestamp
{
    return [[NSDate new] timeIntervalSince1970] * 1000;
}

#pragma mark - EMMultiDevicesDelegate

- (void)multiDevicesContactEventDidReceive:(EMMultiDevicesEvent)aEvent
                                  username:(NSString *)aTarget
                                       ext:(NSString *)aExt
{
    __weak typeof(self) weakself = self;
    if (aEvent == EMMultiDevicesEventContactAccept || aEvent == EMMultiDevicesEventContactDecline) {
        EMConversation *systemConversation = [EMClient.sharedClient.chatManager getConversation:EMSYSTEMNOTIFICATIONID type:-1 createIfNotExist:NO];
        [systemConversation loadMessagesStartFromId:nil count:systemConversation.unreadMessagesCount searchDirection:EMMessageSearchDirectionUp completion:^(NSArray *aMessages, EMError *aError) {
            BOOL hasUnreadMsg = NO;
            for (EMChatMessage *message in aMessages) {
                if (message.isRead == NO && message.chatType == EMChatTypeChat) {
                    message.isRead = YES;
                    hasUnreadMsg = YES;
                }
            }
            if (hasUnreadMsg) {
                [weakself _resetConversationsUnreadCount];
            }
        }];
    }
}

- (void)multiDevicesGroupEventDidReceive:(EMMultiDevicesEvent)aEvent
                                 groupId:(NSString *)aGroupId
                                     ext:(id)aExt
{
    __weak typeof(self) weakself = self;
    if (aEvent == EMMultiDevicesEventGroupInviteDecline || aEvent == EMMultiDevicesEventGroupInviteAccept || aEvent == EMMultiDevicesEventGroupApplyAccept || aEvent == EMMultiDevicesEventGroupApplyDecline) {
        EMConversation *systemConversation = [EMClient.sharedClient.chatManager getConversation:EMSYSTEMNOTIFICATIONID type:-1 createIfNotExist:NO];
        [systemConversation loadMessagesStartFromId:nil count:systemConversation.unreadMessagesCount searchDirection:EMMessageSearchDirectionUp completion:^(NSArray *aMessages, EMError *aError) {
            BOOL hasUnreadMsg = NO;
            for (EMChatMessage *message in aMessages) {
                if (message.isRead == NO && message.chatType == EMChatTypeGroupChat) {
                    message.isRead = YES;
                    hasUnreadMsg = YES;
                }
            }
            if (hasUnreadMsg) {
                [weakself _resetConversationsUnreadCount];
            }
        }];
    }
}

#pragma mark - 未读数变化

- (BOOL)conversationUndisturb:(NSString *)conversationId {
    if (conversationId == nil) { return NO; }
    return [[_undisturbMaps valueForKey:conversationId] boolValue];
}

- (void)updateUndisturbMapsKey:(NSString *)key value:(BOOL )value {
    if (_undisturbMaps == nil) {
        _undisturbMaps = [NSMutableDictionary dictionary];
        [self fillUndisturbMaps];
    }
    [_undisturbMaps setValue:[NSNumber numberWithBool:value] forKey:key];
}

- (void)cleanMemoryUndisturbMaps {
    _undisturbMaps = nil;
}

- (void)fillUndisturbMaps {
    for (EMConversation *conversation in [EMClient.sharedClient.chatManager getAllConversations]) {
        
        if ([[[EMClient sharedClient].pushManager noPushUIds] containsObject:conversation.conversationId]) {
            if ([_undisturbMaps valueForKey:conversation.conversationId] == nil) {
                [_undisturbMaps setValue:[NSNumber numberWithBool:YES] forKey:conversation.conversationId];
            }
        }
        if ([[[EMClient sharedClient].pushManager noPushGroups] containsObject:conversation.conversationId]) {
            if ([_undisturbMaps valueForKey:conversation.conversationId] == nil) {
                [_undisturbMaps setValue:[NSNumber numberWithBool:YES] forKey:conversation.conversationId];
            }
        }
    }
}

//会话所有信息标记已读
- (void)markAllMessagesAsReadWithConversation:(EMConversation *)conversation
{
    if (conversation && conversation.unreadMessagesCount > 0) {
        [conversation markAllMessagesAsRead:nil];
        [self _resetConversationsUnreadCount];
    }
}

//未读总数变化
- (void)_resetConversationsUnreadCount
{
    NSInteger unreadCount = 0,undisturbCount = 0;
    NSArray *conversationList = [EMClient.sharedClient.chatManager getAllConversations];
    for (EMConversation *conversation in conversationList) {
        if ([conversation.conversationId isEqualToString:_currentConversationId]) {
            continue;
        }
        if ([[[EMClient sharedClient].pushManager noPushUIds] containsObject:conversation.conversationId]) {
            undisturbCount += conversation.unreadMessagesCount;
            [_undisturbMaps setValue:[NSNumber numberWithBool:YES] forKey:conversation.conversationId];
            continue;
        }
        if ([[[EMClient sharedClient].pushManager noPushGroups] containsObject:conversation.conversationId]) {
            undisturbCount += conversation.unreadMessagesCount;
            [_undisturbMaps setValue:[NSNumber numberWithBool:YES] forKey:conversation.conversationId];
            continue;
        }
        unreadCount += conversation.unreadMessagesCount;
    }
    _currentUnreadCount = unreadCount;
    [self coversationsUnreadCountUpdate:unreadCount undisturbCount:undisturbCount];
}

#pragma mark - 多播

//未读总数多播总数法
- (void)coversationsUnreadCountUpdate:(NSInteger)unreadCount undisturbCount:(NSInteger)undisturbCount
{
    EaseMulticastDelegateEnumerator *multicastDelegates = [self.delegates delegateEnumerator];
    for (EaseMulticastDelegateNode *node in [multicastDelegates getDelegates]) {
        id<EaseIMKitManagerDelegate> delegate = (id<EaseIMKitManagerDelegate>)node.delegate;
        if (delegate&&[delegate respondsToSelector:@selector(conversationsUnreadCountUpdate:)])
            [delegate conversationsUnreadCountUpdate:unreadCount];
        if (delegate&&[delegate respondsToSelector:@selector(conversationsUnreadCountUpdate:undisturbCount:)]) {
            [delegate conversationsUnreadCountUpdate:unreadCount undisturbCount:undisturbCount];
        }
    }
}

#pragma mark - 系统通知

//是否需要系统通知
- (BOOL)isNeedsSystemNoti
{
    if (self.systemNotiDelegate && [self.systemNotiDelegate respondsToSelector:@selector(isNeedsSystemNotification)]) {
        return [self.systemNotiDelegate isNeedsSystemNotification];
    }
    return YES;
}

//收到请求返回展示信息
- (NSString*)requestDidReceiveShowMessage:(NSString *)conversationId requestUser:(NSString *)requestUser reason:(EaseIMKitCallBackReason)reason
{
    if (self.systemNotiDelegate && [self.systemNotiDelegate respondsToSelector:@selector(requestDidReceiveShowMessage:requestUser:reason:)]) {
        return [self.systemNotiDelegate requestDidReceiveShowMessage:conversationId requestUser:requestUser reason:reason];
    }
    return @"";
}

//收到请求返回扩展信息
- (NSDictionary *)requestDidReceiveConversationExt:(NSString *)conversationId requestUser:(NSString *)requestUser reason:(EaseIMKitCallBackReason)reason
{
    if (self.systemNotiDelegate && [self.systemNotiDelegate respondsToSelector:@selector(requestDidReceiveConversationExt:requestUser:reason:)]) {
        return [self.systemNotiDelegate requestDidReceiveConversationExt:conversationId requestUser:requestUser reason:reason];
    }
    return [[NSDictionary alloc]init];
}

@end

@implementation EaseIMKitManager (currentUnreadCount)

- (void)setConversationId:(NSString *)conversationId
{
    _currentConversationId = conversationId;
}

@end
