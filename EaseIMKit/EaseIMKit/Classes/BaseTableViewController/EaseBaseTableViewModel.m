//
//  EaseBaseTableViewModel.m
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/11/11.
//

#import "EaseBaseTableViewModel.h"

@implementation EaseBaseTableViewModel
- (instancetype)init {
    if( self = [super init]) {
        _canRefresh = YES;
        _avatarType = Corner;
        _cellHeight = 60;
        _cellBgColor = [UIColor whiteColor];
        _viewBgColor = [UIColor whiteColor];
    }
    
    return self;
}
@end
