//
//  EaseConversationsViewController.m
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/10/29.
//

#import "EaseConversationsViewController.h"
#import "EMRealtimeSearch.h"
#import "EaseConversationModelUtil.h"
#import "UIViewController+Search.h"
#import "EaseConversationExtController.h"
#import "EMNotificationViewController.h"
#import "EMDateHelper.h"
#import "EaseHeaders.h"
#import "EaseConversationViewModel.h"
#import "EaseConversationVcDelegate.h"

@interface EaseConversationsViewController ()<EMContactManagerDelegate, EMChatManagerDelegate, EMGroupManagerDelegate, EMSearchControllerDelegate, EaseConversationsDelegate,EMNotificationsDelegate>
{
    EaseConversationViewModel *_viewModel;
    BOOL _isReloadViewWithModel; //重新刷新会话列表
}

@property (nonatomic, assign) id<EaseConversationVCDelegate> conversationVCDelegate;

@property (nonatomic) BOOL isViewAppear;
@property (nonatomic) BOOL isNeedReload;
@property (nonatomic) BOOL isNeedReloadSorted;
@property (nonatomic) BOOL isAddBlankView;

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) UIButton *addImageBtn;

@property (nonatomic, strong) UIView *blankPerchView;

@property (nonatomic) BOOL isNeedsSearchModule; //是否需要搜索组件

@property (nonatomic) BOOL isNeedsSystemNoti; //是否需要系统通知

@end

@implementation EaseConversationsViewController

- (instancetype)init{
    EaseConversationViewModel *viewModel = [[EaseConversationViewModel alloc]init];
    if (self = [super initWithModel:viewModel]) {
     _viewModel = viewModel;
     _isReloadViewWithModel = NO;
     _isNeedsSystemNoti = YES;
    }
    
    return self;
}

- (void)addDelegate:(id<EaseConversationVCDelegate>)aDelegate
{
    _conversationVCDelegate = aDelegate;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.isNeedsSearchModule = NO;
    self.isAddBlankView = NO;
    [self _setupSubviews];
    [[EMNotificationHelper shared] addDelegate:self];
    [[EMClient sharedClient].contactManager addDelegate:self delegateQueue:nil];
//    [self didNotificationsUnreadCountUpdate:[EMNotificationHelper shared].unreadCount];
    [[EMClient sharedClient].groupManager addDelegate:self delegateQueue:nil];
    [[EaseConversationModelUtil shared] addDelegate:self];
    [self _loadAllConversationsFromDBWithIsShowHud:YES];
    
    //本地通话记录
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(insertLocationCallRecord:) name:EMCOMMMUNICATE_RECORD object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGroupSubjectUpdated:) name:GROUP_SUBJECT_UPDATED object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AgreeJoinGroupInvite:) name:NOTIF_ADD_SOCIAL_CONTACT object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationControllerBack) name:SYSTEM_NOTIF_DETAIL object:nil];
}

- (void)resetViewModel:(EaseConversationViewModel *)viewModel{
    _viewModel = viewModel;
    _isReloadViewWithModel = YES;
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.isViewAppear = YES;
    if (self.isNeedReloadSorted) {
        self.isNeedReloadSorted = NO;
        [self _loadAllConversationsFromDBWithIsShowHud:NO];
    } else if (self.isNeedReload) {
        self.isNeedReload = NO;
        [self.tableView reloadData];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    self.isViewAppear = NO;
    self.isNeedReload = NO;
    self.isNeedReloadSorted = NO;
    [EMNotificationHelper shared].isCheckUnreadCount = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)dealloc
{
    [EMNotificationHelper shared].isCheckUnreadCount = YES;
    [[EMNotificationHelper shared] removeDelegate:self];
    [EMNotificationHelper destoryShared];
    [[EMClient sharedClient].contactManager removeDelegate:self];
    [[EMClient sharedClient].groupManager removeDelegate:self];
    [[EaseConversationModelUtil shared] removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    self.view.backgroundColor = _viewModel.viewBgColor;
    
    if (self.isNeedsSearchModule) {
        [self enableSearchController];
        [self.searchButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view);
            make.left.equalTo(self.view).offset(15);
            make.right.equalTo(self.view).offset(-15);
            make.height.equalTo(@36);
        }];
        [self _setupSearchResultController];
    }
    
    self.blankPerchView = _viewModel.blankPerchView;
    [self.view addSubview:self.blankPerchView];
    [self.blankPerchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(self.view);
        make.width.height.equalTo(@115);
    }];
    
    self.tableView.rowHeight = 74;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (self.isNeedsSearchModule) {
            make.top.equalTo(self.searchButton.mas_bottom).offset(15);
        } else {
            make.top.equalTo(self.view);
        }
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    if (self.conversationVCDelegate && ([self.conversationVCDelegate respondsToSelector:@selector(isNeedsSystemNotification)])) {
        _isNeedsSystemNoti = [self.conversationVCDelegate isNeedsSystemNotification];
        if (!_isNeedsSystemNoti) {
            [[EMNotificationHelper shared] removeDelegate:self];
        }
    }
}

//空白占位视图
- (void)addBlankPerchView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.dataArray count] <= 0 && !self.isAddBlankView) {
            //空会话列表占位视图
            self.isAddBlankView = YES;
            self.blankPerchView.hidden = NO;
        } else if ([self.dataArray count] > 0) {
            self.blankPerchView.hidden = YES;
            self.isAddBlankView = NO;
        }
    });
}

- (void)_setupSearchResultController
{
    __weak typeof(self) weakself = self;
    self.resultController.tableView.rowHeight = 60;
    [self.resultController setCellForRowAtIndexPathCompletion:^UITableViewCell *(UITableView *tableView, NSIndexPath *indexPath) {
        EaseConversationCell *cell = (EaseConversationCell *)[tableView dequeueReusableCellWithIdentifier:@"EaseConversationCell"];
        if (cell == nil || self->_isReloadViewWithModel == YES) {
            self->_isReloadViewWithModel = NO;
            cell = [[EaseConversationCell alloc] initWithConversationViewModel:self->_viewModel];
        }
        
        NSInteger row = indexPath.row;
        id<EaseConversationItemModelDelegate> model = [weakself.resultController.dataArray objectAtIndex:row];
        cell.conversationItemModel = model;
        return cell;
    }];
    [self.resultController setCanEditRowAtIndexPath:^BOOL(UITableView *tableView, NSIndexPath *indexPath) {
        return YES;
    }];
    [self.resultController setCommitEditingAtIndexPath:^(UITableView *tableView, UITableViewCellEditingStyle editingStyle, NSIndexPath *indexPath) {
        if (editingStyle != UITableViewCellEditingStyleDelete) {
            return ;
        }
        
        NSInteger row = indexPath.row;
        id<EaseConversationItemModelDelegate>model = (id<EaseConversationItemModelDelegate>)[weakself.resultController.dataArray objectAtIndex:row];
        [[EMClient sharedClient].chatManager deleteConversation:model.itemId isDeleteMessages:YES completion:nil];
        [weakself.resultController.dataArray removeObjectAtIndex:row];
        [weakself.resultController.tableView reloadData];
    }];
    [self.resultController setDidSelectRowAtIndexPathCompletion:^(UITableView *tableView, NSIndexPath *indexPath) {
        NSInteger row = indexPath.row;
        id<EaseConversationItemModelDelegate> model = [weakself.resultController.dataArray objectAtIndex:row];
        if (weakself.easeTableViewDelegate && [weakself.easeTableViewDelegate respondsToSelector:@selector(easeTableView:didSelectItem:)]) {
            [weakself.easeTableViewDelegate easeTableView:tableView didSelectItem:model];
            return;
        }
        weakself.resultController.searchBar.text = @"";
        [weakself.resultController.searchBar resignFirstResponder];
        weakself.resultController.searchBar.showsCancelButton = NO;
        [weakself searchBarCancelButtonAction:nil];
        [weakself.resultNavigationController dismissViewControllerAnimated:NO completion:nil];
        if (![model.itemId isEqualToString:EMSYSTEMNOTIFICATIONID]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:CHAT_PUSHVIEWCONTROLLER object:model];
        } else {
            EMNotificationViewController *controller = [[EMNotificationViewController alloc] initWithStyle:UITableViewStylePlain];
            [weakself.navigationController pushViewController:controller animated:NO];
        }
    }];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.easeTableViewDelegate && [self.easeTableViewDelegate respondsToSelector:@selector(easeTableView:heightForItem:)]) {
        return [self.easeTableViewDelegate easeTableView:tableView heightForItem:self.dataAry[indexPath.row]];
    }
    
    return 74;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EaseConversationCell *cell = (EaseConversationCell *)[tableView dequeueReusableCellWithIdentifier:@"EaseConversationCell"];
    if (cell == nil || _isReloadViewWithModel == YES) {
        _isReloadViewWithModel = NO;
        cell = [[EaseConversationCell alloc] initWithConversationViewModel:_viewModel];
    }
    
    id<EaseConversationItemModelDelegate> model = [self.dataArray objectAtIndex:indexPath.row];
    if (self.conversationVCDelegate && [self.conversationVCDelegate respondsToSelector:@selector(conversationCellForModel:)]) {
        id<EaseConversationCellModelDelegate> cellModel = [self.conversationVCDelegate conversationCellForModel:model];
        if (cellModel) {
            //不去处理用户返回的任何值
            model.defaultAvatar = cellModel.avatarImg;
            model.showName = cellModel.nickName;
        }
    }
    cell.conversationItemModel = model;
    [cell setSeparatorInset:UIEdgeInsetsMake(0, cell.avatarView.frame.size.height + 23, 0, 1)];

    if (model.isStick) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell setSelected:YES animated:NO];
        });
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    id<EaseConversationItemModelDelegate> model = [self.dataArray objectAtIndex:row];
    if (self.easeTableViewDelegate && [self.easeTableViewDelegate respondsToSelector:@selector(easeTableView:didSelectItem:)]) {
        [self.easeTableViewDelegate easeTableView:tableView didSelectItem:model];
        return;
    }
    __weak typeof(self) weakself = self;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (![model.itemId isEqualToString:EMSYSTEMNOTIFICATIONID]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CHAT_PUSHVIEWCONTROLLER object:model];
    } else {
        EMNotificationViewController *controller = [[EMNotificationViewController alloc] initWithStyle:UITableViewStylePlain];
        [weakself.navigationController pushViewController:controller animated:NO];
    }
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) API_UNAVAILABLE(tvos)
{
    id<EaseConversationItemModelDelegate> model = [self.dataArray objectAtIndex:indexPath.row];
    
    __weak typeof(self) weakself = self;
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"删除" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        [tableView setEditing:NO animated:YES];
        [weakself _deleteConversation:indexPath];
    }];
    deleteAction.backgroundColor = [UIColor colorWithRed: 253 / 255.0 green: 81 / 255.0 blue: 84 / 255.0 alpha:1.0];
    
    UIContextualAction *stickConversationAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"置顶" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        [tableView setEditing:NO animated:YES];
        [weakself _stickConversation:indexPath];
    }];
    stickConversationAction.backgroundColor = [UIColor colorWithRed: 203 / 255.0 green: 125 / 255.0 blue: 50 / 255.0 alpha:1.0];
    
    UIContextualAction *cancelStickConversationAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"取消置顶" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        [tableView setEditing:NO animated:YES];
        [weakself _cancelStickConversation:indexPath];
    }];
    cancelStickConversationAction.backgroundColor = [UIColor colorWithRed: 203 / 255.0 green: 125 / 255.0 blue: 50 / 255.0 alpha:1.0];
    
    UIContextualAction *customContextualAction = nil;
    if (self.conversationVCDelegate && [self.conversationVCDelegate respondsToSelector:@selector(sideslipCustomAction:dataArray:trailingSwipeActionsConfigurationForRowAtIndexPath:)]) {
        customContextualAction = [self.conversationVCDelegate sideslipCustomAction:tableView dataArray:self.dataArray trailingSwipeActionsConfigurationForRowAtIndexPath:indexPath];
    }
    
    NSMutableArray<UIContextualAction *> *sideslipArray = [[NSMutableArray alloc]init];
    [sideslipArray addObject:deleteAction];
    if(model.isStick) {
        [sideslipArray addObject:cancelStickConversationAction];
    } else {
        [sideslipArray addObject:stickConversationAction];
    }
    if (customContextualAction) {
        [sideslipArray addObject:customContextualAction];
    }
    
    UISwipeActionsConfiguration *actions = [UISwipeActionsConfiguration configurationWithActions:sideslipArray];
    actions.performsFirstActionWithFullSwipe = NO;
    return actions;
}

#pragma mark - EMChatManagerDelegate

- (void)messagesDidRecall:(NSArray *)aMessages {
    [self _loadAllConversationsFromDBWithIsShowHud:NO];
}
/*
- (void)conversationListDidUpdate:(NSArray *)aConversationList
{
    if (!self.isViewAppear) {
        self.isNeedReloadSorted = YES;
    } else {
        [self _loadAllConversationsFromDBWithIsShowHud:NO];
    }
}*/

- (void)messagesDidReceive:(NSArray *)aMessages
{
    if (self.isViewAppear) {
        if (!self.isNeedReload) {
            self.isNeedReload = YES;
            NSMutableArray<EMConversation *> *conversationList = [[NSMutableArray alloc]initWithCapacity:16];
            for (EMMessage *msg in aMessages) {
                EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:msg.conversationId type:EMConversationTypeGroupChat createIfNotExist:YES];
                if(msg.body.type == EMMessageBodyTypeText) {
                    //通话邀请
                    if ([((EMTextMessageBody *)msg.body).text isEqualToString:EMCOMMUNICATE_CALLINVITE]) {
                        [conversation deleteMessageWithId:msg.messageId error:nil];
                        continue;
                    }
                    //群聊@“我”提醒
                    NSString *content = [NSString stringWithFormat:@"@%@",EMClient.sharedClient.currentUsername];
                    if(conversation.type == EMConversationTypeGroupChat && [((EMTextMessageBody *)msg.body).text containsString:content]) {
                        [EaseConversationExtController groupChatAtOperate:conversation];
                    }
                }
                [conversationList addObject:conversation];
            }
            NSArray *models = [EaseConversationModelUtil modelsFromEMConversations:conversationList];
            [self.dataArray addObjectsFromArray:models];
            [self _reSortedConversationModelsAndReloadView];
        }
    } else {
        self.isNeedReload = YES;
    }
}

#pragma mark - EMGroupManagerDelegate

- (void)didLeaveGroup:(EMGroup *)aGroup
               reason:(EMGroupLeaveReason)aReason
{
    [[EMClient sharedClient].chatManager deleteConversation:aGroup.groupId isDeleteMessages:NO completion:nil];
}

#pragma mark - EMSearchControllerDelegate

- (void)searchBarWillBeginEditing:(UISearchBar *)searchBar
{
    self.resultController.searchKeyword = nil;
}

- (void)searchBarCancelButtonAction:(UISearchBar *)searchBar
{
    [[EMRealtimeSearch shared] realtimeSearchStop];
    
    if ([self.resultController.dataArray count] > 0)
        [self.resultController.dataArray removeAllObjects];
    [self.resultController.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.view endEditing:YES];
}

- (void)searchTextDidChangeWithString:(NSString *)aString
{
    self.resultController.searchKeyword = aString;
    
    __weak typeof(self) weakself = self;
    [[EMRealtimeSearch shared] realtimeSearchWithSource:self.dataArray searchText:aString collationStringSelector:@selector(name) resultBlock:^(NSArray *results) {
         dispatch_async(dispatch_get_main_queue(), ^{
            if ([weakself.resultController.dataArray count] > 0)
                [weakself.resultController.dataArray removeAllObjects];
            [weakself.resultController.dataArray addObjectsFromArray:results];
            [weakself.resultController.tableView reloadData];
        });
    }];
}

#pragma mark - EMConversationsDelegate

- (void)didConversationUnreadCountToZero:(id<EaseConversationItemModelDelegate>)aConversation
{
    NSInteger index = [self.dataArray indexOfObject:aConversation];
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

- (void)didResortConversationsLatestMessage
{
    [self _reSortedConversationModelsAndReloadView];
}

#pragma mark - EMContactManagerDelegate

//收到好友请求被同意/同意
- (void)friendshipDidAddByUser:(NSString *)aUsername
{
    [self notificationMsg:aUsername aUserName:aUsername conversationType:EMConversationTypeChat];
}

#pragma mark - EMGroupManagerDelegate

//群主同意用户A的入群申请后，用户A会接收到该回调
- (void)joinGroupRequestDidApprove:(EMGroup *)aGroup
{
    [self notificationMsg:aGroup.groupId aUserName:EMClient.sharedClient.currentUsername conversationType:EMConversationTypeGroupChat];
}

//有用户加入群组
- (void)userDidJoinGroup:(EMGroup *)aGroup
                    user:(NSString *)aUsername
{
    [self notificationMsg:aGroup.groupId aUserName:aUsername conversationType:EMConversationTypeGroupChat];
}

#pragma mark - noti

//本地通话记录
- (void)insertLocationCallRecord:(NSNotification*)noti
{
    [self _reSortedConversationModelsAndReloadView];
}

//加群邀请被同意
- (void)AgreeJoinGroupInvite:(NSNotification *)aNotif
{
    NSDictionary *dic = aNotif.object;
    [self notificationMsg:[dic objectForKey:CONVERSATION_ID] aUserName:[dic objectForKey:CONVERSATION_OBJECT] conversationType:EMConversationTypeGroupChat];
}

//加好友，加群 成功通知
- (void)notificationMsg:(NSString *)itemId aUserName:(NSString *)aUserName conversationType:(EMConversationType)aType
{
    EMConversationType conversationType = aType;
    EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:itemId type:conversationType createIfNotExist:YES];
    EMTextMessageBody *body;
    NSString *to = itemId;
    EMMessage *message;
    if (conversationType == EMChatTypeChat) {
        body = [[EMTextMessageBody alloc] initWithText:[NSString stringWithFormat:@"你与%@已经成为好友，开始聊天吧",aUserName]];
        message = [[EMMessage alloc] initWithConversationID:to from:EMClient.sharedClient.currentUsername to:to body:body ext:@{MSG_EXT_NEWNOTI:NOTI_EXT_ADDFRIEND}];
    } else if (conversationType == EMChatTypeGroupChat) {
        if ([aUserName isEqualToString:EMClient.sharedClient.currentUsername]) {
            body = [[EMTextMessageBody alloc] initWithText:@"你已加入本群，开始发言吧"];
        } else {
            body = [[EMTextMessageBody alloc] initWithText:[NSString stringWithFormat:@"%@ 加入了群聊",aUserName]];
        }
        message = [[EMMessage alloc] initWithConversationID:to from:aUserName to:to body:body ext:@{MSG_EXT_NEWNOTI:NOTI_EXT_ADDGROUP}];
    }
    message.chatType = (EMChatType)conversation.type;
    message.isRead = YES;
    [conversation insertMessage:message error:nil];
    
    //刷新dataArray & tableview
    [self _loadAllConversationsFromDBWithIsShowHud:(NO)];
}

#pragma mark - NSNotification

- (void)handleGroupSubjectUpdated:(NSNotification *)aNotif
{
    EMGroup *group = aNotif.object;
    if (!group) {
        return;
    }
    
    NSString *groupId = group.groupId;
    for (id<EaseConversationItemModelDelegate> model in self.dataArray) {
        id<EaseConversationItemModelDelegate>conversationModel = (id<EaseConversationItemModelDelegate>)model;
        if ([conversationModel.itemId isEqualToString:groupId]) {
            conversationModel.showName = group.groupName;
            [self.tableView reloadData];
        }
    }
}

//从系统通知页返回前的设置
- (void)notificationControllerBack
{
    self.isNeedReload = YES;
}

#pragma mark - EMNotificationsDelegate
/*
- (void)didNotificationsUnreadCountUpdate:(int)aUnreadCount
{
    EMNotificationHelper.shared.unreadCount = aUnreadCount;
    //系统通知可显示
    if ([EMDemoOptions sharedOptions].isVisibleOnConversationList == YES) {
        [self renewalSystemNotification];
        [self _reSortedConversationModelsAndReloadView];
    }
}*/

- (void)didNotificationsUpdate
{
    //是否已存在系统通知
    if ([EMDemoOptions sharedOptions].isVisibleOnConversationList == NO) {
        [self _loadAllConversationsFromDBWithIsShowHud:NO];
        [EMDemoOptions sharedOptions].isVisibleOnConversationList = YES;
        [EMDemoOptions.sharedOptions archive];
    } else {
        [self renewalSystemNotification];
        [self _reSortedConversationModelsAndReloadView];
    }
}

#pragma mark - UIMenuController

//删除会话
- (void)_deleteConversation:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    id<EaseConversationItemModelDelegate> model = [self.dataArray objectAtIndex:row];
    [[EMClient sharedClient].chatManager deleteConversation:model.itemId
                                           isDeleteMessages:YES
                                                 completion:nil];
    //更新系统通知存在状态
    if ([model.itemId isEqualToString:EMSYSTEMNOTIFICATIONID]) {
        [EMDemoOptions sharedOptions].isVisibleOnConversationList = NO;
        [EMDemoOptions.sharedOptions archive];
    }
    [self.dataArray removeObjectAtIndex:row];
    [self.tableView reloadData];
    [self addBlankPerchView];
}

//置顶
- (void)_stickConversation:(NSIndexPath *)indexPath
{
    id<EaseConversationItemModelDelegate> model = [self.dataArray objectAtIndex:indexPath.row];
    [EaseConversationExtController stickConversation:model];
    [self _reSortedConversationModelsAndReloadView];
}

//取消置顶
- (void)_cancelStickConversation:(NSIndexPath *)indexPath
{
    id<EaseConversationItemModelDelegate> model = [self.dataArray objectAtIndex:indexPath.row];
    [EaseConversationExtController cancelStickConversation:model];
    [self _reSortedConversationModelsAndReloadView];
}

#pragma mark - Data

//会话model置顶重排序
- (NSMutableArray *)_stickSortedConversationModels:(NSArray *)modelArray
{
    NSMutableArray *tempModelArray = [[NSMutableArray alloc]init];
    NSMutableArray *stickArray = [[NSMutableArray alloc]init];
    [tempModelArray addObjectsFromArray:modelArray];
    id<EaseConversationItemModelDelegate> model = nil;
    
    for (int i = 0; i < [modelArray count]; i++) {
        model = modelArray[i];
        if (model.isStick) {
            [stickArray addObject:model];
            [tempModelArray removeObject:model];
        }
    }
    NSLog(@"\nbefore:%@",stickArray);
    //排序置顶会话列表
    stickArray = [[stickArray sortedArrayUsingComparator:^(id<EaseConversationItemModelDelegate> obj1, id<EaseConversationItemModelDelegate> obj2) {
        if([self getConversationStickTime:obj1] > [self getConversationStickTime:obj2]) {
            return(NSComparisonResult)NSOrderedAscending;
        } else {
            return(NSComparisonResult)NSOrderedDescending;
        }
    }] mutableCopy];
    NSLog(@"\nlast :%@",stickArray);
    [stickArray addObjectsFromArray:tempModelArray];
    return stickArray;
}

//置顶时间
- (long)getConversationStickTime:(id<EaseConversationItemModelDelegate>)conversationModel
{
    return [(NSNumber *)[conversationModel.ext objectForKey:CONVERSATION_STICK] longValue];
}

//重排序会话model
- (void)_reSortedConversationModelsAndReloadView
{
    NSMutableArray *conversationModels = [NSMutableArray array];
    
    if (self.conversationVCDelegate && [self.conversationVCDelegate respondsToSelector:@selector(sortConversationsList:)]) {
        conversationModels = [[self.conversationVCDelegate sortConversationsList:self.dataArray] mutableCopy];
    } else {
        NSArray *sorted = [self.dataArray sortedArrayUsingComparator:^(id<EaseConversationItemModelDelegate> obj1, id<EaseConversationItemModelDelegate> obj2) {
            if(obj1.timestamp > obj2.timestamp) {
                return(NSComparisonResult)NSOrderedAscending;
            } else {
                return(NSComparisonResult)NSOrderedDescending;
            }
        }];
        
        for (id<EaseConversationItemModelDelegate> model in sorted) {
            if (![model.itemId isEqualToString:EMSYSTEMNOTIFICATIONID]) {
                id<EaseConversationItemModelDelegate>conversationModel = (id<EaseConversationItemModelDelegate>)model;
                if (![EaseConversationModelUtil getConversationWithConversationModel:conversationModel].latestMessage) {
                    [EMClient.sharedClient.chatManager deleteConversation:conversationModel.itemId
                                                         isDeleteMessages:NO
                                                               completion:nil];
                    continue;
                }
            }
            [conversationModels addObject:model];
        }
    }
    
    NSMutableArray *finalDataArray = [self _stickSortedConversationModels:[conversationModels copy]];//置顶重排序
    if ([self.dataArray count] > 0)
        [self.dataArray removeAllObjects];
    self.dataArray = finalDataArray;

    [self.tableView reloadData];
    self.isNeedReload = NO;
}

- (void)_loadAllConversationsFromDBWithIsShowHud:(BOOL)aIsShowHUD
{
    if (aIsShowHUD) {
        [self showHudInView:self.view hint:@"加载会话列表..."];
    }
    
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
        NSArray *sorted = [conversations sortedArrayUsingComparator:^(EMConversation *obj1, EMConversation *obj2) {
            EMMessage *message1 = [obj1 latestMessage];
            EMMessage *message2 = [obj2 latestMessage];
            if(message1.timestamp > message2.timestamp) {
                return(NSComparisonResult)NSOrderedAscending;
            } else {
                return(NSComparisonResult)NSOrderedDescending;
            }
            
        }];
        
        NSArray *models = [EaseConversationModelUtil modelsFromEMConversations:sorted];
        if (weakself.conversationVCDelegate && [weakself.conversationVCDelegate respondsToSelector:@selector(sortConversationsList:)]) {
            models = [[weakself.conversationVCDelegate sortConversationsList:models] mutableCopy];
        }
        
        NSMutableArray *finalDataArray = [weakself _stickSortedConversationModels:models];//置顶重排序
        
        if ([weakself.dataArray count] > 0)
            [weakself.dataArray removeAllObjects];
        weakself.dataArray = finalDataArray;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (aIsShowHUD) {
                [weakself hideHud];
            }
            
            [weakself addBlankPerchView];
            [weakself endRefresh];
            weakself.isNeedReload = NO;
        });
    });
}

- (void)refreshTabView
{
    [self _loadAllConversationsFromDBWithIsShowHud:NO];
}

//更新系统通知会话
- (void)renewalSystemNotification
{
    EMNotificationModel* notificationModel = [EMNotificationHelper.shared.notificationList objectAtIndex:0];
    NSString *notificationStr = nil;
    NSString *conversationId = nil;
    if (notificationModel.type == ContanctsRequestDidReceive) {
        conversationId = notificationModel.sender;
        notificationStr = [NSString stringWithFormat:@"好友申请来自：%@",notificationModel.sender];
    }
    if (notificationModel.type == GroupInvitationDidReceive) {
        conversationId = notificationModel.groupId;
        notificationStr = [NSString stringWithFormat:@"加群邀请来自：%@",notificationModel.sender];
    }
    if (notificationModel.type == JoinGroupRequestDidReceive) {
        conversationId = notificationModel.groupId;
        notificationStr = [NSString stringWithFormat:@"加群申请来自：%@",notificationModel.sender];
    }
    if (self.conversationVCDelegate && [self.conversationVCDelegate respondsToSelector:@selector(requestDidReceiveShowMessage:requestUser:reason:)]) {
        notificationStr = [self.conversationVCDelegate requestDidReceiveShowMessage:notificationModel.sender requestUser:notificationModel.sender reason:notificationModel.type];
    }
    EMTextMessageBody *body = [[EMTextMessageBody alloc]initWithText:notificationStr];
    EMMessage *message = [[EMMessage alloc] initWithConversationID:EMSYSTEMNOTIFICATIONID from:EMSYSTEMNOTIFICATIONID to:EMClient.sharedClient.currentUsername body:body ext:nil];
    message.timestamp = [self getLatestNotificTimestamp:notificationModel.time];
    EMConversation *notiConversation = [[EMClient sharedClient].chatManager getConversation:message.conversationId type:-1 createIfNotExist:YES];
    if (self.conversationVCDelegate && [self.conversationVCDelegate respondsToSelector:@selector(requestDidReceiveConversationExt:requestUser:reason:)]) {
        NSDictionary *ext = [self.conversationVCDelegate requestDidReceiveConversationExt:conversationId requestUser:notificationModel.sender reason:notificationModel.type];
        [notiConversation setExt:ext];
    }
    [notiConversation insertMessage:message error:nil];
}

//最后一个系统通知信息时间
- (long long)getLatestNotificTimestamp:(NSString*)timestamp
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *notiTime = [dateFormatter dateFromString:timestamp];
    NSTimeInterval notiTimeInterval = [notiTime timeIntervalSince1970];
    return [[NSNumber numberWithDouble:notiTimeInterval] longLongValue];
}

@end
