//
//  EaseNormalModel.m
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/11/10.
//

#import "EaseNormalModel.h"

@implementation EaseNormalModel

- (instancetype)initWithShowName:(NSString *)showName {
    if (self = [super initWithShowName:showName]) {
        
    }
    
    return self;
}

- (EaseContactModelType)type {
    return Normal;
}


@end
