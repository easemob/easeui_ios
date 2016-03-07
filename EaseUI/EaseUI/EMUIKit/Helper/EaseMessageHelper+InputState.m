//
//  EaseMessageHelper+InputState.m
//  EaseUI
//
//  Created by WYZ on 16/2/16.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EaseMessageHelper+InputState.h"
#import <objc/runtime.h>

/** @brief 待发送输入状态的CMD消息action */
#define KEM_INPUTSTATE_CMDACTION                   @"em_inputState_cmdAction"
/** @brief 输入状态cmd扩展字段,对应的value值为待撤销消息id */
#define KEM_INPUTSTATE_STATE        @"em_inputState_state"
/** @brief 校验输入状态cmd发送时间间隔 */
#define KEM_INPUTSTATE_TIMEINTERVAL  5
/** @brief 输入状态cmd接收方聊天页面title */
#define KEM_INPUTSTATE_TITLE  @"对方正在输入..."

static char inputStateValidKey;
static char inputStateTimerKey;
static char inputStateRunLoopKey;
static char inputStateLatestTimestampKey;

@interface EaseMessageHelper()

@property (nonatomic, strong) NSNumber *isValid;  //对应为BOOL

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) NSRunLoop *runLoop;

@property (nonatomic, strong) NSNumber *latestTimestamp;//发送方使用，用于cmd消息发送时间间隔

@end

@implementation EaseMessageHelper (InputState)

#pragma mark - getter

- (NSNumber *)isValid
{
    return objc_getAssociatedObject(self, &inputStateValidKey);
}

- (NSTimer *)timer
{
    return objc_getAssociatedObject(self, &inputStateTimerKey);
}

- (NSRunLoop *)runLoop
{
    return objc_getAssociatedObject(self, &inputStateRunLoopKey);
}

- (NSNumber *)latestTimestamp
{
    return objc_getAssociatedObject(self, &inputStateLatestTimestampKey);
}

#pragma mark - setter

- (void)setIsValid:(NSNumber *)isValid
{
    objc_setAssociatedObject(self, &inputStateValidKey, isValid, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setTimer:(NSTimer *)timer
{
    objc_setAssociatedObject(self, &inputStateTimerKey, timer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setRunLoop:(NSRunLoop *)runLoop
{
    objc_setAssociatedObject(self, &inputStateRunLoopKey, runLoop, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setLatestTimestamp:(NSNumber *)latestTimestamp
{
    objc_setAssociatedObject(self, &inputStateLatestTimestampKey, latestTimestamp, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - public

/**
 * 验证cmd消息是否含有输入状态提示功能
 *
 * @param model 待验证消息
 * @return 判断结果, YES代表消息含有输入状态提示功能
 */
+ (BOOL)isInputCMDMessage:(EMMessage *)message
{
    if (![EaseMessageHelper inputStateIsValid]) {
        return NO;
    }
    if (!message.body || ![message.body isKindOfClass:[EMCmdMessageBody class]]) {
        return NO;
    }
    EMCmdMessageBody *body = (EMCmdMessageBody *)message.body;
    return [body.action isEqualToString:KEM_INPUTSTATE_CMDACTION];
}

/**
 * 重置输入状态cmd消息的发送时间(前提会话为单聊)
 *
 * @param conversationType 会话类型
 */
+ (void)resetInputStateCmdMessageSendTime:(EMConversationType)conversationType
{
    if (conversationType == EMConversationTypeChat &&
        [EaseMessageHelper inputStateIsValid]) {
        [[EaseMessageHelper sharedInstance] setLatestTimestamp:nil];
    }
}

//验证消息发送方，输入状态cmd是否符合发送规律，符合则发送cmd，不符合跳出
+ (void)canSendInputCmdMsgToChatter:(NSString *)chatter status:(BOOL)isInput
{
    //输入提示未开启，或 未连接，不发送
    if (![EaseMessageHelper inputStateIsValid] ||
        ![[EMClient sharedClient] isConnected])
    {
        return;
    }
    BOOL isCanSend = NO;
    NSNumber *latestTimestamp = [EaseMessageHelper sharedInstance].latestTimestamp;
    if (isInput)
    {
        NSDate *currentDate = [NSDate date];
        long long currentTimestamp = (long long)[currentDate timeIntervalSince1970];
        
        if (!latestTimestamp ||
            currentTimestamp - latestTimestamp.longLongValue >= KEM_INPUTSTATE_TIMEINTERVAL)
        {
            latestTimestamp = [NSNumber numberWithLongLong:currentTimestamp];
            isCanSend = YES;
        }
    }
    else {
        latestTimestamp = nil;
        isCanSend = YES;
    }
    if (isCanSend)
    {
        //可以发送cmd消息
        [EaseMessageHelper sendInputStateCmdMessage:chatter status:isInput];
        [[EaseMessageHelper sharedInstance] setLatestTimestamp:latestTimestamp];
    }
}

/**
 * 处理接收的输入状态cmd消息
 *
 * @param cmdMessage 待处理cmd消息
 */
- (NSString *)handleReceiveInputStateCmdMessage:(EMMessage *)cmdMessage
{
    NSString *conversationTitle = nil;
    if (![EaseMessageHelper isInputCMDMessage:cmdMessage])
    {
        return conversationTitle;
    }
    if ([cmdMessage.ext[KEM_INPUTSTATE_STATE] boolValue])
    {
        conversationTitle = KEM_INPUTSTATE_TITLE;
    }
    return conversationTitle;
}

//接收者开启runloop计时
- (void)startRunLoopByReceiver
{
    [self startRunLoop:@selector(handleTimerAction:) target:self];
}

/**
 * 开启输入状态提示功能
 *
 */
+ (void)openInputState
{
    [EaseMessageHelper sharedInstance].isValid = [NSNumber numberWithBool:YES];
    [EaseMessageHelper sharedInstance].latestTimestamp = nil;
}

/**
 * 关闭输入状态提示功能
 *
 */
+ (void)closeInputState
{
    [EaseMessageHelper sharedInstance].isValid = [NSNumber numberWithBool:NO];
    [EaseMessageHelper sharedInstance].latestTimestamp = nil;
    [[EaseMessageHelper sharedInstance] stopRunLoop];
}

/**
 * 输入状态提示功能是否可用
 *
 * @return 判断结果, YES代表输入状态提示功能可用
 */
+ (BOOL)inputStateIsValid
{
    BOOL isvalid = [[EaseMessageHelper sharedInstance].isValid boolValue];
    return isvalid;
}

#pragma mark - private

/**
 * 发送输入状态提示cmd消息
 *
 * @param aChatter 会话chatter
 * @param isInput 输入状态
 */
+ (void)sendInputStateCmdMessage:(NSString *)aChatter status:(BOOL)isInput
{
    EMCmdMessageBody *cmdBody = [[EMCmdMessageBody alloc] initWithAction:KEM_INPUTSTATE_CMDACTION];
    NSString *currentUsername = [EMClient sharedClient].currentUsername;
    NSDictionary *ext = @{KEM_INPUTSTATE_STATE:[NSNumber numberWithBool:isInput]};
    EMMessage *message = [[EMMessage alloc] initWithConversationID:aChatter from:currentUsername to:aChatter body:cmdBody ext:ext];
    message.chatType = EMChatTypeChat;
    [[EaseMessageHelper sharedInstance].chatManager asyncSendMessage:message progress:nil completion:^(EMMessage *message, EMError *error) {
        
    }];
}

//接收方，启动runloop
- (void)startRunLoop:(SEL)runAction target:(id)target
{
    [self stopRunLoop];
    if (![EaseMessageHelper inputStateIsValid])
    {
        return;
    }
    if (!self.runLoop)
    {
        self.runLoop = [[NSRunLoop alloc] init];
    }
    
    if (!self.timer)
    {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:KEM_INPUTSTATE_TIMEINTERVAL target:target selector:runAction userInfo:nil repeats:NO];
    }
    [self.runLoop addTimer:self.timer forMode:NSRunLoopCommonModes];
    [self.runLoop run];
}

//关闭runloop
- (void)stopRunLoop
{
    if (self.timer.isValid)
    {
        [self.timer invalidate];
        self.timer = nil;
        self.runLoop = nil;
    }
}

//定时处理方法
- (void)handleTimerAction:(NSTimer *)timer
{
    //规定时间内接收方没有收到输入状态通知
    [self stopRunLoop];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [multicastDelegate emHelper:weakSelf handleInputStateMessage:nil];
    });
}

@end
