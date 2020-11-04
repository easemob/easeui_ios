//
//  EaseConversationCellOptions.h
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/10/29.
//

#import <Foundation/Foundation.h>

/*!
 *  头像风格
 */
typedef enum {
    EMAvatarStyleCorner = 0, //圆角
    EMAvatarStyleRectangular,  //矩形
    EMAvatarStyleCircular,  //圆形
    
    EMAvatarMIN = EMAvatarStyleCorner,
    EMAvatarMAX = EMAvatarStyleCircular,
} EMAvatarStyle;

/*!
 *  未读数view位置
 */
typedef enum {
    EMRightForCell = 0,    //cell右方
    EMTopRightCornerForAvatar, //头像右上角
    
    EMPositionMIN = EMRightForCell,
    EMPositionMAX = EMTopRightCornerForAvatar,
} EMUnReadCountViewPosition;

NS_ASSUME_NONNULL_BEGIN

@interface EaseConversationCellOptions : NSObject

@property (nonatomic, copy) UIColor *bgColor; //会话列表皮肤

@property (nonatomic) EMAvatarStyle avatarStyle; //头像风格

@property (nonatomic) EMUnReadCountViewPosition unReadCountPosition; //未读数view位置

@property (nonatomic, copy) UIColor *unReadCountViewBgColor; //未读数view背景色

@property (nonatomic) CGFloat longer; //未读数view大小(圆形)

@property (nonatomic, copy) UIView *blankPerchView; //空会话列表占位view

@end

NS_ASSUME_NONNULL_END
