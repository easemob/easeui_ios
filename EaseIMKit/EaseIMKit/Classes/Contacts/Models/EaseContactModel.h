//
//  EaseContactModel.h
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/11/5.
//

#import <Foundation/Foundation.h>
#import "EaseUserDelegate.h"
NS_ASSUME_NONNULL_BEGIN

@interface EaseContactModel : NSObject

- (instancetype)initWithEaseId:(NSString *)easeId;

@property (nonatomic) id<EaseUserDelegate> userDelegate;
@property (nonatomic, strong, readonly) NSString *easeId;
@property (nonatomic, strong, readonly) NSString *showName;
@property (nonatomic, strong, readonly) NSString *firstLetter;
@property (nonatomic, strong, readonly) UIImage *defaultAvatar;
@property (nonatomic, strong, readonly) NSString *avatarURL;

@end

NS_ASSUME_NONNULL_END
