//
//  EMChatViewController.h
//  EaseIM
//
//  Created by XieYajie on 2019/1/18.
//  Update © 2020 zhangchong. All rights reserved.
//

#import "EMChatBar.h"
#import "EaseHeaders.h"
#import "EMViewModel.h"
#import "EaseUserDataProtocol.h"

NS_ASSUME_NONNULL_BEGIN

//聊天控制器回调
@protocol EMChatViewControlDelegate <NSObject>

@optional

/**
 * 是否从服务器获取历史消息
 *
 * YES      从服务器取
 * NO        从DB取
 */
- (BOOL)isFetchHistoryMessagesFromServer;

/**
 * 当前登录账户未读消息总数
 */
- (void)currentConversationsUnreadCount:(NSInteger)unreadCount;


/* cell 回调 */

/**
 * 返回用户资料
 *
 * message        当前消息
 */
- (id<EaseUserData>)userData:(EMMessage*)message;
/**
 * 消息点击事件 （返回是否需要执行默认点击事件）
 *
 * messageModel        当前点击的消息数据模型model
 */
- (BOOL)didSelectItem:(EMMessageModel*)messageModel;

/**
 * 自定义cell
 */
- (UITableViewCell *)cellForItem:(UITableView *)tableView messageModel:(EMMessageModel *)messageModel;


/*输入区回调*/

/**
 * 输入扩展区内容
 *
 * @param   defaultItems        默认功能描述（字符串描述定义功能）
 */
- (NSMutableArray<NSString*>*)chatBarExtFunctionItemDescArray:(NSMutableArray<NSString*>*)defaultItems;
/**
 * 输入扩展区图标
 *
 * @param   defaultImgs        默认功能图标
 */
- (NSMutableArray<UIImage*>*)chatBarExtFunctionItemImgArray:(NSMutableArray<UIImage*>*)defaultImgs;
/**
 * 输入区键盘输入变化回调
 */
- (void)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
/**
 * 对方输入状态（单聊可用）
 */
- (void)isEditing:(BOOL)isEditing;


/* 消息长按回调 */

/**
 * 长按扩展区内容
 *
 * @param   defaultItems        默认功能描述（字符串描述定义功能）
 */
- (NSMutableArray<NSString*>*)longPressExtItemDescArray:(NSMutableArray<NSString*>*)defaultItems;
/**
 * 长按扩展区图标
 *
 * @param   defaultImgs        默认功能图标
 */
- (NSMutableArray<UIImage*>*)longPressExtItemImgArray:(NSMutableArray<UIImage*>*)defaultImgs;
/**
 * 长按扩展区需要隐藏的 ITEM 列表
 *
 * @param   itemList       当前长按扩展区列表（仅事件名称）
 */
- (NSArray<NSString*>*)hideItem:(NSMutableArray<NSString*>*)itemList;


/* 消息长按功能区和输入扩展功能区点击事件回调 */

/**
 * 消息长按功能区点击项 item
 * （返回是否需要执行默认功能）
 *
 * @param   itemTag     点击项标签从0开始
 * @param   itemDesc   点击项描述
 */
- (BOOL)extLongPressFuncActionItem:(NSInteger)itemTag itemDesc:(NSString*)itemDesc;

/**
 * 输入组件更多功能区点击项 item
 * （返回是否需要执行默认功能，第一版不加）
 *
 * @param   itemTag     点击项标签从0开始
 * @param   itemDesc   点击项描述
 */
- (BOOL)extChatBarFuncActionItem:(NSInteger)itemTag itemDesc:(NSString*)itemDesc;

@end


@interface EMChatViewController : UIViewController <UIDocumentInteractionControllerDelegate>

@property (nonatomic, weak) id<EMChatViewControlDelegate> delegate;

@property (nonatomic, strong) EMConversation *currentConversation;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) dispatch_queue_t msgQueue;
@property (nonatomic, strong) EMChatBar *chatBar;
@property (nonatomic) NSTimeInterval msgTimelTag;   //消息时间格式化
@property(nonatomic, strong) UIAlertController *alertController;

//实例化聊天控制器
- (instancetype)initWithCoversationid:(NSString *)conversationId conversationType:(EMConversationType)conType chatViewModel:(EMViewModel *)viewModel;
//重置聊天控制器
- (void)resetChatVCWithViewModel:(EMViewModel *)viewModel;

//发送文本消息
- (void)sendTextAction:(NSString *)aText ext:(NSDictionary * __nullable)aExt;
//发送消息体
- (void)sendMessageWithBody:(EMMessageBody *)aBody ext:(NSDictionary * __nullable)aExt isUpload:(BOOL)aIsUpload;
//刷新页面
- (void)refreshTableView;
//消息已读回执
- (void)returnReadReceipt:(EMMessage *)msg;
//格式化消息
- (NSArray *)formatMessages:(NSArray<EMMessage *> *)aMessages;
//获取数据刷新页面
- (void)tableViewDidTriggerHeaderRefresh;

@end

NS_ASSUME_NONNULL_END
