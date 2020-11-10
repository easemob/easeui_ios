//
//  EaseContactCellModel.h
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/11/5.
//

#import <Foundation/Foundation.h>
#import "EaseContactCellModelDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface EaseContactCellModel : NSObject <EaseContactCellModelDelegate>
- (instancetype)initWithShowName:(NSString *)showName;
@end

NS_ASSUME_NONNULL_END
