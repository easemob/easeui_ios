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
} EMAvatarStyle;

/*!
 *  未读数view位置
 */
typedef enum {
    EMRightForCell = 0,    //cell右方
    EMTopRightCornerForAvatar, //头像右上角
} EMUnReadCountViewPosition;

NS_ASSUME_NONNULL_BEGIN

@interface EaseConversationCellOptions : NSObject

@property (nonatomic, copy) UIColor *convesationsListBgColor; //会话列表页面皮肤
@property (nonatomic, copy) UIColor *conversationCellBgColor; //会话列表项cell皮肤

@property (nonatomic) EMAvatarStyle avatarStyle; //头像风格
@property (nonatomic) CGSize avatarSize; //头像尺寸

@property (nonatomic) CGFloat wordSizeForCellTitle; //会话列表cell标题字号
@property (nonatomic) CGFloat wordSizeForCellDetail; //会话列表cell会话最后信息描述字号
@property (nonatomic) CGFloat wordSizeForCellTimestamp; //会话列表cell最后会话时间字号

@property (nonatomic) CGFloat longer; //未读数view大小(圆形)
@property (nonatomic, copy) UIColor *unReadCountViewBgColor; //未读数view背景色
@property (nonatomic) EMUnReadCountViewPosition unReadCountPosition; //未读数view位置

@property (nonatomic, copy) UIView *blankPerchView; //空会话列表占位view

@end

NS_ASSUME_NONNULL_END
