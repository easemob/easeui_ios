//
//  EMChatViewController.m
//  EaseIM
//
//  Update by zhangchong on 2020/2.
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
    EMMessageCell *_currentLongPressCell;
    BOOL _isReloadViewWithModel; //重新刷新会话页面
}
@property (nonatomic, strong) NSString *moreMsgId;  //第一条消息的消息id
@property (nonatomic, strong) EMMoreFunctionView *longPressView;
@end

@implementation EMChatViewController

- (instancetype)initWithCoversationid:(NSString *)conversationId conversationType:(EMConversationType)conType chatViewModel:(EMViewModel *)viewModel
{
    self = [super init];
    if (self) {
        _currentConversation = [EMClient.sharedClient.chatManager getConversation:conversationId type:conType createIfNotExist:NO];
        _msgQueue = dispatch_queue_create("emmessage.com", NULL);
        _viewModel = viewModel;
        _isReloadViewWithModel = NO;
        if (!_viewModel) {
            _viewModel = [[EMViewModel alloc]init];
        }
    }
    return self;
}

- (void)resetChatVCWithViewModel:(EMViewModel *)viewModel
{
    _viewModel = viewModel;
    _isReloadViewWithModel = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshTableView];
    });
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
    [self.longPressView removeFromSuperview];
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
    self.view.backgroundColor = kColor_chatViewBg;
    
    self.chatBar = [[EMChatBar alloc] initWithViewModel:_viewModel];
    self.chatBar.delegate = self;
    [self.view addSubview:self.chatBar];
    [self.chatBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    //会话工具栏
    [self _setupChatBarMoreViews];
    
    self.tableView.backgroundColor = _viewModel.chatViewBgColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 130;
    [self.view addSubview:self.tableView];
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        /*if (self.currentConversation.type == EMConversationTypeGroupChat && _viewModel.chatViewHeight > 0) {
            make.height.equalTo(@(_viewModel.chatViewHeight));
        } else {
            make.top.equalTo(self.view);
        }*/
        make.height.equalTo(@(_viewModel.chatViewHeight));
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
    NSMutableArray<UIImage*> *toolbarImgArray = nil;
    NSMutableArray<NSString*> *toolbarDescArray = nil;
    BOOL isCustomExtFuncItems = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatBarExtFunctionItemDescArray)]) {
        toolbarDescArray = [self.delegate chatBarExtFunctionItemDescArray];
        isCustomExtFuncItems = YES;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatBarExtFunctionItemImgArray)]) {
        toolbarImgArray = [self.delegate chatBarExtFunctionItemImgArray];
        isCustomExtFuncItems = YES;
    }
    EMMoreFunctionView *moreFunction = [[EMMoreFunctionView alloc]initWithConversation:_currentConversation itemDescArray:toolbarDescArray itemImgArray:toolbarImgArray isCustom:isCustomExtFuncItems];
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
            if ([model.message.from isEqualToString:EMClient.sharedClient.currentUsername]) {
                cellString = @"您撤回一条消息";
            } else {
                cellString = @"对方撤回一条消息";
            }
        }
            
        if (model.type == EMMessageTypeExtNewFriend || model.type == EMMessageTypeExtAddGroup)
            cellString = ((EMTextMessageBody *)(model.message.body)).text;
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
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellForItem:messageModel:)]) {
        return [self.delegate cellForItem:tableView messageModel:model];
    }
    NSString *identifier = [EMMessageCell cellIdentifierWithDirection:model.direction type:model.type];
    EMMessageCell *cell = (EMMessageCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    // Configure the cell...
    if (cell == nil || _isReloadViewWithModel == YES) {
        _isReloadViewWithModel = NO;
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
    [self.longPressView removeFromSuperview];
    [self resetCellLongPressStatus:_currentLongPressCell];
}

#pragma mark - EMChatBarDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)]) {
        [self.delegate textView:textView shouldChangeTextInRange:range replacementText:text];
        return YES;
    }
    return NO;
}

- (void)chatBarSendMsgAction:(NSString *)text
{
    if ((text.length > 0 && ![text isEqualToString:@""])) {
        [self sendTextAction:text ext:nil];
        [self.chatBar clearInputViewText];
    }
}

- (void)chatBarDidShowMoreViewAction
{
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.chatBar.mas_top);
    }];
    
    [self performSelector:@selector(scrollToBottomRow) withObject:nil afterDelay:0.1];
}

#pragma mark - EMMoreFunctionViewDelegate

- (void)chatBarMoreFunctionAction:(NSInteger)componentTag itemDesc:(NSString *)itemDesc extType:(ExtType)extType
{
    [self resetCellLongPressStatus:_currentLongPressCell];
    [self.longPressView removeFromSuperview];
    //输入功能区
    if (extType == ExtTypeChatBar) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(extChatBarFuncActionItem:itemDesc:)]) {
            [self.delegate extChatBarFuncActionItem:componentTag itemDesc:itemDesc];
            return;
        }
        //default
        //[self chatToolBarComponentAction:componentTag];
    }
    //消息长按功能区
    if (extType == ExtTypeLongPress) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(extLongPressFuncActionItem:itemDesc:)]) {
            [self.delegate extLongPressFuncActionItem:componentTag itemDesc:itemDesc];
            return;
        }
        //default
        [self executeAction:componentTag];
    }
}

//隐藏某些item
- (NSArray<NSString*>*)hideItem:(NSArray<NSString*>*)itemList extType:(ExtType)extType
{
    //消息长按功能区
    if (extType == ExtTypeLongPress) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(hideItem:)]) {
            return [self.delegate hideItem:itemList];
        }
    }
    return [[NSArray<NSString*> alloc]init];
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
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectItem:)]) {
        [self.delegate didSelectItem:aCell.model];
        return;
    }
    //消息事件策略分类
    EMMessageEventStrategy *eventStrategy = [EMMessageEventStrategyFactory getStratrgyImplWithMsgCell:aCell];
    eventStrategy.chatController = self;
    [eventStrategy messageCellEventOperation:aCell];
}
//消息长按事件
- (void)messageCellDidLongPress:(UITableViewCell *)aCell
{
    self.longPressIndexPath = [self.tableView indexPathForCell:aCell];
    NSMutableArray<UIImage*> *longPressImgArray = nil;
    NSMutableArray<NSString*> *longPressDescArray = nil;
    BOOL isCustomExtFuncItems = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(longPressExtItemDescArray)]) {
        longPressDescArray = [self.delegate longPressExtItemDescArray];
        isCustomExtFuncItems = YES;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(longPressExtItemImgArray)]) {
        longPressImgArray = [self.delegate longPressExtItemImgArray];
        isCustomExtFuncItems = YES;
    }
    self.longPressView = [[EMMoreFunctionView alloc]initWithData:longPressDescArray itemImgArray:longPressImgArray isCustom:isCustomExtFuncItems];
    self.longPressView.delegate = self;
    CGSize longPressViewsize = [self.longPressView getExtViewSize];
    self.longPressView.layer.cornerRadius = 8;
    UIWindow *win = [[[UIApplication sharedApplication] windows] firstObject];
    [win addSubview:self.longPressView];
    CGRect rect = [aCell convertRect:aCell.bounds toView:nil];
    CGFloat maxWidth = self.view.frame.size.width;
    CGFloat maxHeight = self.tableView.frame.size.height;
    CGFloat xOffset = 0;
    if ([aCell isKindOfClass:[EMMessageCell class]]) {
        _currentLongPressCell = (EMMessageCell*)aCell;
        if (_currentLongPressCell.model.direction == EMMessageDirectionSend) {
            xOffset = (maxWidth - _viewModel.avatarLength - 2*componentSpacing - _currentLongPressCell.bubbleView.frame.size.width/2) - (longPressViewsize.width/2);
            if ((xOffset + longPressViewsize.width) > (maxWidth - componentSpacing)) {
                xOffset = maxWidth - componentSpacing - longPressViewsize.width;
            }
        }
        if (_currentLongPressCell.model.direction == EMMessageDirectionReceive) {
            xOffset = (_viewModel.avatarLength + 2*componentSpacing + _currentLongPressCell.bubbleView.frame.size.width/2) - (longPressViewsize.width/2);
            if (xOffset < componentSpacing) {
                xOffset = componentSpacing;
            }
        }
    } else {
        xOffset = maxWidth / 2 - longPressViewsize.width / 2;
    }
    
    CGFloat yOffset = rect.origin.y - longPressViewsize.height - 2;
    //顶部界线
    CGFloat topBoundary = _viewModel.chatViewHeight > 0 ? ([UIScreen mainScreen].bounds.size.height - _viewModel.chatViewHeight - self.chatBar.frame.size.height) : [self bangScreenSize];
    if (yOffset < topBoundary) {
        yOffset = topBoundary;
        if ((yOffset + longPressViewsize.height) > rect.origin.y) {
            yOffset = rect.origin.y + rect.size.height + 2;
        }
        if ([aCell isKindOfClass:[EMMessageCell class]]) {
            EMMessageCell *cell = (EMMessageCell *)aCell;
            if (cell.bubbleView.frame.size.height > (maxHeight - longPressViewsize.height - 4)) {
                yOffset = maxHeight / 2;
            }
        } else {
            if (aCell.frame.size.height > (maxHeight - longPressViewsize.height - 4)) {
                yOffset = maxHeight / 2;
            }
        }
    }
    self.longPressView.frame = CGRectMake(xOffset, yOffset, longPressViewsize.width, longPressViewsize.height);
}
//刘海屏刘海高度
- (CGFloat)bangScreenSize {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return 0;
    }
    CGSize size = [UIScreen mainScreen].bounds.size;
    NSInteger notchValue = size.width / size.height * 100;
    if (216 == notchValue || 46 == notchValue) {
        return 34;
    }
    return 0;
}
    
- (void)messageCellDidResend:(EMMessageModel *)aModel
{
    if (aModel.message.status != EMMessageStatusFailed && aModel.message.status != EMMessageStatusPending) {
        return;
    }
    
    __weak typeof(self) weakself = self;
    [[[EMClient sharedClient] chatManager] resendMessage:aModel.message progress:nil completion:^(EMMessage *message, EMError *error) {
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
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.dataArray addObjectsFromArray:formated];
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
                if ([model.message.messageId isEqualToString:msg.messageId]) {
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
                if ([model.message.messageId isEqualToString:aMessage.messageId]) {
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
        [self.longPressView removeFromSuperview];
        [self resetCellLongPressStatus:_currentLongPressCell];
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
        EMMessageModel *model = nil;
        model = [[EMMessageModel alloc] initWithEMMessage:msg];
        if (!model) {
            model = [[EMMessageModel alloc]init];
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(userData:)]) {
            id<EaseUserData> userData = [self.delegate userData:msg];
            model.userDataDelegate = userData;
        }
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
    //是否从服务器拉取历史消息
    if (self.delegate && [self.delegate respondsToSelector:@selector(isFetchHistoryMessagesFromServer)]) {
        if ([self.delegate isFetchHistoryMessagesFromServer]) {
            [EMClient.sharedClient.chatManager asyncFetchHistoryMessagesFromServer:self.currentConversation.conversationId conversationType:self.currentConversation.type startMessageId:self.moreMsgId pageSize:50 completion:^(EMCursorResult *aResult, EMError *aError) {
                block(aResult.list, aError);
                return;
             }];
        }
    }
    [self.currentConversation loadMessagesStartFromId:self.moreMsgId count:50 searchDirection:EMMessageSearchDirectionUp completion:block];
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
        _tableView.backgroundColor = [UIColor systemPinkColor];
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
