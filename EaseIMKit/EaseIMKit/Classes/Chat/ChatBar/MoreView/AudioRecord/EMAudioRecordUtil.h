//
//  EMAudioRecordUtil.h
//  EaseIMKit
//
//  Created by 娜塔莎 on 2020/11/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMAudioRecordUtil : NSObject

+ (instancetype)sharedHelper;

- (void)startRecordWithPath:(NSString *)aPath
                 completion:(void(^)(NSError *error))aCompletion;

-(void)stopRecordWithCompletion:(void(^)(NSString *aPath, NSInteger aTimeLength))aCompletion;

-(void)cancelRecord;

@end

NS_ASSUME_NONNULL_END
