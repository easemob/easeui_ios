//
//  EaseConversationCellModel.h
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/10/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol EaseConversationCellModelDelegate <NSObject>

@property (nonatomic, copy) NSString *showName;
@property (nonatomic, copy) NSString *avatarStr;

@end

NS_ASSUME_NONNULL_END
