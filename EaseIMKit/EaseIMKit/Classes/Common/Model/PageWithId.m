//
//  PageWithId.m
//  EaseIMKit
//
//  Created by 冯钊 on 2022/3/1.
//

#import "PageWithId.h"

@interface PageWithId ()

@property (nonatomic, strong) NSMutableArray *dataList;
@property (nonatomic, strong) NSString *lastId;
@property (nonatomic, strong) NSMutableDictionary *userInfo;

@end

@implementation PageWithId

- (instancetype)init {
    if (self = [super init]) {
        _dataList = [NSMutableArray array];
    }
    return self;
}

- (void)appendData:(NSArray *)dataList lastId:(NSString *)lastId {
    [_dataList addObjectsFromArray:dataList];
    _lastId = lastId;
}

- (void)clear {
    [_dataList removeAllObjects];
    _lastId = nil;
    [_userInfo removeAllObjects];
}

- (NSMutableDictionary *)userInfo {
    if (!_userInfo) {
        _userInfo = [NSMutableDictionary dictionary];
    }
    return _userInfo;
}

@end
