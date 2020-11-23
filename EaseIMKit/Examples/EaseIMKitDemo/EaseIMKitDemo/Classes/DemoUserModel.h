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
- (NSString *)showName;
@end

NS_ASSUME_NONNULL_END
