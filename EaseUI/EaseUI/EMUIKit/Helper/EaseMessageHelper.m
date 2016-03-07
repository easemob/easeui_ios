//
//  EaseMessageHelper.m
//  EaseUI
//
//  Created by WYZ on 16/2/16.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EaseMessageHelper.h"
#import "EaseMessageHelper+Revoke.h"
#import "EaseMessageHelper+RemoveAfterRead.h"
#import "EaseMessageHelper+GroupAt.h"
#import "EaseMessageHelper+InputState.h"

@interface EaseMessageHelper()

@end

@implementation EaseMessageHelper

+ (EaseMessageHelper *)sharedInstance
{
    static EaseMessageHelper *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[EaseMessageHelper alloc] init];
    });
    
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _queue = dispatch_queue_create("com.EaseMessageHelper", DISPATCH_QUEUE_SERIAL);
        [self.chatManager addDelegate:self delegateQueue:nil];
        _emHelperType = emHelperTypeDefault;
    }
    return self;
}

- (void)dealloc
{
    [self.chatManager removeDelegate:self];
    self.chatManager = nil;
}

#pragma mark - getter

- (NSString *)account
{
    return [EMClient sharedClient].currentUsername;
}

- (id<IEMChatManager>)chatManager
{
    return [EMClient sharedClient].chatManager;
}

#pragma mark - public

+ (NSDictionary *)structureEaseMessageHelperExt:(NSDictionary *)ext
                                       bodyType:(EMMessageBodyType)bodyType
{
    NSDictionary *_ext = [ext mutableCopy];
    switch ([EaseMessageHelper sharedInstance].emHelperType)
    {
        case emHelperTypeRemoveAfterRead:
            _ext = [[EaseMessageHelper structureRemoveAfterReadMessageExt:ext] mutableCopy];
            break;
        case emHelperTypeGroupAt:
        {
            if (bodyType == EMMessageBodyTypeText) {
                _ext = [[EaseMessageHelper structureGroupAtMessageExt:ext] mutableCopy];
            }
        }
            break;
        default:
            break;
    }
    return _ext;
}


- (void)addDelegate:(id<EaseMessageHelperProtocal>)delegate
{
    [multicastDelegate addDelegate:delegate delegateQueue:dispatch_get_main_queue()];
}

- (void)removeDelegate:(id<EaseMessageHelperProtocal>)delegate
{
    [multicastDelegate removeDelegate:delegate delegateQueue:dispatch_get_main_queue()];
}

+ (EMHelperType)checkMessage:(EMMessage *)message
{
    EMHelperType type = emHelperTypeDefault;
    if ([EaseMessageHelper isRemoveAfterReadMessage:message])
    {
        type = emHelperTypeRemoveAfterRead;
    }
    else if ([EaseMessageHelper isRevokeCMDMessage:message])
    {
        type = emHelperTypeRevoke;
    }
    else if ([EaseMessageHelper isGroupAtMessage:message])
    {
        type = emHelperTypeGroupAt;
    }
    else if ([EaseMessageHelper isInputCMDMessage:message])
    {
        type = emHelperTypeInputState;
    }
    return type;
}

#pragma mark - private

#pragma mark - EMChatManagerDelegate
//当categray中涉及到的回调重复需要提到此处统一处理，以防被重写

- (void)didReceiveMessages:(NSArray *)aMessages
{
    NSMutableArray *groupAtMsgs = nil;
    for (EMMessage *message in aMessages) {
        if ([EaseMessageHelper isGroupAtMessage:message])
        {
            if (!groupAtMsgs) {
                groupAtMsgs = [NSMutableArray array];
            }
            [groupAtMsgs addObject:message];
        }
    }
    if (groupAtMsgs) {
        //按时间降幂排列
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO];
        NSArray *results = [groupAtMsgs sortedArrayUsingDescriptors:@[sortDescriptor]];
        [multicastDelegate emHelper:self handleGroupAtMessage:results];
    }
    if ([EaseMessageHelper inputStateIsValid]) {
        [multicastDelegate emHelper:self handleInputStateMessage:nil];
    }
}

- (void)didReceiveCmdMessages:(NSArray *)aCmdMessages
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(_queue, ^{
        NSMutableArray *needRevokeMessages = nil;
        NSString *conversationTitle = nil; //存放最后一个
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
        NSArray *cmdMessages = [aCmdMessages sortedArrayUsingDescriptors:@[sortDescriptor]];
        for (EMMessage *cmdMessage in cmdMessages)
        {
            switch ([EaseMessageHelper checkMessage:cmdMessage])
            {
                case emHelperTypeRevoke:
                {
                    EMMessage *message = [weakSelf handleReceiveRevokeCmdMessage:cmdMessage];
                    if (message) {
                        if (!needRevokeMessages) {
                            needRevokeMessages = [NSMutableArray array];
                        }
                        [needRevokeMessages addObject:message];
                    }
                }
                    break;
                case emHelperTypeInputState:
                {
                    conversationTitle = [weakSelf handleReceiveInputStateCmdMessage:cmdMessage];
                }
                    break;
                default:
                    break;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (needRevokeMessages) {
                [multicastDelegate emHelper:weakSelf handleRevokeMessage:needRevokeMessages];
            }
            [multicastDelegate emHelper:weakSelf handleInputStateMessage:conversationTitle];
            if (conversationTitle) {
                //返回会话标题，则说明正在输入，接收方开启定时
                [weakSelf startRunLoopByReceiver];
            }
        });
    });
}

@end
