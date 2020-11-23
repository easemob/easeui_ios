//
//  EMViewModel.h
//  EaseIMKit
//
//  Created by 娜塔莎 on 2020/11/17.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "EaseCommonEnum.h"

/*!
 *  输入区类型
 */
typedef NS_ENUM(NSInteger, EMChatBarStyle) {
    EMChatBarStyleAll = 1,          //全部功能
    EMChatBarStyleLackAudio,        //缺少语音
    EMChatBarStyleLackEmoji,        //缺少表情
    EMChatBarStyleOnlyExtension,    //只有扩展
    EMChatBarStyleText,             //纯文本
};

/*!
 *  群聊消息排列方式
 */
typedef enum {
    ArrangementLeftOrRight = 1,     //左右排列
    ArrangementlLeft,               //居左排列
} EMArrangementStyle;

NS_ASSUME_NONNULL_BEGIN

@interface EMViewModel : NSObject

@property (nonatomic, strong) UIColor *chatViewBgColor; //聊天页背景色
@property (nonatomic, strong) UIColor *chatBarBgColor; //输入区背景色
@property (nonatomic, strong) UIColor *msgTimeItemBgColor; //时间线背景色
@property (nonatomic, strong) UIColor *msgTimeItemFontColor; //时间线字体颜色
@property (nonatomic, strong) UIImage *receiveBubbleBgPicture; //所接收信息的气泡
@property (nonatomic, strong) UIImage *sendBubbleBgPicture; //所发送信息的气泡
@property (nonatomic) CGFloat contentFontSize; //消息字体大小
@property (nonatomic) EMChatBarStyle chatBarStyle; //输入区类型：(全部功能，缺少语音，缺少表情，只有扩展，纯文本)
@property (nonatomic) EaseAvatarStyle avatarStyle; //头像风格
@property (nonatomic) CGFloat avatarCornerRadius; //头像圆角大小 默认：0 (只有头像类型是圆角才会有效)
@property (nonatomic) CGFloat avatarLength; //头像边长（默认正方形）
//仅群聊可设置
@property (nonatomic, assign) CGFloat chatViewHeight; //聊天区域高度：仅群聊可设置
@property (nonatomic)  EMArrangementStyle msgArrangementStyle; //聊天区域消息排列方式

@end

NS_ASSUME_NONNULL_END
