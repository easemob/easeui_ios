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
#import "EaseConversationModelDelegate.h"
#import "EaseConversationModel.h"
#import "EMConversation+EaseUI.h"

@interface EaseConversationsViewController ()
<
    EMContactManagerDelegate,
    EMChatManagerDelegate,
    EMGroupManagerDelegate
>
{
    dispatch_queue_t _loadDataQueue;
}
@property (nonatomic, strong) UIView *blankPerchView;

@end

@implementation EaseConversationsViewController {
    id<EaseConversationsViewControllerDelegate> _easeTableViewDelegate;
}
@synthesize viewModel = _viewModel;
@dynamic easeTableViewDelegate;

- (instancetype)initWithModel:(EaseBaseTableViewModel *)aModel{
    if (self = [super initWithModel:aModel]) {
        _loadDataQueue = dispatch_queue_create("com.easemob.easeui.conversations.queue", 0);
        [[EMClient sharedClient].contactManager addDelegate:self delegateQueue:nil];
        [[EMClient sharedClient].groupManager addDelegate:self delegateQueue:nil];
        [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
        [self _setupSubviews];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTabView) name:CONVERSATIONLIST_UPDATE object:nil];
}

- (void)resetViewModel:(EaseConversationViewModel *)viewModel{
    [super resetViewModel:viewModel];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)_setupSubviews
{
    self.view.backgroundColor = _viewModel.viewBgColor;
    EaseConversationViewModel *conversationModel = nil;
    if ([_viewModel isMemberOfClass:[EaseConversationViewModel class]]) {
        conversationModel = (EaseConversationViewModel *)_viewModel;
    }
    self.blankPerchView = conversationModel.blankPerchView;
    [self.view addSubview:self.blankPerchView];
}

//空白占位视图
- (void)updateBlankPerchView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.dataAry count] == 0) {
            self.blankPerchView.hidden = NO;
        } else if ([self.dataAry count] > 0) {
            self.blankPerchView.hidden = YES;
        }
    });
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
    id<EaseConversationModelDelegate> model = self.dataAry[indexPath.row];
    if (self.easeTableViewDelegate && [self.easeTableViewDelegate respondsToSelector:@selector(easeTableView:cellforItem:)]) {
        return [self.easeTableViewDelegate easeTableView:tableView cellforItem:model];
    }
    
    EaseConversationCell *cell = (EaseConversationCell *)[tableView dequeueReusableCellWithIdentifier:@"EaseConversationCell"];
    if (!cell) {
        cell = [[EaseConversationCell alloc] initWithConversationViewModel:(EaseConversationViewModel *)_viewModel];
    }
    
    cell.model = model;
    
    return cell;
}

#pragma mark - Table view delegate

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) API_UNAVAILABLE(tvos)
{
    id<EaseConversationModelDelegate> model = [self.dataAry objectAtIndex:indexPath.row];
    
    if (self.easeTableViewDelegate && [self.easeTableViewDelegate respondsToSelector:@selector(tableView:trailingSwipeActionsConfigurationForRowAtItem:)]) {
        UISwipeActionsConfiguration *customSwipActions = [self.easeTableViewDelegate tableView:tableView trailingSwipeActionsConfigurationForRowAtItem:model];
        customSwipActions.performsFirstActionWithFullSwipe = NO;
        return customSwipActions;
    }
    
    __weak typeof(self) weakself = self;
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"删除" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        [tableView setEditing:NO animated:YES];
        [weakself _deleteConversation:indexPath];
    }];
    deleteAction.backgroundColor = [UIColor colorWithRed: 253 / 255.0 green: 81 / 255.0 blue: 84 / 255.0 alpha:1.0];
    
    UIContextualAction *stickConversationAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"置顶" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        [tableView setEditing:NO animated:YES];
        EMConversation *conversation = [EMClient.sharedClient.chatManager getConversation:model.itemId type:model.type createIfNotExist:YES];
        [conversation setTop:YES];
    }];
    stickConversationAction.backgroundColor = [UIColor colorWithRed: 203 / 255.0 green: 125 / 255.0 blue: 50 / 255.0 alpha:1.0];
    
    UIContextualAction *cancelStickConversationAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"取消置顶" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        [tableView setEditing:NO animated:YES];
        EMConversation *conversation = [EMClient.sharedClient.chatManager getConversation:model.itemId type:model.type createIfNotExist:YES];
        [conversation setTop:NO];
    }];
    cancelStickConversationAction.backgroundColor = [UIColor colorWithRed: 203 / 255.0 green: 125 / 255.0 blue: 50 / 255.0 alpha:1.0];

    NSMutableArray<UIContextualAction *> *sideslipArray = [[NSMutableArray alloc]init];
    [sideslipArray addObject:deleteAction];
    if(model.isTop) {
        [sideslipArray addObject:cancelStickConversationAction];
    } else {
        [sideslipArray addObject:stickConversationAction];
    }
    UISwipeActionsConfiguration *actions = [UISwipeActionsConfiguration configurationWithActions:sideslipArray];
    actions.performsFirstActionWithFullSwipe = NO;
    return actions;
}

#pragma mark - EMChatManagerDelegate

- (void)messagesDidRecall:(NSArray *)aMessages {
    [self _loadAllConversationsFromDB];
}

- (void)messagesDidReceive:(NSArray *)aMessages
{
    [self _loadAllConversationsFromDB];
}

#pragma mark - UIMenuController

//删除会话
- (void)_deleteConversation:(NSIndexPath *)indexPath
{
    __weak typeof(self) weakSelf = self;
    NSInteger row = indexPath.row;
    id<EaseConversationModelDelegate> model = [self.dataAry objectAtIndex:row];
    [[EMClient sharedClient].chatManager deleteConversation:model.itemId
                                           isDeleteMessages:YES
                                                 completion:^(NSString *aConversationId, EMError *aError) {
        if (!aError) {
            [weakSelf.dataAry removeObjectAtIndex:row];
            [weakSelf.tableView reloadData];
            [weakSelf updateBlankPerchView];
        }
    }];
}


- (void)_loadAllConversationsFromDB
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(_loadDataQueue, ^{
        NSMutableArray<id<EaseItemDelegate>> *totals = [NSMutableArray<id<EaseItemDelegate>> array];
        if (weakSelf.easeTableViewDelegate && [weakSelf.easeTableViewDelegate respondsToSelector:@selector(resetDataAry)]) {
            totals = [[weakSelf.easeTableViewDelegate resetDataAry] mutableCopy];
        }else {
            NSArray *conversations = [EMClient.sharedClient.chatManager getAllConversations];
            
            NSMutableArray<EaseConversationModelDelegate> *convs = [NSMutableArray<EaseConversationModelDelegate> array];
            NSMutableArray<EaseConversationModelDelegate> *topConvs = [NSMutableArray<EaseConversationModelDelegate> array];
            
            for (EMConversation *conv in conversations) {
                EaseConversationModel *item = [[EaseConversationModel alloc] initWithConversation:conv];
                if (item.isTop) {
                    [topConvs addObject:item];
                }else {
                    [convs addObject:item];
                }
            }
            
            NSArray *normalConvList = [convs sortedArrayUsingComparator:
                                       ^NSComparisonResult(id  <EaseConversationModelDelegate> obj1, id  <EaseConversationModelDelegate> obj2)
            {
                if (obj1.lastestUpdateTime > obj2.lastestUpdateTime) {
                    return(NSComparisonResult)NSOrderedAscending;
                }else {
                    return(NSComparisonResult)NSOrderedDescending;
                }
            }];
            
            NSArray *topConvList = [topConvs sortedArrayUsingComparator:
                                    ^NSComparisonResult(id  <EaseConversationModelDelegate> obj1, id  <EaseConversationModelDelegate> obj2)
            {
                if (obj1.lastestUpdateTime > obj2.lastestUpdateTime) {
                    return(NSComparisonResult)NSOrderedAscending;
                }else {
                    return(NSComparisonResult)NSOrderedDescending;
                }
            }];
            
            [totals addObjectsFromArray:topConvList];
            [totals addObjectsFromArray:normalConvList];
        }
        
        weakSelf.dataAry = (NSMutableArray<EaseConversationModelDelegate> *)totals;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf endRefresh];
            [weakSelf updateBlankPerchView];
        });
    });
}

- (void)refreshTabView
{
    [self _loadAllConversationsFromDB];
}

#pragma mark - setter & getter
- (void)setEaseTableViewDelegate:(id<EaseConversationsViewControllerDelegate>)easeTableViewDelegate {
    _easeTableViewDelegate = easeTableViewDelegate;
}

- (id<EaseConversationsViewControllerDelegate>)easeTableViewDelegate {
    return (id<EaseConversationsViewControllerDelegate>)_easeTableViewDelegate;
}
@end
