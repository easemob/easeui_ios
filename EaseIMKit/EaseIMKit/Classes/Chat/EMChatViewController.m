//
//  EMChatViewController.m
//  EaseIM
//
//  Created by XieYajie on 2019/1/18.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <AVKit/AVKit.h>
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "EMChatViewController.h"
#import "EMImageBrowser.h"
#import "EMDateHelper.h"
#import "EMMessageModel.h"
#import "EMMessageCell.h"
#import "EMAudioPlayerUtil.h"
#import "EMMessageTimeCell.h"
#import "EMMsgTouchIncident.h"
#import "EMChatViewController+EMMsgLongPressIncident.h"
#import "EMChatViewController+ChatToolBarIncident.h"

#import "EMConversation+EaseUI.h"
#import "EMSingleChatViewController.h"
#import "EMGroupChatViewController.h"
#import "EMChatroomViewController.h"
#import "UITableView+Refresh.h"

@interface EMChatViewController ()<UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, EMChatManagerDelegate, EMChatBarDelegate, EMMessageCellDelegate, EMChatBarEmoticonViewDelegate, EMChatBarRecordAudioViewDelegate,EMMoreFunctionViewDelegate>
{
    EMViewModel *_viewModel;
}
@property (nonatomic, strong) NSString *moreMsgId;  //第一条消息的消息id
@end

@implementation EMChatViewController

- (instancetype)initWithCoversationid:(NSString *)conversationId conversationType:(EMConversationType)conType chatViewModel:(EMViewModel *)viewModel
{
    self = [super init];
    if (self) {
        _currentConversation = [EMClient.sharedClient.chatManager getConversation:conversationId type:conType createIfNotExist:NO];
        _msgQueue = dispatch_queue_create("emmessage.com", NULL);
        _viewModel = viewModel;
        if (!_viewModel) {
            _viewModel = [[EMViewModel alloc]init];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.msgTimelTag = -1;
    [self _setupChatSubviews];
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
 
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapTableViewAction:)];
    [self.tableView addGestureRecognizer:tap];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self tableViewDidTriggerHeaderRefresh];
    [self.currentConversation markAllMessagesAsRead:nil];
    //抛出消息全部已读回调
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    //草稿
    if (![[self.currentConversation draft] isEqualToString:@""]) {
        self.chatBar.textView.text = [self.currentConversation draft];
        [self.chatBar textChangedExt];
        [self.currentConversation setDraft:@""];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[EMAudioPlayerUtil sharedHelper] stopPlayer];
    if (self.currentConversation.type == EMChatTypeChatRoom) {
        [[EMClient sharedClient].roomManager leaveChatroom:self.currentConversation.conversationId completion:nil];
    } else {
        //草稿
        if (self.chatBar.textView.text.length > 0) {
            [self.currentConversation setDraft:self.chatBar.textView.text];
        }
    }
}

- (void)dealloc
{
    [[EMClient sharedClient].chatManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Subviews

- (void)_setupChatSubviews
{
    self.view.backgroundColor = _viewModel.chatViewBgColor;
    
    self.chatBar = [[EMChatBar alloc] initWithViewModel:_viewModel];
    self.chatBar.delegate = self;
    [self.view addSubview:self.chatBar];
    [self.chatBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    [self.chatBar.sendBtn addTarget:self action:@selector(_sendText) forControlEvents:UIControlEventTouchUpInside];
    //会话工具栏
    [self _setupChatBarMoreViews];
    
    self.tableView.backgroundColor = kColor_LightGray;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 130;
    [self.view addSubview:self.tableView];
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.chatBar.mas_top);
    }];
}

- (void)_setupChatBarMoreViews
{
    //语音
    NSString *path = [self getAudioOrVideoPath];
    EMChatBarRecordAudioView *recordView = [[EMChatBarRecordAudioView alloc] initWithRecordPath:path];
    recordView.delegate = self;
    self.chatBar.recordAudioView = recordView;
    //表情
    EMChatBarEmoticonView *moreEmoticonView = [[EMChatBarEmoticonView alloc] init];
    moreEmoticonView.delegate = self;
    self.chatBar.moreEmoticonView = moreEmoticonView;
    
    //更多
    EMMoreFunctionView *moreFunction = [[EMMoreFunctionView alloc]initWithConversation:self.currentConversation];
    moreFunction.delegate = self;
    self.chatBar.moreFunctionView = moreFunction;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id obj = [self.dataArray objectAtIndex:indexPath.row];
    NSString *cellString = nil;
    if ([obj isKindOfClass:[NSString class]])
        cellString = (NSString *)obj;
    if ([obj isKindOfClass:[EMMessageModel class]]) {
        EMMessageModel *model = (EMMessageModel *)obj;
        if (model.type == EMMessageTypeExtRecall) {
            if ([model.emModel.from isEqualToString:EMClient.sharedClient.currentUsername]) {
                cellString = @"您撤回一条消息";
            } else {
                cellString = @"对方撤回一条消息";
            }
        }
            
        if (model.type == EMMessageTypeExtNewFriend || model.type == EMMessageTypeExtAddGroup)
            cellString = ((EMTextMessageBody *)(model.emModel.body)).text;
    }
    
    if ([cellString length] > 0) {
        EMMessageTimeCell *cell = (EMMessageTimeCell *)[tableView dequeueReusableCellWithIdentifier:@"EMMessageTimeCell"];
        // Configure the cell...
        if (cell == nil) {
            cell = [[EMMessageTimeCell alloc] initWithViewModel:_viewModel];
        }
        cell.timeLabel.text = cellString;
        return cell;
    }
    
    EMMessageModel *model = (EMMessageModel *)obj;
    NSString *identifier = [EMMessageCell cellIdentifierWithDirection:model.direction type:model.type];
    EMMessageCell *cell = (EMMessageCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    // Configure the cell...
    if (cell == nil) {
        cell = [[EMMessageCell alloc] initWithDirection:model.direction type:model.type viewModel:_viewModel];
        cell.delegate = self;
    }
    cell.model = model;
    return cell;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
    [self.chatBar clearMoreViewAndSelectedButton];
}

#pragma mark - EMChatBarDelegate

- (void)chatBarDidShowMoreViewAction
{
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.chatBar.mas_top);
    }];
    
    [self performSelector:@selector(scrollToBottomRow) withObject:nil afterDelay:0.1];
}

#pragma mark - EMMoreFunctionViewDelegate

- (void)chatBarMoreFunctionAction:(NSInteger)componentType
{
    [self chatToolBarComponentAction:componentType];
}

#pragma mark - EMChatBarRecordAudioViewDelegate

- (void)chatBarRecordAudioViewStopRecord:(NSString *)aPath
                              timeLength:(NSInteger)aTimeLength
{
    EMVoiceMessageBody *body = [[EMVoiceMessageBody alloc] initWithLocalPath:aPath displayName:@"audio"];
    body.duration = (int)aTimeLength;
    if(body.duration < 1){
        [self showHint:@"说话时间太短"];
        return;
    }
    [self sendMessageWithBody:body ext:nil isUpload:YES];
}

#pragma mark - EMChatBarEmoticonViewDelegate

- (void)didSelectedTextDetele
{
    [self.chatBar deleteTailText];
}

- (void)didSelectedEmoticonModel:(EMEmoticonModel *)aModel
{
    if (aModel.type == EMEmotionTypeEmoji)
        [self.chatBar inputViewAppendText:aModel.name];
    
    if (aModel.type == EMEmotionTypeGif) {
        NSDictionary *ext = @{MSG_EXT_GIF:@(YES), MSG_EXT_GIF_ID:aModel.eId};
        [self sendTextAction:aModel.name ext:ext];
    }
}

#pragma mark - EMMessageCellDelegate

- (void)messageCellDidSelected:(EMMessageCell *)aCell
{
    //消息事件策略分类
    EMMessageEventStrategy *eventStrategy = [EMMessageEventStrategyFactory getStratrgyImplWithMsgCell:aCell];
    eventStrategy.chatController = self;
    [eventStrategy messageCellEventOperation:aCell];
}

- (void)messageCellDidLongPress:(EMMessageCell *)aCell
{
    self.menuIndexPath = [self.tableView indexPathForCell:aCell];
}

- (void)messageCellDidResend:(EMMessageModel *)aModel
{
    if (aModel.emModel.status != EMMessageStatusFailed && aModel.emModel.status != EMMessageStatusPending) {
        return;
    }
    
    __weak typeof(self) weakself = self;
    [[[EMClient sharedClient] chatManager] resendMessage:aModel.emModel progress:nil completion:^(EMMessage *message, EMError *error) {
        [weakself.tableView reloadData];
    }];
    
    [self.tableView reloadData];
}

#pragma mark -- UIDocumentInteractionControllerDelegate
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return self;
}
- (UIView*)documentInteractionControllerViewForPreview:(UIDocumentInteractionController*)controller
{
    return self.view;
}
- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController*)controller
{
    return self.view.frame;
}

#pragma mark - EMChatManagerDelegate

- (void)messagesDidReceive:(NSArray *)aMessages
{
    __weak typeof(self) weakself = self;
    dispatch_async(self.msgQueue, ^{
        NSString *conId = weakself.currentConversation.conversationId;
        NSMutableArray *msgArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < [aMessages count]; i++) {
            EMMessage *msg = aMessages[i];
            if (![msg.conversationId isEqualToString:conId])
                continue;
            [weakself returnReadReceipt:msg];
            [weakself.currentConversation markMessageAsReadWithId:msg.messageId error:nil];
            [msgArray addObject:msg];
        }
        
        NSArray *formated = [weakself formatMessages:msgArray];
        [weakself.dataArray addObjectsFromArray:formated];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself refreshTableView];
        });
    });
}

- (void)messagesDidRecall:(NSArray *)aMessages {
    [aMessages enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        EMMessage *msg = (EMMessage *)obj;
        [self.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[EMMessageModel class]]) {
                EMMessageModel *model = (EMMessageModel *)obj;
                if ([model.emModel.messageId isEqualToString:msg.messageId]) {
                    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:@"对方撤回一条消息"];
                    NSString *to = [[EMClient sharedClient] currentUsername];
                    NSString *from = self.currentConversation.conversationId;
                    EMMessage *message = [[EMMessage alloc] initWithConversationID:from from:from to:to body:body ext:@{MSG_EXT_RECALL:@(YES)}];
                    message.chatType = (EMChatType)self.currentConversation.type;
                    message.isRead = YES;
                    message.messageId = msg.messageId;
                    message.localTime = msg.localTime;
                    message.timestamp = msg.timestamp;
                    [self.currentConversation insertMessage:message error:nil];
                    EMMessageModel *replaceModel = [[EMMessageModel alloc]initWithEMMessage:message];
                    [self.dataArray replaceObjectAtIndex:idx withObject:replaceModel];
                }
            }
        }];
    }];
    [self.tableView reloadData];
}

//为了从会话列表切进来触发 群组阅读回执 或 消息已读回执
- (void)sendDidReadReceipt
{
    __weak typeof(self) weakself = self;
    NSString *conId = self.currentConversation.conversationId;
    void (^block)(NSArray *aMessages, EMError *aError) = ^(NSArray *aMessages, EMError *aError) {
        if (!aError && [aMessages count]) {
            for (int i = 0; i < [aMessages count]; i++) {
                EMMessage *msg = aMessages[i];
                if (![msg.conversationId isEqualToString:conId]) {
                    continue;
                }
                [weakself returnReadReceipt:msg];
                [weakself.currentConversation markMessageAsReadWithId:msg.messageId error:nil];
            }
        }
    };
    [self.currentConversation loadMessagesStartFromId:self.moreMsgId count:self.currentConversation.unreadMessagesCount searchDirection:EMMessageSearchDirectionUp completion:block];
}

- (void)messageStatusDidChange:(EMMessage *)aMessage
                         error:(EMError *)aError
{
    __weak typeof(self) weakself = self;
    dispatch_async(self.msgQueue, ^{
        NSString *conId = self.currentConversation.conversationId;
        if (![conId isEqualToString:aMessage.conversationId]){
            return ;
        }
        
        __block NSUInteger index = NSNotFound;
        __block EMMessageModel *reloadModel = nil;
        [self.dataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[EMMessageModel class]]) {
                EMMessageModel *model = (EMMessageModel *)obj;
                if ([model.emModel.messageId isEqualToString:aMessage.messageId]) {
                    reloadModel = model;
                    index = idx;
                    *stop = YES;
                }
            }
        }];
        
        if (index != NSNotFound) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself.dataArray replaceObjectAtIndex:index withObject:reloadModel];
                [weakself.tableView beginUpdates];
                [weakself.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                [weakself.tableView endUpdates];
            });
        }
        
    });
}

#pragma mark - KeyBoard

- (void)keyBoardWillShow:(NSNotification *)note
{
    // 获取用户信息
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:note.userInfo];
    // 获取键盘高度
    CGRect keyBoardBounds  = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyBoardHeight = keyBoardBounds.size.height;
    // 获取键盘动画时间
    CGFloat animationTime  = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    // 定义好动作
    void (^animation)(void) = ^void(void) {
        [self.chatBar mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).offset(-keyBoardHeight);
        }];
    };
    
    if (animationTime > 0) {
        [UIView animateWithDuration:animationTime animations:animation completion:^(BOOL finished) {
            [self scrollToBottomRow];
        }];
    } else {
        animation();
    }
}

- (void)keyBoardWillHide:(NSNotification *)note
{
    // 获取用户信息
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:note.userInfo];
    // 获取键盘动画时间
    CGFloat animationTime  = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    // 定义好动作
    void (^animation)(void) = ^void(void) {
        [self.chatBar mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view);
        }];
    };
    
    if (animationTime > 0) {
        [UIView animateWithDuration:animationTime animations:animation];
    } else {
        animation();
    }
}

#pragma mark - Gesture Recognizer

//点击消息列表，收起更多功能区
- (void)handleTapTableViewAction:(UITapGestureRecognizer *)aTap
{
    if (aTap.state == UIGestureRecognizerStateEnded) {
        [self.view endEditing:YES];
        [self.chatBar clearMoreViewAndSelectedButton];
    }
}

- (void)scrollToBottomRow
{
    NSInteger toRow = -1;
    if ([self.dataArray count] > 0) {
        toRow = self.dataArray.count - 1;
        NSIndexPath *toIndexPath = [NSIndexPath indexPathForRow:toRow inSection:0];
        [self.tableView scrollToRowAtIndexPath:toIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

#pragma mark - Send Message

- (void)_sendText
{
    if(self.chatBar.sendBtn.tag == 1){
        [self sendTextAction:self.chatBar.textView.text ext:nil];
    }
}

- (void)sendTextAction:(NSString *)aText
                    ext:(NSDictionary *)aExt
{
    if(![aExt objectForKey:MSG_EXT_GIF]){
        [self.chatBar clearInputViewText];
    }
    if ([aText length] == 0) {
        return;
    }
    
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:aText];
    [self sendMessageWithBody:body ext:aExt isUpload:NO];
}

#pragma mark - Data

- (NSArray *)formatMessages:(NSArray<EMMessage *> *)aMessages
{
    NSMutableArray *formated = [[NSMutableArray alloc] init];

    for (int i = 0; i < [aMessages count]; i++) {
        EMMessage *msg = aMessages[i];
        if (msg.chatType == EMChatTypeChat && msg.isReadAcked && (msg.body.type == EMMessageBodyTypeText || msg.body.type == EMMessageBodyTypeLocation)) {
            [[EMClient sharedClient].chatManager sendMessageReadAck:msg.messageId toUser:msg.conversationId completion:nil];
        }
        
        CGFloat interval = (self.msgTimelTag - msg.timestamp) / 1000;
        if (self.msgTimelTag < 0 || interval > 60 || interval < -60) {
            NSString *timeStr = [EMDateHelper formattedTimeFromTimeInterval:msg.timestamp];
            [formated addObject:timeStr];
            self.msgTimelTag = msg.timestamp;
        }
        
        EMMessageModel *model = [[EMMessageModel alloc] initWithEMMessage:msg];

        [formated addObject:model];
    }
    
    return formated;
}

- (void)tableViewDidTriggerHeaderRefresh
{
    __weak typeof(self) weakself = self;
    void (^block)(NSArray *aMessages, EMError *aError) = ^(NSArray *aMessages, EMError *aError) {
        if (!aError && [aMessages count]) {
            EMMessage *msg = aMessages[0];
            weakself.moreMsgId = msg.messageId;
            
            dispatch_async(self.msgQueue, ^{
                NSArray *formated = [weakself formatMessages:aMessages];
                [weakself.dataArray insertObjects:formated atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [formated count])]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (weakself.tableView.isRefreshing) {
                        [weakself.tableView endRefreshing];
                    }
                    [weakself refreshTableView];
                });
            });
        } else {
            if (weakself.tableView.isRefreshing) {
                [weakself.tableView endRefreshing];
            }
        }
    };

    if(self.currentConversation.unreadMessagesCount > 0){
        [self sendDidReadReceipt];
    }
    
    if ([EMDemoOptions sharedOptions].isPriorityGetMsgFromServer) {
        [EMClient.sharedClient.chatManager asyncFetchHistoryMessagesFromServer:self.currentConversation.conversationId conversationType:self.currentConversation.type startMessageId:self.moreMsgId pageSize:50 completion:^(EMCursorResult *aResult, EMError *aError) {
            block(aResult.list, aError);
         }];
    } else {
        [self.currentConversation loadMessagesStartFromId:self.moreMsgId count:50 searchDirection:EMMessageSearchDirectionUp completion:block];
    }
}

#pragma mark - Action

//发送消息体
- (void)sendMessageWithBody:(EMMessageBody *)aBody
                         ext:(NSDictionary * __nullable)aExt
                    isUpload:(BOOL)aIsUpload
{
    if (!([EMClient sharedClient].options.isAutoTransferMessageAttachments) && aIsUpload) {
        return;
    }
    
    NSString *from = [[EMClient sharedClient] currentUsername];
    NSString *to = self.currentConversation.conversationId;
    EMMessage *message = [[EMMessage alloc] initWithConversationID:to from:from to:to body:aBody ext:aExt];
    
    //是否需要发送阅读回执
    if([aExt objectForKey:MSG_EXT_READ_RECEIPT])
        message.isNeedGroupAck = YES;
    
    message.chatType = (EMChatType)self.currentConversation.type;
    
    __weak typeof(self) weakself = self;
    NSArray *formated = [weakself formatMessages:@[message]];
    [self.dataArray addObjectsFromArray:formated];
    if (!self.moreMsgId)
        //新会话的第一条消息
        self.moreMsgId = message.messageId;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakself refreshTableView];
    });
    [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:^(EMMessage *message, EMError *error) {
        [weakself messageStatusDidChange:message error:error];
    }];
}

#pragma mark - Public

- (void)returnReadReceipt:(EMMessage *)msg{}

- (void)refreshTableView
{
    [self.tableView reloadData];
    [self.tableView setNeedsLayout];
    [self.tableView layoutIfNeeded];
    [self scrollToBottomRow];
}

#pragma mark - getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.tableFooterView = [UIView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = 60;
        [_tableView enableRefresh:@"下拉刷新" color:UIColor.redColor];
        [_tableView.refreshControl addTarget:self action:@selector(tableViewDidTriggerHeaderRefresh) forControlEvents:UIControlEventValueChanged];
    }
    
    return _tableView;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];;
    }
    
    return _dataArray;
}

@end
