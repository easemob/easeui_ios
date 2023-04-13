//
//  EaseChatViewController.h
//  EaseIM
//
//  Created by XieYajie on 2019/1/18.
//  Update © 2020 zhangchong. All rights reserved.
//



#import "EaseChatViewModel.h"
#import "EaseChatViewControllerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface EaseChatViewController : UIViewController <UIDocumentInteractionControllerDelegate>

@property (nonatomic, weak) id<EaseChatViewControllerDelegate> delegate;

@property (nonatomic, strong) EMConversation *currentConversation;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSString *moreMsgId;  //第一条消息的消息id
@property (nonatomic) NSTimeInterval msgTimelTag;   //消息时间格式化

@property (nonatomic) BOOL endScroll;

+ (EaseChatViewController *)initWithConversationId:(NSString *)aConversationId
                      conversationType:(EMConversationType)aType
                                     chatViewModel:(EaseChatViewModel *)aModel;
//重置聊天控制器
- (void)resetChatVCWithViewModel:(EaseChatViewModel *)viewModel;

//是否显示输入状态
- (void)setEditingStatusVisible:(BOOL)editingStatusVisible;
//发送文本消息
- (void)sendTextAction:(NSString *)aText ext:(NSDictionary * __nullable)aExt;
//发送消息体
- (void)sendMessageWithBody:(EMMessageBody *)aBody ext:(NSDictionary * __nullable)aExt;
//消息已读回执
- (void)sendReadReceipt:(EMChatMessage *)msg;
//触发用户资料回调 isScrollBottom：列表是否滚动到底部（最新一条消息处）
- (void)triggerUserInfoCallBack:(BOOL)isScrollBottom;
//刷新页面 isScrollBottom：列表是否滚动到底部（最新一条消息处）
- (void)refreshTableView:(BOOL)isScrollBottom;
//填充数据刷新页面 isInsertBottom:数据集是否插入到尾部（默认插入头部） isScrollBottom：列表是否滚动到底部（最新一条消息处）
- (void)refreshTableViewWithData:(NSArray<EMChatMessage *> *)messages isInsertBottom:(BOOL)isInsertBottom isScrollBottom:(BOOL)isScrollBottom;
//清除从聊天页弹出的其他控制器页面(例：发起/接收 音视频通话时清理 相册弹出页/图片浏览页/输入扩展区收起等)
- (void)cleanPopupControllerView;
//停止音频播放
- (void)stopAudioPlayer;

// 发送消息添加 @的用户，消息发送后删除
- (void)appendAtUser:(NSString *)username;
// 发送消息删除 @的用户
- (void)removeAtUser:(NSString *)username;
// 发送消息添加 @所有人
- (void)appendAtAll;
// 发送消息删除 @所有人
- (void)removeAtAll;

@end

NS_ASSUME_NONNULL_END
