//
//  EaseConversationsViewController.m
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/10/29.
//

#import "EaseConversationsViewController.h"
#import "EaseHeaders.h"
#import "EaseConversationViewModel.h"
#import "EaseConversationCell.h"
#import "EaseConversationModel.h"
#import "EMConversation+EaseUI.h"
#import "UIImage+EaseUI.h"
#import "EaseIMKitManager.h"
#import "UIViewController+HUD.h"


@interface EaseConversationsViewController ()
<
UITableViewDelegate,
UITableViewDataSource,
EMContactManagerDelegate,
EMChatManagerDelegate,
EMGroupManagerDelegate,
EMClientDelegate
>
{
    dispatch_queue_t _loadDataQueue;
}
@property (nonatomic, strong) UIView *blankPerchView;

@property (nonatomic, strong) NSMutableDictionary <NSString *, NSString *>*hasAtConversationMap;
@property (nonatomic, strong) NSMutableSet *blockAtNotificationSet;

@end

@implementation EaseConversationsViewController

@synthesize viewModel = _viewModel;

- (instancetype)initWithModel:(EaseConversationViewModel *)aModel{
    if (self = [super initWithModel:aModel]) {
        _viewModel = aModel;
        _loadDataQueue = dispatch_queue_create("com.easemob.easeui.conversations.queue", 0);
        [[EMClient sharedClient] addDelegate:self delegateQueue:nil];
        [[EMClient sharedClient].contactManager addDelegate:self delegateQueue:nil];
        [[EMClient sharedClient].groupManager addDelegate:self delegateQueue:nil];
        [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [EMClient.sharedClient.chatManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient] addMultiDevicesDelegate:self delegateQueue:nil];
    
    NSDictionary *hasAtConversationMap = [[NSUserDefaults.standardUserDefaults objectForKey:[NSString stringWithFormat:@"at_list_%@", EMClient.sharedClient.currentUsername]] copy];
    if (hasAtConversationMap) {
        _hasAtConversationMap = [NSMutableDictionary dictionaryWithDictionary:hasAtConversationMap];
    } else {
        _hasAtConversationMap = [NSMutableDictionary dictionary];
    }
    _blockAtNotificationSet = [NSMutableSet set];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshTabView)
                                                 name:CONVERSATIONLIST_UPDATE object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(blockAtBeginNotification:) name:CONVERSATIONLIST_BLOCK_AT_BEGIN object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(blockAtEndNotification:) name:CONVERSATIONLIST_BLOCK_AT_END object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(removeAtNotification:) name:CONVERSATIONLIST_REMOVE_AT object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf endRefresh];
    });
}

- (void)dealloc
{
    [[EMClient sharedClient] removeDelegate:self];
    [[EMClient sharedClient].groupManager removeDelegate:self];
    [[EMClient sharedClient].contactManager removeDelegate:self];
    [[EMClient sharedClient].chatManager removeDelegate:self];
    [[EMClient sharedClient] removeMultiDevicesDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - EMClientDelegate

- (void)autoLoginDidCompleteWithError:(EMError *)aError
{
    if (!aError) {
        [self _loadAllConversationsFromDB];
    }
}

#pragma mark - EMMultiDevicesDelegate

- (void)multiDevicesUndisturbEventNotifyFormOtherDeviceData:(NSString *)undisturbData {
#if DEBUG
    NSLog(@"multiDevicesUndisturbEventNotifyFormOtherDeviceData::: %@",[self dictionaryWithJsonString:undisturbData]);
#endif
    [[EMClient sharedClient].pushManager getPushNotificationOptionsFromServerWithCompletion:^(EMPushOptions * _Nonnull aOptions, EMError * _Nonnull aError) {
        if (!aError) {
            [[EaseIMKitManager shared] cleanMemoryUndisturbMaps];
            NSMutableArray *undisturbs = [NSMutableArray array];
            [undisturbs addObjectsFromArray:[EMClient sharedClient].pushManager.noPushGroups];
            [undisturbs addObjectsFromArray:[EMClient sharedClient].pushManager.noPushUIds];
            for (NSString *conversationId in undisturbs) {
                [[EaseIMKitManager shared] updateUndisturbMapsKey:conversationId value:@(YES)];
            }
            [self.tableView reloadData];
        }
    }];
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err) {
        return nil;
    }
    return dic;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataAry count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(easeTableView:cellForRowAtIndexPath:)]) {
        UITableViewCell *cell = [self.delegate easeTableView:tableView cellForRowAtIndexPath:indexPath];
        if (cell) {
            return cell;
        }
    }
    
    EaseConversationCell *cell = [EaseConversationCell tableView:tableView cellViewModel:_viewModel];
    if (indexPath.row >= self.dataAry.count || self.dataAry.count <= 0) {
        return cell;
    }
    EaseConversationModel *model = self.dataAry[indexPath.row];
    
    cell.model = model;
    
    return cell;
}

#pragma mark - Table view delegate

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) API_UNAVAILABLE(tvos)
{
    EaseConversationModel *model = [self.dataAry objectAtIndex:indexPath.row];
    
    __weak typeof(self) weakself = self;
    
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive
                                                                               title:EaseLocalizableString(@"delete", nil)
                                                                             handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL))
                                        {
        [weakself _deleteConversation:indexPath];
        [weakself refreshTabView];
    }];
    
    UIContextualAction *topAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal
                                                                            title:!model.isTop ? EaseLocalizableString(@"top", nil) : EaseLocalizableString(@"cancelTop", nil)
                                                                          handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL))
                                     {
        EMConversation *conversation = [EMClient.sharedClient.chatManager getConversation:model.easeId
                                                                                     type:model.type
                                                                         createIfNotExist:YES];
        [conversation setTop:!model.isTop];
        [weakself refreshTabView];
    }];
    
    topAction.backgroundColor = [UIColor colorWithHexString:@"CB7D32"];
    
    NSArray *swipeActions = @[deleteAction, topAction];
    if (self.delegate && [self.delegate respondsToSelector:@selector(easeTableView:trailingSwipeActionsForRowAtIndexPath:actions:)]) {
        swipeActions = [self.delegate easeTableView:tableView trailingSwipeActionsForRowAtIndexPath:indexPath actions:swipeActions];
    }
    
    if (swipeActions == nil) {
        return nil;
    }
    
    UISwipeActionsConfiguration *actions = [UISwipeActionsConfiguration configurationWithActions:swipeActions];
    actions.performsFirstActionWithFullSwipe = NO;
    return actions;
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[self makeSwipeButton:tableView];
}

- (void)makeSwipeButton:(UITableView *)tableView
{
    if (@available(iOS 13.0, *))
    {
        for (UIView *subview in tableView.subviews)
        {
            if ([subview isKindOfClass:NSClassFromString(@"_UITableViewCellSwipeContainerView")] )
            {
                NSArray *subviewArray=subview.subviews;
                for (UIView *sub_subview in subviewArray)
                {
                    if ([sub_subview isKindOfClass:NSClassFromString(@"UISwipeActionPullView")] )
                    {
                        NSArray *subviews=sub_subview.subviews;
                        
                        UIView *topView = sub_subview.subviews[1];
                        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, topView.frame.size.width, topView.frame.size.height)];
                        
                        UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage easeUIImageNamed:@"alert_error"]];
                        [view addSubview:imageView];
                        [imageView Ease_makeConstraints:^(EaseConstraintMaker *make) {
                            make.centerX.equalTo(view.ease_centerX);
                            make.bottom.equalTo(view.ease_centerY);
                            make.height.width.equalTo(@30);
                        }];
                        
                        UILabel *titleLable = [[UILabel alloc]init];
                        titleLable.text = @"stick";
                        titleLable.textAlignment = NSTextAlignmentCenter;
                        [view addSubview:titleLable];
                        [titleLable Ease_makeConstraints:^(EaseConstraintMaker *make) {
                            make.left.right.equalTo(view);
                            make.top.equalTo(view.ease_centerY);
                            make.height.equalTo(@30);
                        }];
                        view.backgroundColor = [UIColor colorWithHexString:@"CB7D32"];
                        view.userInteractionEnabled = NO;
                        
                        [sub_subview insertSubview:view aboveSubview:topView];
                        
                        //                        UIButton*deleteButton = sub_subview.subviews[1];
                        //                        [deleteButton setImage:[UIImage imageNamed:@"contact_de"] forState:UIControlStateNormal];
                    }
                }
            }
        }
    } else if (@available(iOS 11.0, *))
    {
        for (UIView *subview in tableView.subviews)
        {
            if ([subview isKindOfClass:NSClassFromString(@"UISwipeActionPullView")] )
            {
                UIButton*addButton = subview.subviews[0];
                [addButton setImage:[UIImage imageNamed:@"alert_error"] forState:UIControlStateNormal];
            }
        }
    }else{
        //     ios 8-10
        // UITableView -> UITableViewCell -> UITableViewCellDeleteConfirmationView
        //       UITableViewCell*  cell = [self.FULTable cellForRowAtIndexPath:_indexPath];
    }
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    EaseConversationModel *model = [self.dataAry objectAtIndex:indexPath.row];
    __weak typeof(self) weakself = self;
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive
                                                                            title:EaseLocalizableString(@"delete", nil)
                                                                          handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath)
    {
        [weakself _deleteConversation:indexPath];
        [weakself refreshTabView];
    }];
    
    UITableViewRowAction *topAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive
                                                                            title:!model.isTop ? EaseLocalizableString(@"top", nil) : EaseLocalizableString(@"cancelTop", nil)
                                                                          handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath)
    {
        EMConversation *conversation = [EMClient.sharedClient.chatManager getConversation:model.easeId
                                                                                     type:model.type
                                                                         createIfNotExist:YES];
        [conversation setTop:!model.isTop];
        [weakself refreshTabView];
    }];
    
    topAction.backgroundColor = [UIColor colorWithHexString:@"CB7D32"];
    
    NSArray *swipeActions = @[deleteAction, topAction];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(easeTableView:editActionsForRowAtIndexPath:actions:)]) {
        swipeActions = [self.delegate easeTableView:tableView editActionsForRowAtIndexPath:indexPath actions:swipeActions];
    }
    
    return swipeActions;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.dataAry.count || self.dataAry.count <= 0) {
        return;
    }
    EaseConversationModel *model = [self.dataAry objectAtIndex:indexPath.row];
    if (!model.isTop) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    [self removeAt:model];
    if (self.delegate && [self.delegate respondsToSelector:@selector(easeTableView:didSelectRowAtIndexPath:)]) {
        return [self.delegate easeTableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

- (void)removeAt:(EaseConversationModel *)model
{
    if (model.type == EMConversationTypeGroupChat) {
        [_hasAtConversationMap removeObjectForKey:model.userDelegate.easeId];
        [NSUserDefaults.standardUserDefaults setObject:_hasAtConversationMap forKey:[NSString stringWithFormat:@"at_list_%@", EMClient.sharedClient.currentUsername]];
    }
}

#pragma mark - EMChatManagerDelegate

- (void)messagesInfoDidRecall:(NSArray<EMRecallMessageInfo *> *)aRecallMessagesInfo
{
    [self _loadAllConversationsFromDB];
}

- (void)messagesDidReceive:(NSArray *)aMessages
{
    for (EMChatMessage *message in aMessages) {
        if ([_blockAtNotificationSet containsObject:message.conversationId]) {
            continue;
        }
        if (_hasAtConversationMap[message.conversationId]) {
            continue;
        }
        if (message.chatType != EMChatTypeGroupChat) {
            continue;
        }
        if ([message.from isEqualToString:EMClient.sharedClient.currentUsername]) {
            continue;
        }
        id atListObj = message.ext[@"em_at_list"];
        if (atListObj) {
            if ([atListObj isKindOfClass:NSString.class]) {
                if ([atListObj isEqualToString:@"ALL"]) {
                    _hasAtConversationMap[message.conversationId] = @"";
                    [NSUserDefaults.standardUserDefaults setObject:_hasAtConversationMap forKey:[NSString stringWithFormat:@"at_list_%@", EMClient.sharedClient.currentUsername]];
                } else {
                    NSArray <NSString *>*atList = [NSJSONSerialization JSONObjectWithData:[atListObj dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
                    if ([atList containsObject:EMClient.sharedClient.currentUsername]) {
                        _hasAtConversationMap[message.conversationId] = @"";
                        [NSUserDefaults.standardUserDefaults setObject:_hasAtConversationMap forKey:[NSString stringWithFormat:@"at_list_%@", EMClient.sharedClient.currentUsername]];
                    }
                }
            } else if ([atListObj isKindOfClass:NSArray.class]) {
                NSArray <NSString *>*atList = atListObj;
                if ([atList containsObject:EMClient.sharedClient.currentUsername]) {
                    _hasAtConversationMap[message.conversationId] = @"";
                    [NSUserDefaults.standardUserDefaults setObject:_hasAtConversationMap forKey:[NSString stringWithFormat:@"at_list_%@", EMClient.sharedClient.currentUsername]];
                }
            }
        }
    }
    
    [self _loadAllConversationsFromDB];
}

- (void)onConversationRead:(NSString *)from to:(NSString *)to
{
    [self _loadAllConversationsFromDB];
}

//　收到已读回执
- (void)messagesDidRead:(NSArray *)aMessages
{
    [self refreshTable];
}

#pragma mark - UIMenuController

//删除会话
- (void)_deleteConversation:(NSIndexPath *)indexPath
{
    __weak typeof(self) weakSelf = self;
    NSInteger row = indexPath.row;
    EaseConversationModel *model = [self.dataAry objectAtIndex:row];
    [[EMClient sharedClient].chatManager deleteServerConversation:model.easeId conversationType:model.type isDeleteServerMessages:YES completion:^(NSString *aConversationId, EMError *aError) {
        if (aError) {
            [weakSelf showHint:aError.errorDescription];
        }
    }];
    [[EMClient sharedClient].chatManager deleteConversation:model.easeId
                                           isDeleteMessages:YES
                                                 completion:^(NSString *aConversationId, EMError *aError) {
        if (!aError) {
            if(weakSelf.dataAry.count >= row) {
                [weakSelf.dataAry removeObjectAtIndex:row];
            }
            [weakSelf.tableView reloadData];
            [weakSelf _updateBackView];
        }
    }];
}

- (void)_loadAllConversationsFromDB
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(_loadDataQueue, ^{
        NSMutableArray<id<EaseUserDelegate>> *totals = [NSMutableArray<id<EaseUserDelegate>> array];
        
        NSArray *conversations = [EMClient.sharedClient.chatManager getAllConversations];
        
        NSMutableArray *convs = [NSMutableArray array];
        NSMutableArray *topConvs = [NSMutableArray array];
        
        for (EMConversation *conv in conversations) {
            if (!conv.latestMessage) {
                /*[EMClient.sharedClient.chatManager deleteConversation:conv.conversationId
                                                     isDeleteMessages:NO
                                                           completion:nil];*/
                continue;
            }
            if (conv.type == EMConversationTypeChatRoom) {
                continue;
            }
            EaseConversationModel *item = [[EaseConversationModel alloc] initWithConversation:conv];
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(easeUserDelegateAtConversationId:conversationType:)]) {
                item.userDelegate = [weakSelf.delegate easeUserDelegateAtConversationId:conv.conversationId conversationType:conv.type];
            }
            item.hasAtMessage = weakSelf.hasAtConversationMap[conv.conversationId] != nil;

            if (item.isTop) {
                [topConvs addObject:item];
            }else {
                [convs addObject:item];
            }
        }
        
        NSArray *normalConvList = [convs sortedArrayUsingComparator:
                                   ^NSComparisonResult(EaseConversationModel *obj1, EaseConversationModel *obj2)
                                   {
            if (obj1.lastestUpdateTime > obj2.lastestUpdateTime) {
                return(NSComparisonResult)NSOrderedAscending;
            }else {
                return(NSComparisonResult)NSOrderedDescending;
            }
        }];
        
        NSArray *topConvList = [topConvs sortedArrayUsingComparator:
                                ^NSComparisonResult(EaseConversationModel *obj1, EaseConversationModel *obj2)
                                {
            if (obj1.lastestUpdateTime > obj2.lastestUpdateTime) {
                return(NSComparisonResult)NSOrderedAscending;
            }else {
                return(NSComparisonResult)NSOrderedDescending;
            }
        }];
        
        [totals addObjectsFromArray:topConvList];
        [totals addObjectsFromArray:normalConvList];
        
        weakSelf.dataAry = (NSMutableArray *)totals;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            if ([self.tableView.refreshControl isRefreshing]) {
                [self.tableView.refreshControl endRefreshing];
            }
        });
        
        dispatch_async(dispatch_get_main_queue(), ^{
         [self.tableView reloadData];
         [weakSelf _updateBackView];
        });
    });
}

- (void)refreshTabView
{
    [self _loadAllConversationsFromDB];
}

- (void)_updateBackView {
    if (self.dataAry.count == 0) {
        [self.tableView.backgroundView setHidden:NO];
    }else {
        [self.tableView.backgroundView setHidden:YES];
    }
}

#pragma mark - @
- (void)blockAtBeginNotification:(NSNotification *)notification
{
    NSString *conversationId = notification.object;
    if ([conversationId isKindOfClass:NSString.class]) {
        [_blockAtNotificationSet addObject:conversationId];
    }
}

- (void)blockAtEndNotification:(NSNotification *)notification
{
    NSString *conversationId = notification.object;
    if ([conversationId isKindOfClass:NSString.class]) {
        [_blockAtNotificationSet removeObject:conversationId];
    }
}

- (void)removeAtNotification:(NSNotification *)notification
{
    NSString *conversationId = notification.object;
    if ([conversationId isKindOfClass:NSString.class]) {
        for (EaseConversationModel *i in self.dataAry) {
            if ([i.userDelegate.easeId isEqualToString:conversationId]) {
                [self removeAt:i];
                return;
            }
        }
    }
}

@end
