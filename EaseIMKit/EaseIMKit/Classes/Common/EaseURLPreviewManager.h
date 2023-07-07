//
//  EaseURLPreviewManager.h
//  EaseIMKit
//
//  Created by 冯钊 on 2023/5/23.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, EaseURLPreviewState) {
    EaseURLPreviewStateLoading,
    EaseURLPreviewStateSuccess,
    EaseURLPreviewStateFaild,
};

NS_ASSUME_NONNULL_BEGIN

@interface EaseURLPreviewResult: NSObject

@property (nonatomic, assign) EaseURLPreviewState state;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *imageUrl;

@end

typedef void(^EaseURLPreviewSuccessBlock)(EaseURLPreviewResult *result);
typedef void(^EaseURLPreviewFailedBlock)(void);

@interface EaseURLPreviewManager : NSObject

+ (instancetype)shared;

- (void)preview:(NSURL *)url successHandle:(EaseURLPreviewSuccessBlock)successHandle faieldHandle:(nullable EaseURLPreviewFailedBlock)faieldHandle;

- (nullable EaseURLPreviewResult *)resultWithURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
