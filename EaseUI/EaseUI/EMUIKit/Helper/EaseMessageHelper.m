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
    return [[[EaseMob sharedInstance].chatManager loginInfo] objectForKey:kSDKUsername];
}

- (id<IChatManager>)chatManager
{
    return [EaseMob sharedInstance].chatManager;
}

#pragma mark - public

+ (NSDictionary *)structureEaseMessageHelperExt:(NSDictionary *)ext
                                       bodyType:(MessageBodyType)bodyType
{
    NSDictionary *_ext = [ext mutableCopy];
    switch ([EaseMessageHelper sharedInstance].emHelperType)
    {
        case emHelperTypeRemoveAfterRead:
            _ext = [[EaseMessageHelper structureRemoveAfterReadMessageExt:ext] mutableCopy];
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
    return type;
}

#pragma mark - private
//处理cmd接收消息
- (NSObject *)handleReceivedCmdMessage:(EMMessage *)cmdMessage type:(EMHelperType)type
{
    NSObject *obj = nil;
    switch (type)
    {
        case emHelperTypeRevoke:
            obj = [self handleReceivedRevokeCmdMessage:cmdMessage];
            break;
        default:
            break;
    }
    return obj;
}

#pragma mark - IChatManagerDelegate
//当categray中涉及到的回调重复需要提到此处统一处理，以防被重写

- (void)didReceiveCmdMessage:(EMMessage *)cmdMessage
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(_queue, ^{
        EMHelperType type = [EaseMessageHelper checkMessage:cmdMessage];
        NSObject *obj = [weakSelf handleReceivedCmdMessage:cmdMessage type:type];
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (type)
            {
                case emHelperTypeRevoke:
                {
                    NSArray *results = nil;
                    if (obj && [obj isKindOfClass:[EMMessage class]]){
                        results = @[obj];
                    }
                    [multicastDelegate emHelper:weakSelf handleRevokeMessage:results];
                }
                    break;
                default:
                    break;
            }
        });
    });
}

- (void)didReceiveOfflineCmdMessages:(NSArray *)offlineCmdMessages
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(_queue, ^{
        NSMutableArray *revokeResults;
        for (EMMessage *cmdMessage in offlineCmdMessages)
        {
            EMHelperType type = [EaseMessageHelper checkMessage:cmdMessage];
            if (type != emHelperTypeRevoke)
            {//离线cmd，除了消息回撤cmd消息，其他不作处理
                continue;
            }
            NSObject *obj = [weakSelf handleReceivedCmdMessage:cmdMessage type:type];
            if (!obj) {
                continue;
            }
            if (!revokeResults)
            {
                revokeResults = [NSMutableArray array];
            }
            [revokeResults addObject:obj];
        }
        if (revokeResults)
        {
            [multicastDelegate emHelper:weakSelf handleRevokeMessage:revokeResults];
        }
    });
}

- (void)didReceiveMessage:(EMMessage *)message
{
    
}

- (void)didReceiveOfflineMessages:(NSArray *)offlineMessages
{
    
}


@end
