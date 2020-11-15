//
//  EaseConversationItem.h
//  EaseIMKit
//
//  Created by 娜塔莎 on 2020/11/10.
//

#import "EaseConversationItemDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface EaseConversationItem : NSObject <EaseConversationItemDelegate>

- (instancetype)initWithConversation:(EMConversation *)conversation;

@end

NS_ASSUME_NONNULL_END
