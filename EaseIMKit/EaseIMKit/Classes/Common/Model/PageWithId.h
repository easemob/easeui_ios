//
//  PageWithId.h
//  EaseIMKit
//
//  Created by 冯钊 on 2022/3/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PageWithId <ObjectType>: NSObject

@property (readonly) NSArray <ObjectType>*dataList;
@property (readonly, nullable) NSString *lastId;
@property (readonly) NSMutableDictionary *userInfo;

- (void)appendData:(NSArray <ObjectType>*)dataList lastId:(NSString *)lastId;

- (void)clear;

@end

NS_ASSUME_NONNULL_END
