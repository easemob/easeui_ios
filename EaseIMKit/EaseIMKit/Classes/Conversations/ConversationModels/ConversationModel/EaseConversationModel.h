//
//  EaseConversationModel.h
//  EaseIMKit
//
//  Created by 娜塔莎 on 2020/11/10.
//

#import "EaseConversationModelDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface EaseConversationModel : NSObject <EaseConversationModelDelegate>

- (instancetype)initWithConversation:(EMConversation *)conversation;

@end

NS_ASSUME_NONNULL_END
