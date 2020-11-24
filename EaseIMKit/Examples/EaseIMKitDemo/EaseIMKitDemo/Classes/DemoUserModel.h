//
//  DemoUserModel.h
//  EaseIMKitDemo
//
//  Created by 杜洁鹏 on 2020/11/23.
//  Copyright © 2020 djp. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DemoUserModel : NSObject <EaseUserDelegate>
- (instancetype)initWithEaseId:(NSString *)easeId;
@property (nonatomic, strong) NSString *nickName;
- (NSString *)easeId;
- (NSString *)showName;
@end

NS_ASSUME_NONNULL_END
