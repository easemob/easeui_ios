//
//  EMAudioPlayerUtil.h
//  EaseIMKit
//
//  Created by 娜塔莎 on 2020/11/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMAudioPlayerUtil : NSObject

@property (nonatomic, strong) id model;

+ (instancetype)sharedHelper;

- (void)startPlayerWithPath:(NSString *)aPath
                      model:(id)aModel
                 completion:(void(^)(NSError *error))aCompleton;

- (void)stopPlayer;

@end

NS_ASSUME_NONNULL_END
