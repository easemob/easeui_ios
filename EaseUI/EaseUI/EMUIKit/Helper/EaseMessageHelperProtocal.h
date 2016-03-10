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

@end
