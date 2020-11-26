//
//  EaseIMKitManager.m
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/10/29.
//

#import "EaseIMKitManager.h"
#import "EaseConversationsViewController.h"
#import "EaseIMKitManager+ExtFunction.h"
#import "EMMulticastDelegate.h"

static dispatch_once_t onceToken;
static EaseIMKitManager *easeIMKit = nil;
@interface EaseIMKitManager ()<EMMultiDevicesDelegate, EMContactManagerDelegate, EMGroupManagerDelegate>
@property (nonatomic, strong) EMMulticastDelegate<EaseIMKitManagerDelegate> *delegates;
@property (nonatomic, strong) NSString *currentConversationId;
@end

@implementation EaseIMKitManager

+ (instancetype)shareEaseIMKit
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (easeIMKit == nil) {
            easeIMKit = [[EaseIMKitManager alloc] init];
        }
        
    });
    return easeIMKit;
}

+ (void)destoryShared
{
    onceToken = 0;
    easeIMKit = nil;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _delegates = (EMMulticastDelegate<EaseIMKitManagerDelegate> *)[[EMMulticastDelegate alloc] init];
    }
    [[EMClient sharedClient] addMultiDevicesDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].contactManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].groupManager addDelegate:self delegateQueue:nil];
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

- (void)addDelegate:(id<EaseIMKitManagerDelegate>)aDelegate
{
    [self.delegates addDelegate:aDelegate delegateQueue:dispatch_get_main_queue()];
}

- (void)removeDelegate:(id<EaseIMKitManagerDelegate>)aDelegate
{
    [self.delegates removeDelegate:aDelegate];
}

#pragma mark - EMContactManagerDelegate

//收到好友请求
- (void)friendRequestDidReceiveFromUser:(NSString *)aUsername
                                message:(NSString *)aMessage
{
    if ([aUsername length] == 0) {
        return;
    }
    [self structureSystemNotification:aUsername userName:aUsername chatType:EMChatTypeChat reason:ContanctsRequestDidReceive];
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
    [self structureSystemNotification:aGroupId userName:aInviter chatType:EMChatTypeGroupChat reason:GroupInvitationDidReceive];
}

//收到加群申请
- (void)joinGroupRequestDidReceive:(EMGroup *)aGroup
                              user:(NSString *)aUsername
                            reason:(NSString *)aReason
{
    if ([aGroup.groupId length] == 0 || [aUsername length] == 0) {
        return;
    }
    [self structureSystemNotification:aGroup.groupId userName:aUsername chatType:EMChatTypeGroupChat reason:JoinGroupRequestDidReceive];
}

#pragma mark - private

//系统通知构造为会话
- (void)structureSystemNotification:(NSString *)conversationId userName:(NSString*)userName chatType:(EMChatType)chatType reason:(EaseIMKitCallBackReason)reason
{
    if (![self isNeedsSystemNoti]) {
        return;
    }
    NSString *notificationStr = nil;
    if (reason == ContanctsRequestDidReceive) {
        notificationStr = [NSString stringWithFormat:@"好友申请来自：%@",conversationId];
    }
    if (reason == GroupInvitationDidReceive) {
        notificationStr = [NSString stringWithFormat:@"加群邀请来自：%@",userName];
    }
    if (reason == JoinGroupRequestDidReceive) {
        notificationStr = [NSString stringWithFormat:@"加群申请来自：%@",userName];
    }
    notificationStr = [self requestDidReceiveShowMessage:conversationId requestUser:userName reason:reason];
    EMTextMessageBody *body = [[EMTextMessageBody alloc]initWithText:notificationStr];
    EMMessage *message = [[EMMessage alloc] initWithConversationID:EMSYSTEMNOTIFICATIONID from:EMSYSTEMNOTIFICATIONID to:EMClient.sharedClient.currentUsername body:body ext:nil];
    message.timestamp = [self getLatestMsgTimestamp];
    message.isRead = NO;
    message.chatType = chatType;
    EMConversation *notiConversation = [[EMClient sharedClient].chatManager getConversation:message.conversationId type:-1 createIfNotExist:YES];
    NSDictionary *ext = [self requestDidReceiveConversationExt:conversationId requestUser:userName reason:reason];
    [notiConversation setExt:ext];
    [notiConversation insertMessage:message error:nil];
    [self conversationsUnreadCount];
    //刷新会话列表
    [[NSNotificationCenter defaultCenter] postNotificationName:CONVERSATIONLIST_UPDATE object:nil];
}

//加好友，加群 成功通知
- (void)notificationMsg:(NSString *)itemId aUserName:(NSString *)aUserName conversationType:(EMConversationType)aType
{
    EMConversationType conversationType = aType;
    EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:itemId type:conversationType createIfNotExist:YES];
    EMTextMessageBody *body;
    NSString *to = itemId;
    EMMessage *message;
    if (conversationType == EMChatTypeChat) {
        body = [[EMTextMessageBody alloc] initWithText:[NSString stringWithFormat:@"你与%@已经成为好友，开始聊天吧",aUserName]];
        message = [[EMMessage alloc] initWithConversationID:to from:EMClient.sharedClient.currentUsername to:to body:body ext:@{MSG_EXT_NEWNOTI:NOTI_EXT_ADDFRIEND}];
    } else if (conversationType == EMChatTypeGroupChat) {
        if ([aUserName isEqualToString:EMClient.sharedClient.currentUsername]) {
            body = [[EMTextMessageBody alloc] initWithText:@"你已加入本群，开始发言吧"];
        } else {
            body = [[EMTextMessageBody alloc] initWithText:[NSString stringWithFormat:@"%@ 加入了群聊",aUserName]];
        }
        message = [[EMMessage alloc] initWithConversationID:to from:aUserName to:to body:body ext:@{MSG_EXT_NEWNOTI:NOTI_EXT_ADDGROUP}];
    }
    message.chatType = (EMChatType)conversation.type;
    message.isRead = YES;
    message.timestamp = [self getLatestMsgTimestamp];
    [conversation insertMessage:message error:nil];
    //刷新会话列表
    [[NSNotificationCenter defaultCenter] postNotificationName:CONVERSATIONLIST_UPDATE object:nil];
}

//最新消息时间
- (long long)getLatestMsgTimestamp
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *notiTime = [NSDate date];
    NSTimeInterval notiTimeInterval = [notiTime timeIntervalSince1970];
    return [[NSNumber numberWithDouble:notiTimeInterval] longLongValue];
}

#pragma mark - EMMultiDevicesDelegate

- (void)multiDevicesContactEventDidReceive:(EMMultiDevicesEvent)aEvent
                                  username:(NSString *)aTarget
                                       ext:(NSString *)aExt
{
    if (aEvent == EMMultiDevicesEventContactAccept || aEvent == EMMultiDevicesEventContactDecline) {
        EMConversation *systemConversation = [EMClient.sharedClient.chatManager getConversation:EMSYSTEMNOTIFICATIONID type:-1 createIfNotExist:NO];
        [systemConversation loadMessagesStartFromId:nil count:systemConversation.unreadMessagesCount searchDirection:EMMessageSearchDirectionUp completion:^(NSArray *aMessages, EMError *aError) {
            BOOL hasUnreadMsg = NO;
            for (EMMessage *message in aMessages) {
                if (message.isRead == NO && message.chatType == EMChatTypeChat) {
                    message.isRead = YES;
                    hasUnreadMsg = YES;
                }
            }
            if (hasUnreadMsg) {
                [self conversationsUnreadCount];
            }
        }];
    }
}

- (void)multiDevicesGroupEventDidReceive:(EMMultiDevicesEvent)aEvent
                                 groupId:(NSString *)aGroupId
                                     ext:(id)aExt
{
    if (aEvent == EMMultiDevicesEventGroupInviteDecline || aEvent == EMMultiDevicesEventGroupInviteAccept || aEvent == EMMultiDevicesEventGroupApplyAccept || aEvent == EMMultiDevicesEventGroupApplyDecline) {
        EMConversation *systemConversation = [EMClient.sharedClient.chatManager getConversation:EMSYSTEMNOTIFICATIONID type:-1 createIfNotExist:NO];
        [systemConversation loadMessagesStartFromId:nil count:systemConversation.unreadMessagesCount searchDirection:EMMessageSearchDirectionUp completion:^(NSArray *aMessages, EMError *aError) {
            BOOL hasUnreadMsg = NO;
            for (EMMessage *message in aMessages) {
                if (message.isRead == NO && message.chatType == EMChatTypeGroupChat) {
                    message.isRead = YES;
                    hasUnreadMsg = YES;
                }
            }
            if (hasUnreadMsg) {
                [self conversationsUnreadCount];
            }
        }];
    }
}

#pragma mark - callback
//未读总数变化
- (void)conversationsUnreadCount
{
    NSInteger unreadCount = 0;
    NSArray *conversationList = [EMClient.sharedClient.chatManager getAllConversations];
    for (EMConversation *conversation in conversationList) {
        unreadCount += conversation.unreadMessagesCount;
    }
    [self coversationsUnreadCount:unreadCount];
}

#pragma mark - 多播

//未读总数
- (void)coversationsUnreadCount:(NSInteger)unreadCount
{
    EMMulticastDelegateEnumerator *multicastDelegates = [self.delegates delegateEnumerator];
    for (EMMulticastDelegateNode *node in [multicastDelegates getDelegates]) {
        id<EaseIMKitManagerDelegate> delegate = (id<EaseIMKitManagerDelegate>)node.delegate;
        if ([delegate respondsToSelector:@selector(conversationsUnreadCountUpdate:)])
            [delegate conversationsUnreadCountUpdate:unreadCount];
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
