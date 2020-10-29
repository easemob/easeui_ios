//
//  ConversationCellModel.h
//  EaseIMKitDemo
//
//  Created by 杜洁鹏 on 2020/10/29.
//  Copyright © 2020 djp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EaseIMKit/EaseIMKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ConversationCellModel : NSObject <EaseConversationCellModelDelegate>
@property (nonatomic, copy) NSString *showName;
@property (nonatomic, copy) NSString *avatarStr;
@end

NS_ASSUME_NONNULL_END
