//
//  EaseChatCustomMessageModel.m
//  EaseIMKit
//
//  Created by 娜塔莎 on 2020/12/8.
//  Copyright © 2020 djp. All rights reserved.
//

#import "EaseChatCustomMessageModel.h"

@implementation EaseChatCustomMessageModel

- (instancetype)initWithCustomMessageInfo:(NSString *)msgKey msgContentDictionary:(NSDictionary *)msgContentDictionary
{
    if (self = [super init]) {
        _msgKey = msgKey;
        _msgContentDictionary = msgContentDictionary;
    }
    return self;
}

- (void)setMsgKey:(NSString *)msgKey
{
    if (msgKey && msgKey.length > 0) {
        _msgKey = msgKey;
    }
}

- (void)setMsgContentDictionary:(NSDictionary *)msgContentDictionary
{
    if (msgContentDictionary) {
        _msgContentDictionary = msgContentDictionary;
    }
}

@end
