//
//  EaseConversationItemModel.h
//  EaseIMKit
//
//  Created by 娜塔莎 on 2020/11/10.
//

#import "EaseConversationItemModelDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface EaseConversationItemModel : NSObject <EaseConversationItemModelDelegate>

- (instancetype)initWithEMConversation:(EMConversation *)conversation;

@end

NS_ASSUME_NONNULL_END
