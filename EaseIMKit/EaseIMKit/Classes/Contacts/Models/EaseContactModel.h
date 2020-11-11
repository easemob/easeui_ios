//
//  EaseContactModel.h
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/11/5.
//

#import <Foundation/Foundation.h>
#import "EaseContactDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface EaseContactModel : NSObject <EaseContactDelegate>
- (instancetype)initWithShowName:(NSString *)showName;
@end

NS_ASSUME_NONNULL_END
