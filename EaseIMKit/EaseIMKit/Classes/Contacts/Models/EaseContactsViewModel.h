//
//  EaseContactsViewModel.h
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/11/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 *  头像风格
 */
typedef enum {
    Corner = 0, //圆角
    Rectangular,  //矩形
    Circular,  //圆形
} EaseContactAvatarStyle;

@interface EaseContactsViewModel : NSObject
@property (nonatomic) BOOL canRefresh;
@property (nonatomic, assign) EaseContactAvatarStyle avatarType;
@end

NS_ASSUME_NONNULL_END
