//
//  EaseConversationCellModel.h
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/10/29.
//

#import "EaseHeaders.h"

NS_ASSUME_NONNULL_BEGIN

@protocol EaseConversationCellModelDelegate <NSObject>

@property (nonatomic, copy) UIImage *avatarImg; //头像

@property (nonatomic, copy) NSString *nickName; //会话对象昵称

@end

NS_ASSUME_NONNULL_END
