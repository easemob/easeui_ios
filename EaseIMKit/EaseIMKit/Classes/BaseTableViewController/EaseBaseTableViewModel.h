//
//  EaseBaseTableViewModel.h
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/11/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 *  头像风格
 */
typedef enum {
    Corner = 0,     //圆角
    Rectangular,    //矩形
    Circular,       //圆形
} EaseAvatarStyle;


@interface EaseBaseTableViewModel : NSObject
@property (nonatomic) EaseAvatarStyle avatarType;
@property (nonatomic) BOOL canRefresh;
@property (nonatomic) CGFloat cellHeight;
@property (nonatomic) BOOL cellCanEdit;
@property (nonatomic, copy) UIColor *cellBgColor; //cell皮肤
@property (nonatomic, copy) UIColor *viewBgColor; //页面皮肤
@end

NS_ASSUME_NONNULL_END
