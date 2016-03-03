//
//  EaseMessageHelperProtocal.h
//  EaseUI
//
//  Created by WYZ on 16/2/19.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>
@class EaseMessageHelper;
@class EMMessage;

@protocol EaseMessageHelperProtocal <NSObject>

@optional

//涉及到cmd消息的回调，一律使用数组保存


/**
 * 处理接收到的消息撤销cmd消息后回调
 * @param needRevokeMessags 待撤销的消息
 */
- (void)emHelper:(EaseMessageHelper *)emHelper handleRevokeMessage:(NSArray *)needRevokeMessags;

/**
 * 处理接收到的阅后即焚消息ack后回调
 * @param removeMessage 待删除的消息
 */
- (void)emHelper:(EaseMessageHelper *)emHelper handleRemoveAfterReadMessage:(EMMessage *)removeMessage;

/**
 * 处理接收到的群组@消息后回调
 * @param messages 接收到的群组@消息，按时间戳升幂排列
 * @param isOffLine 是否为离线接收
 */
- (void)emHelper:(EaseMessageHelper *)emHelper handleGroupAtMessage:(NSArray *)messages isOffLine:(BOOL)isOffLine;

/**
 * 处理接收到的输入状态cmd消息后回调
 * @param conversationTitle 聊天页面title,如果是nil则更换为初始的标题
 */
- (void)emHelper:(EaseMessageHelper *)emHelper handleInputStateMessage:(NSString *)conversationTitle;

@end
