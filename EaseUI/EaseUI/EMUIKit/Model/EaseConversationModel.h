//
//  EaseConversationModel.h
//  ChatDemo-UI3.0
//
//  Created by dhc on 15/6/25.
//  Copyright (c) 2015年 easemob.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IConversationModel.h"

@interface EaseConversationModel : NSObject<IConversationModel>

@property (strong, nonatomic, readonly) EMConversation *conversation;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *avatarURLPath;
@property (strong, nonatomic) UIImage *avatarImage;

- (instancetype)initWithConversation:(EMConversation *)conversation;

@end
