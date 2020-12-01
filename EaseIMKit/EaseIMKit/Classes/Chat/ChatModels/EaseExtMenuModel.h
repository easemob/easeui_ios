//
//  EaseExtMenuModel.h
//  EaseIMKit
//
//  Created by 娜塔莎 on 2020/11/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EaseExtMenuModel : NSObject

typedef void(^menuItemDidSelectedHandle)(NSString* itemDesc, BOOL isExecuted);

- (instancetype)initWithData:(UIImage *)icon funcDesc:(NSString *)funcDesc handle:(menuItemDidSelectedHandle)menuItemHandle;

@property (nonatomic, strong) UIImage *icon; //图标
@property (nonatomic, strong) NSString *funcDesc; //功能描述
@property (nonatomic, strong) menuItemDidSelectedHandle itemDidSelectedHandle;

@end

NS_ASSUME_NONNULL_END
