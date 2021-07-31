//
//  EMMsgTouchIncident.h
//  EaseIM
//
//  Created by 娜塔莎 on 2020/7/7.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EaseChatViewController.h"
#import "EaseMessageCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMMessageEventStrategy : NSObject

@property (nonatomic, strong) EaseChatViewController *chatController;

- (void)messageCellEventOperation:(EaseMessageCell *)aCell;

@end


/**
    消息事件工厂
 */
@interface EMMessageEventStrategyFactory : NSObject

+ (EMMessageEventStrategy * _Nonnull)getStratrgyImplWithMsgCell:(EaseMessageCell *)aCell;

@end

@interface TextMsgEvent : EMMessageEventStrategy
@end

@interface ImageMsgEvent : EMMessageEventStrategy
@end

@interface LocationMsgEvent : EMMessageEventStrategy
@end

@interface VoiceMsgEvent : EMMessageEventStrategy
@end

@interface VideoMsgEvent : EMMessageEventStrategy
@end

@interface FileMsgEvent : EMMessageEventStrategy
@end

@interface ConferenceMsgEvent : EMMessageEventStrategy
@end

NS_ASSUME_NONNULL_END
