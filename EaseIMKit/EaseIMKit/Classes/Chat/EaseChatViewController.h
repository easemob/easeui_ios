//
//  EaseChatViewController.h
//  EaseIM
//
//  Created by XieYajie on 2019/1/18.
//  Update © 2020 zhangchong. All rights reserved.
//

#import "EMChatBar.h"
#import "EaseHeaders.h"
#import "EaseChatViewModel.h"
#import "EaseChatViewControllerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface EaseChatViewController : UIViewController <UIDocumentInteractionControllerDelegate>

@property (nonatomic, weak) id<EaseChatViewControllerProtocol> delegate;

@property (nonatomic, strong) EMConversation *currentConversation;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic) NSTimeInterval msgTimelTag;   //消息时间格式化

//实例化聊天控制器
- (instancetype)initWithCoversationid:(NSString *)conversationId conversationType:(EMConversationType)conType chatViewModel:(EaseChatViewModel *)viewModel;
//重置聊天控制器
- (void)resetChatVCWithViewModel:(EaseChatViewModel *)viewModel;

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
