//
//  EaseContactCellModelDelegate.h
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/11/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    Normal,
    Contact,
} EaseContactCellModelType;


@protocol EaseContactCellModelDelegate <NSObject>

@required
@property (nonatomic, copy, readonly) NSString *avatarURL; // 显示头像的url
@property (nonatomic, copy, readonly) NSString *showName; // 显示头像的昵称
@property (nonatomic, assign) EaseContactCellModelType type;

@end

NS_ASSUME_NONNULL_END
