//
//  EaseChatViewControllerDelegate.h
//  EaseIMKit
//
//  Created by 娜塔莎 on 2020/11/25.
//

#import <Foundation/Foundation.h>
#import "EaseUserDataDelegate.h"
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
 */
- (id<EaseUserData>)userData:(NSString*)huanxinID;

/**
 * 头像点击事件 （返回是否需要执行默认点击事件） 默认 YES
 *
 * @param   userData        当前点击的头像所指向的用户资料
 */
- (BOOL)avatarDidSelected:(id<EaseUserData>)userData;

/**
 * 头像长按事件 （返回是否需要执行默认长按事件） 默认 YES
 *
 * @param   userData        当前长按的头像所指向的用户资料
 */
- (BOOL)avatarDidLongPress:(id<EaseUserData>)userData;

/**
 * 群通知回执详情 （返回是否需要默认回执详情页）默认 YES
 *
 * @param   message        当前去通知消息
 * @param   groupId        当前消息所属群ID
 */
- (BOOL)groupMessageReadReceiptDetail:(EMMessage*)message groupId:(NSString*)groupId;

/**
 * 自定义cell
 */
- (UITableViewCell *)cellForItem:(UITableView *)tableView messageModel:(EaseMessageModel *)messageModel;
/**
 * 当前所长按的 自定义cell 的扩展区数据模型组
 *
 * @param   defaultLongPressItems       默认长按扩展区功能数据模型组
 * @param   customCell                               当前长按的自定义cell
 */
- (NSMutableArray<EaseExtMenuModel*>*)customCellLongPressExtMenuItemArray:(NSMutableArray<EaseExtMenuModel*>*)defaultLongPressItems customCell:(UITableViewCell*)customCell;


/*输入区回调*/

/**
 * 当前会话输入扩展区数据模型组
 *
 * @param   defaultInputBarItems        默认功能数据模型组
 * @param   conversationType                 当前会话类型：单聊，群聊，聊天室
 */
- (NSMutableArray<EaseExtMenuModel*>*)inputBarExtMenuItemArray:(NSMutableArray<EaseExtMenuModel*>*)defaultInputBarItems conversationType:(EMConversationType)conversationType;
/**
 * 输入区键盘输入变化回调  例：@群成员
 */
- (void)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
/**
 * 对方输入状态（单聊可用）
 */
- (void)isEditing:(BOOL)isEditing;


/* 消息事件回调 */

/**
 * 消息点击事件 （返回是否需要执行默认点击事件） 默认 YES
 *
 * @param   message          当前点击的消息
 * @param   userData        当前点击的消息携带的用户资料
 */
- (BOOL)didSelectMessageItem:(EMMessage*)message userData:(id<EaseUserData>)userData;

/**
 * 当前所长按消息的扩展区数据模型组
 *
 * @param   defaultLongPressItems       默认长按扩展区功能数据模型组
 * @param   message                                      当前长按的消息
 */
- (NSMutableArray<EaseExtMenuModel*>*)messageLongPressExtMenuItemArray:(NSMutableArray<EaseExtMenuModel*>*)defaultLongPressItems message:(EMMessage*)message;

@end

NS_ASSUME_NONNULL_END
