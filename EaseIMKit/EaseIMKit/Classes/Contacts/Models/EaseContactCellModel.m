//
//  EaseContactCellModel.m
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/11/5.
//

#import "EaseContactCellModel.h"

@implementation EaseContactCellModel {
    NSString *_showName;
}

- (instancetype)initWithShowName:(NSString *)showName {
    if (self = [super init]) {
        _showName = showName;
    }
    return self;
}

- (NSString *)showName {
    return _showName;
}


@end
