//
//  EaseConversationViewModel.h
//  EaseIMKit
//
//  Created by 娜塔莎 on 2020/11/12.
//

#import <Foundation/Foundation.h>
#import "EaseBaseTableViewModel.h"
#import "Masonry.h"

/*!
 *  未读数view位置
 */
typedef enum {
    EMRightForCell = 0,    //cell右方
    EMTopRightCornerForAvatar, //头像右上角
} EMUnReadCountViewPosition;

NS_ASSUME_NONNULL_BEGIN

@interface EaseConversationViewModel : EaseBaseTableViewModel

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
