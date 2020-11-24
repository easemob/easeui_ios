//
//  EaseContactCellModel.h
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/11/5.
//

#import <Foundation/Foundation.h>
#import "EaseContactDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface EaseContactCellModel : NSObject <EaseContactDelegate>
- (instancetype)initWithShowName:(NSString *)showName;
- (void)setDefaultAvatar:(UIImage *)defaultAvatar;
- (UIImage *)defaultAvatar;
@end

NS_ASSUME_NONNULL_END
