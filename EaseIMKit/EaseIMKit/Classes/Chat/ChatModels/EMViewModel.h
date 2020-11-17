//
//  EMViewModel.h
//  EaseIMKit
//
//  Created by 娜塔莎 on 2020/11/17.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, EMChatBarStyle) {
    EMChatBarStyleAll = 1,
};

NS_ASSUME_NONNULL_BEGIN

@interface EMViewModel : NSObject

@property (nonatomic, strong) UIColor *chatViewBgColor; //聊天页背景色
@property (nonatomic, strong) UIColor *chatBarBgColor; //输入区背景色
@property (nonatomic, strong) UIColor *msgTimeItemBgColor; //时间线背景色
@property (nonatomic, strong) UIColor *msgTimeItemFontColor; //时间线字体颜色
@property (nonatomic, strong) UIImage *receiveBubbleBgPicture; //所接收信息的气泡
@property (nonatomic, strong) UIImage *sendBubbleBgPicture; //所发送信息的气泡
@property (nonatomic) float contentFontSize; //消息字体大小
@property (nonatomic) EMChatBarStyle chatBarStyle;

@end

NS_ASSUME_NONNULL_END
