//
//  EaseUserUtils.m
//  EaseIMKit
//
//  Created by 冯钊 on 2023/4/27.
//

#import "EaseUserUtils.h"

static EaseUserUtils *shared;

@implementation EaseUserUtils

+ (instancetype)shared
{
    if (!shared) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            shared = [[EaseUserUtils alloc] init];
        });
    }
    return shared;
}

- (id)getUserInfo:(NSString *)easeId moduleType:(EaseUserModuleType)moduleType
{
    if (_delegate && [_delegate respondsToSelector:@selector(getUserInfo:moduleType:)]) {
        return [_delegate getUserInfo:easeId moduleType:moduleType];
    }
    return nil;
}

@end
