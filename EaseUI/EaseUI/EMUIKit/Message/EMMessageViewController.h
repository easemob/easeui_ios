//
//  EMMessageViewController.h
//  ChatDemo-UI3.0
//
//  Created by dhc on 15/6/26.
//  Copyright (c) 2015年 easemob.com. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "EMRefreshTableViewController.h"

#import "IMessageModel.h"
#import "EMMessageModel.h"
#import "EMSendMessageCell.h"
#import "EMRecvMessageCell.h"
#import "EMMessageTimeCell.h"
#import "EMChatToolbar.h"
#import "EMLocationViewController.h"
#import "EMCDDeviceManager+Media.h"
#import "EMCDDeviceManager+ProximitySensor.h"
#import "UIViewController+HUD.h"
#import "EMSDKHelper.h"

@class EMMessageViewController;

@protocol EMMessageViewControllerDelegate <NSObject>

@optional

/**
 *  获取消息自定义cell
 */
- (UITableViewCell *)messageViewController:(UITableView *)tableView
                       cellForMessageModel:(id<IMessageModel>)messageModel;

/**
 *  消息cell高度
 */
- (CGFloat)messageViewController:(EMMessageViewController *)viewController
           heightForMessageModel:(id<IMessageModel>)messageModel
                   withCellWidth:(CGFloat)cellWidth;

/**
 *  发送消息成功
 */
- (void)messageViewController:(EMMessageViewController *)viewController
          didSendMessageModel:(id<IMessageModel>)messageModel;

/**
 *  发送消息失败
 */
- (void)messageViewController:(EMMessageViewController *)viewController
   didFailSendingMessageModel:(id<IMessageModel>)messageModel
                        error:(EMError *)error;

/**
 *  接收到消息的已读回执
 */
- (void)messageViewController:(EMMessageViewController *)viewController
 didReceiveHasReadAckForModel:(id<IMessageModel>)messageModel;

/**
 *  选中消息
 */
- (void)messageViewController:(EMMessageViewController *)viewController
        didSelectMessageModel:(id<IMessageModel>)messageModel
             withTapEventType:(EMMessageCellTapEventType)type;

/**
 *  选中消息头像
 */
- (void)messageViewController:(EMMessageViewController *)viewController
    didSelectAvatarMessageModel:(id<IMessageModel>)messageModel;

/**
 *  选中底部功能按钮
 */
- (void)messageViewController:(EMMessageViewController *)viewController
            didSelectMoreView:(EMChatBarMoreView *)moreView
                      AtIndex:(NSInteger)index;

/**
 * 底部录音功能按钮
 */
- (void)messageViewController:(EMMessageViewController *)viewController
              didSelectRecordView:(UIView *)recordView
                withEvenType:(EMRecordViewType)type;

@end


@protocol EMMessageViewControllerDataSource <NSObject>

@optional

/**
 *  指定消息附件上传或者下载进度的监听者， 默认self
 */
- (id<IEMChatProgressDelegate>)messageViewController:(EMMessageViewController *)viewController
                  progressDelegateForMessageBodyType:(MessageBodyType)messageBodyType;

/**
 *  附件进度有更新
 */
- (void)messageViewController:(EMMessageViewController *)viewController
               updateProgress:(float)progress
                 messageModel:(id<IMessageModel>)messageModel
                  messageBody:(id<IEMMessageBody>)messageBody;

/**
 *  消息时间间隔描述
 */
- (NSString *)messageViewController:(EMMessageViewController *)viewController
                      stringForDate:(NSDate *)date;

/**
 *  获取消息，返回EMMessage类型的数据列表
 */
- (NSArray *)messageViewController:(EMMessageViewController *)viewController
          loadMessageFromTimestamp:(long long)timestamp
                             count:(NSInteger)count;

/**
 *  将EMMessage类型转换为符合<IMessageModel>协议的类型
 */
- (id<IMessageModel>)messageViewController:(EMMessageViewController *)viewController
                           modelForMessage:(EMMessage *)message;

/**
 *  是否允许长按
 */
- (BOOL)messageViewController:(EMMessageViewController *)viewController
   canLongPressRowAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  触发长按手势
 */
- (BOOL)messageViewController:(EMMessageViewController *)viewController
   didLongPressRowAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  是否标记为已读
 *  message 指定的message
 */
- (BOOL)messageViewControllerShouldMarkMessagesAsRead:(EMMessageViewController *)viewController;

/**
 *  是否发送已读回执
 *  message 要发送已读回执的message
 *  read    message是否已读
 */
- (BOOL)messageViewController:(EMMessageViewController *)viewController
shouldSendHasReadAckForMessage:(EMMessage *)message
                         read:(BOOL)read;

@end

@interface EMMessageViewController : EMRefreshTableViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate, IChatManagerDelegate, IEMChatProgressDelegate, EMCallManagerCallDelegate, EMCDDeviceManagerDelegate, EMChatToolbarDelegate, EMChatBarMoreViewDelegate, EMLocationViewDelegate>

@property (weak, nonatomic) id<EMMessageViewControllerDelegate> delegate;

@property (weak, nonatomic) id<EMMessageViewControllerDataSource> dataSource;

@property (strong, nonatomic, readonly) EMConversation *conversation;

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

@property(strong, nonatomic) EMChatBarMoreView *chatBarMoreView;

@property(strong, nonatomic) EMFaceView *faceView;

@property(strong, nonatomic) EMRecordView *recordView;

@property (strong, nonatomic) UIMenuController *menuController;

@property (strong, nonatomic) UIImagePickerController *imagePicker;

@property (nonatomic) BOOL isInvisible;

- (instancetype)initWithConversationChatter:(NSString *)conversationChatter
                           conversationType:(EMConversationType)conversationType;

/**
 *  下拉加载更多
 */
- (void)tableViewDidTriggerHeaderRefresh;

/**
 *  刷新conversation list页面
 */
- (void)reloadConversationList;

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

@end
