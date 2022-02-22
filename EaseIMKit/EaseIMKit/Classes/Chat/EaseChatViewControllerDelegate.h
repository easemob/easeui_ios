//
//  EaseChatViewControllerDelegate.h
//  EaseIMKit
//
//  Created by 娜塔莎 on 2020/11/25.
//

#import <UIKit/UIKit.h>
#import "EaseUserDelegate.h"
#import "EaseMessageModel.h"
#import "EaseExtMenuModel.h"

NS_ASSUME_NONNULL_BEGIN

//聊天控制器回调
@protocol EaseChatViewControllerDelegate <NSObject>

@optional

/* cell 回调 */

/**
 * 返回用户资料
 *
 * @param   huanxinID        环信id
 *
 */
- (id<EaseUserDelegate>)userData:(NSString *)huanxinID;

/**
 * 头像点击事件
 *
 * @param   userData        当前点击的头像所指向的用户资料
 *
 */
- (void)avatarDidSelected:(id<EaseUserDelegate>)userData;

/**
 * 头像长按事件
 *
 * @param   userData        当前长按的头像所指向的用户资料
 *
 */
- (void)avatarDidLongPress:(id<EaseUserDelegate>)userData;

/**
 * 群通知回执详情
 *
 * @param   message        当前群通知消息
 * @param   groupId        当前消息所属群ID
 *
 */
- (void)groupMessageReadReceiptDetail:(EMChatMessage *)message groupId:(NSString*)groupId;

/**
 * 自定义cell
 */
- (UITableViewCell *)cellForItem:(UITableView *)tableView messageModel:(EaseMessageModel *)messageModel;

/**
 * 当前所长按的 自定义cell 的扩展区数据模型组
 *
 * @param   defaultLongPressItems       默认长按扩展区功能数据模型组      （默认共有：复制，删除，撤回（发送消息时间距当前时间小于2分钟））
 * @param   customCell                               当前长按的自定义cell
 *
 */
- (NSMutableArray<EaseExtMenuModel *> *)customCellLongPressExtMenuItemArray:(NSMutableArray<EaseExtMenuModel*>*)defaultLongPressItems customCell:(UITableViewCell*)customCell;


/*输入区回调*/

/**
 * EaseIMKit发送消息前回调
 *
 * @param   aMessage      将要发送的消息
 *
 */
- (EMChatMessage *)willSendMessage:(EMChatMessage *)aMessage;

/**
 * 发送消息完成回调
 *
 * @param   message       发送完成的消息
 * @param   error         发送消息结果
 *
 */
-(void)didSendMessage:(EMChatMessage *)message error:(EMError *)error;

/**
 * 当前会话输入扩展区数据模型组
 *
 * @param   defaultInputBarItems        默认功能数据模型组   （默认有序：相册，相机，位置，文件）
 * @param   conversationType                 当前会话类型：单聊，群聊，聊天室
 *
 */
- (NSMutableArray<EaseExtMenuModel *> *)inputBarExtMenuItemArray:(NSMutableArray<EaseExtMenuModel*>*)defaultInputBarItems conversationType:(EMConversationType)conversationType;
/**
 * 输入区键盘输入变化回调  例：@群成员
 */
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;

/**
 对方正在输入
*/
- (void)beginTyping;

/**
 对方结束输入
*/
- (void)endTyping;


/* 消息事件回调 */

/**
 * 消息点击事件 （返回是否需要执行默认点击事件） 默认 YES
 *
 * @param   message         当前点击的消息
 * @param   userData        当前点击的消息携带的用户资料
 *
 */
- (BOOL)didSelectMessageItem:(EMChatMessage *)message userData:(id<EaseUserDelegate>)userData;

/**
 * 当前所长按消息的扩展区数据模型组
 *
 * @param   defaultLongPressItems       默认长按扩展区功能数据模型组  （默认共有：复制，删除， 撤回）
 * @param   message                     当前长按的消息
 *
 */
- (NSMutableArray<EaseExtMenuModel *> *)messageLongPressExtMenuItemArray:(NSMutableArray<EaseExtMenuModel*>*)defaultLongPressItems message:(EMChatMessage*)message;


/* 页面下拉加载回调 */

/**
 * 下拉加载更多消息回调 
 *
 * @param   firstMessageId          第一条消息 id
 * @param   messageList             当前消息列表
 *
 */
- (void)loadMoreMessageData:(NSString *)firstMessageId currentMessageList:(NSArray<EMChatMessage *> *)messageList;

@end

NS_ASSUME_NONNULL_END
