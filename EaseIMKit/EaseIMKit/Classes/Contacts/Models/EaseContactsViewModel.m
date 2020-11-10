//
//  EaseContactsViewModel.m
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/11/5.
//

#import "EaseContactsViewModel.h"

@implementation EaseContactsViewModel
- (instancetype)init {
    if (self = [super init]) {
        _canRefresh = YES;
        _avatarType = Corner;
        _letterIndex = YES;
        _cellHeight = 60;
    }
    return self;
}
@end
