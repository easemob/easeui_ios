//
//  EaseChatCustomMessageModel.h
//  EaseIMKit
//
//  Created by 娜塔莎 on 2020/12/8.
//  Copyright © 2020 djp. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EaseChatCustomMessageModel : NSObject

@property (nonatomic, strong) NSString *msgKey; //自定义消息所代表的 KEY
@property (nonatomic, strong) NSDictionary *msgContentDictionary; //自定义消息的内容

- (instancetype)initWithCustomMessageInfo:(NSString *)msgKey msgContentDictionary:(NSDictionary *)msgContentDictionary;

@end

NS_ASSUME_NONNULL_END
