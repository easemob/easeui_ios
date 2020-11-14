//
//  EaseConversationModelUtil.m
//  EaseIMKit
//
//  Created by 娜塔莎 on 2020/11/10.
//

#import "EaseConversationModelUtil.h"
#import "EMMulticastDelegate.h"
#import "EaseConversationItemModel.h"

static EaseConversationModelUtil *shared = nil;
@interface EaseConversationModelUtil()

@property (nonatomic, strong) EMMulticastDelegate<EaseConversationsDelegate> *delegates;

@end

@implementation EaseConversationModelUtil

- (instancetype)init
{
    self = [super init];
    if (self) {
        _delegates = (EMMulticastDelegate<EaseConversationsDelegate> *)[[EMMulticastDelegate alloc] init];
    }
    
    return self;
}

+ (instancetype)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[EaseConversationModelUtil alloc] init];
    });
    
    return shared;
}

- (void)dealloc
{
    [self.delegates removeAllDelegates];
}

#pragma mark - Delegate

- (void)addDelegate:(id<EaseConversationsDelegate>)aDelegate
{
    [self.delegates addDelegate:aDelegate delegateQueue:dispatch_get_main_queue()];
}

- (void)removeDelegate:(id<EaseConversationsDelegate>)aDelegate
{
    [self.delegates removeDelegate:aDelegate];
}

#pragma mark - Class Methods

+ (NSArray<id<EaseConversationItemModelDelegate>> *)modelsFromEMConversations:(NSArray<EMConversation *> *)aConversations
{
    NSMutableArray *retArray = [[NSMutableArray alloc] init];

    for (int i = 0; i < [aConversations count]; i++) {
        EMConversation *conversation = aConversations[i];
        id<EaseConversationItemModelDelegate>conversationModel = [[EaseConversationItemModel alloc] initWithEMConversation:conversation];
        [retArray addObject:conversationModel];
    }
    
    return retArray;
}

+ (EMConversation *)getConversationWithConversationModel:(id<EaseConversationItemModelDelegate>)conversationModel
{
    EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:conversationModel.itemId type:conversationModel.conversationType createIfNotExist:YES];
    return conversation;
}

+ (id<EaseConversationItemModelDelegate>)modelFromContact:(NSString *)aContact
{
    EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:aContact type:EMConversationTypeChat createIfNotExist:YES];
    id<EaseConversationItemModelDelegate>model = [[EaseConversationItemModel alloc] initWithEMConversation:conversation];
    return model;
}

+ (id<EaseConversationItemModelDelegate>)modelFromGroup:(EMGroup *)aGroup
{
    EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:aGroup.groupId type:EMConversationTypeGroupChat createIfNotExist:YES];
    id<EaseConversationItemModelDelegate>model = [[EaseConversationItemModel alloc] initWithEMConversation:conversation];
    model.showName = aGroup.groupName;
    
    NSMutableDictionary *ext = [NSMutableDictionary dictionaryWithDictionary:conversation.ext];
    [ext setObject:aGroup.groupName forKey:@"subject"];
    [ext setObject:[NSNumber numberWithBool:aGroup.isPublic] forKey:@"isPublic"];
    conversation.ext = ext;
    
    return model;
}

+ (id<EaseConversationItemModelDelegate>)modelFromChatroom:(EMChatroom *)aChatroom
{
    EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:aChatroom.chatroomId type:EMConversationTypeChatRoom createIfNotExist:YES];
    id<EaseConversationItemModelDelegate>model = [[EaseConversationItemModel alloc] initWithEMConversation:conversation];
    model.showName = aChatroom.subject;
    
    NSMutableDictionary *ext = [NSMutableDictionary dictionaryWithDictionary:conversation.ext];
    [ext setObject:aChatroom.subject forKey:@"subject"];
    conversation.ext = ext;
    
    return model;
}

+ (void)markAllAsRead:(id<EaseConversationItemModelDelegate>)aConversationModel
{
    [[EaseConversationModelUtil getConversationWithConversationModel:aConversationModel] markAllMessagesAsRead:nil];
    
    EaseConversationModelUtil *helper = [EaseConversationModelUtil shared];
    [helper.delegates didConversationUnreadCountToZero:aConversationModel];
}

+ (void)resortConversationsLatestMessage
{
    EaseConversationModelUtil *helper = [EaseConversationModelUtil shared];
    [helper.delegates didResortConversationsLatestMessage];
}

@end
