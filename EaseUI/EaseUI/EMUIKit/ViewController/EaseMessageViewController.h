//
//  EaseMessageViewController.h
//  ChatDemo-UI3.0
//
//  Created by dhc on 15/6/26.
//  Copyright (c) 2015年 easemob.com. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "EaseRefreshTableViewController.h"

#import "IMessageModel.h"
#import "EaseMessageModel.h"
#import "EaseBaseMessageCell.h"
#import "EaseMessageTimeCell.h"
#import "EaseChatToolbar.h"
#import "EaseLocationViewController.h"
#import "EMCDDeviceManager+Media.h"
#import "EMCDDeviceManager+ProximitySensor.h"
#import "UIViewController+HUD.h"
#import "EaseSDKHelper.h"

@class EaseMessageViewController;

@protocol EaseMessageViewControllerDelegate <NSObject>

@optional

/**
 *  获取消息自定义cell
 */
- (UITableViewCell *)messageViewController:(UITableView *)tableView
                       cellForMessageModel:(id<IMessageModel>)messageModel;

/**
 *  消息cell高度
 */
- (CGFloat)messageViewController:(EaseMessageViewController *)viewController
           heightForMessageModel:(id<IMessageModel>)messageModel
                   withCellWidth:(CGFloat)cellWidth;

/**
 *  发送消息成功
 */
- (void)messageViewController:(EaseMessageViewController *)viewController
          didSendMessageModel:(id<IMessageModel>)messageModel;

/**
 *  发送消息失败
 */
- (void)messageViewController:(EaseMessageViewController *)viewController
   didFailSendingMessageModel:(id<IMessageModel>)messageModel
                        error:(EMError *)error;

/**
 *  接收到消息的已读回执
 */
- (void)messageViewController:(EaseMessageViewController *)viewController
 didReceiveHasReadAckForModel:(id<IMessageModel>)messageModel;

/**
 *  选中消息
 */
- (BOOL)messageViewController:(EaseMessageViewController *)viewController
        didSelectMessageModel:(id<IMessageModel>)messageModel;

/**
 *  选中消息头像
 */
- (void)messageViewController:(EaseMessageViewController *)viewController
    didSelectAvatarMessageModel:(id<IMessageModel>)messageModel;

/**
 *  选中底部功能按钮
 */
- (void)messageViewController:(EaseMessageViewController *)viewController
            didSelectMoreView:(EaseChatBarMoreView *)moreView
                      AtIndex:(NSInteger)index;

/**
 * 底部录音功能按钮
 */
- (void)messageViewController:(EaseMessageViewController *)viewController
              didSelectRecordView:(UIView *)recordView
                withEvenType:(EaseRecordViewType)type;

@end


@protocol EaseMessageViewControllerDataSource <NSObject>

@optional

/**
 *  指定消息附件上传或者下载进度的监听者， 默认self
 */
- (id<IEMChatProgressDelegate>)messageViewController:(EaseMessageViewController *)viewController
                  progressDelegateForMessageBodyType:(MessageBodyType)messageBodyType;

/**
 *  附件进度有更新
 */
- (void)messageViewController:(EaseMessageViewController *)viewController
               updateProgress:(float)progress
                 messageModel:(id<IMessageModel>)messageModel
                  messageBody:(id<IEMMessageBody>)messageBody;

/**
 *  消息时间间隔描述
 */
- (NSString *)messageViewController:(EaseMessageViewController *)viewController
                      stringForDate:(NSDate *)date;

/**
 *  获取消息，返回EMMessage类型的数据列表
 */
- (NSArray *)messageViewController:(EaseMessageViewController *)viewController
          loadMessageFromTimestamp:(long long)timestamp
                             count:(NSInteger)count;

/**
 *  将EMMessage类型转换为符合<IMessageModel>协议的类型
 */
- (id<IMessageModel>)messageViewController:(EaseMessageViewController *)viewController
                           modelForMessage:(EMMessage *)message;

/**
 *  是否允许长按
 */
- (BOOL)messageViewController:(EaseMessageViewController *)viewController
   canLongPressRowAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  触发长按手势
 */
- (BOOL)messageViewController:(EaseMessageViewController *)viewController
   didLongPressRowAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  是否标记为已读
 *  message 指定的message
 */
- (BOOL)messageViewControllerShouldMarkMessagesAsRead:(EaseMessageViewController *)viewController;

/**
 *  是否发送已读回执
 *  message 要发送已读回执的message
 *  read    message是否已读
 */
- (BOOL)messageViewController:(EaseMessageViewController *)viewController
shouldSendHasReadAckForMessage:(EMMessage *)message
                         read:(BOOL)read;

@end

@interface EaseMessageViewController : EaseRefreshTableViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate, IChatManagerDelegate, IEMChatProgressDelegate, EMCallManagerCallDelegate, EMCDDeviceManagerDelegate, EMChatToolbarDelegate, EaseChatBarMoreViewDelegate, EMLocationViewDelegate>

@property (weak, nonatomic) id<EaseMessageViewControllerDelegate> delegate;

@property (weak, nonatomic) id<EaseMessageViewControllerDataSource> dataSource;

@property (strong, nonatomic) EMConversation *conversation;

@property (nonatomic) NSTimeInterval messageTimeIntervalTag;

//如果conversation中没有任何消息，退出该页面时是否删除该conversation
@property (nonatomic) BOOL deleteConversationIfNull; //default YES;

//当前页面显示时，是否滚动到最后一条
@property (nonatomic) BOOL scrollToBottomWhenAppear; //default YES;

//页面是否处于显示状态
@property (nonatomic) BOOL isViewDidAppear;

//加载的每页message的条数
@property (nonatomic) NSInteger messageCountOfPage; //default 50

//时间分割cell的高度
@property (nonatomic) CGFloat timeCellHeight;

//显示的EMMessage类型的消息列表
@property (strong, nonatomic) NSMutableArray *messsagesSource;

@property (strong, nonatomic) UIView *chatToolbar;

@property(strong, nonatomic) EaseChatBarMoreView *chatBarMoreView;

@property(strong, nonatomic) EaseFaceView *faceView;

@property(strong, nonatomic) EaseRecordView *recordView;

@property (strong, nonatomic) UIMenuController *menuController;

@property (strong, nonatomic) NSIndexPath *menuIndexPath;

@property (strong, nonatomic) UIImagePickerController *imagePicker;

- (instancetype)initWithConversationChatter:(NSString *)conversationChatter
                           conversationType:(EMConversationType)conversationType;

/**
 *  下拉加载更多
 */
- (void)tableViewDidTriggerHeaderRefresh;

/**
 *  发送文本消息
 */
- (void)sendTextMessage:(NSString *)text;

/**
 *  发送图片消息
 */
- (void)sendImageMessage:(UIImage *)image;

/**
 *  发送位置消息
 */
- (void)sendLocationMessageLatitude:(double)latitude
                          longitude:(double)longitude
                         andAddress:(NSString *)address;

/**
 *  发送语音消息
 */
- (void)sendVoiceMessageWithLocalPath:(NSString *)localPath
                             duration:(NSInteger)duration;

/**
 *  发送视频消息
 */
- (void)sendVideoMessageWithURL:(NSURL *)url;

/*
 *  添加消息
 */
-(void)addMessageToDataSource:(EMMessage *)message
                     progress:(id<IEMChatProgressDelegate>)progress;

@end
