//
//  EaseContactsViewController.m
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/11/5.
//

#import "EaseContactsViewController.h"
#import "EaseContactModel.h"
#import "EaseContactCell.h"
#import "UITableView+Refresh.h"
#import "EaseHeaders.h"
#import "UIImageView+EaseWebCache.h"
#import "Easeonry.h"

@interface EaseContactsViewController () <EMContactManagerDelegate, UITableViewDelegate, UITableViewDataSource>
{
    EaseContactsViewModel *_viewModel;
    UIView *_sectionView;
    UILabel *_sectionTitleLabel;
}

@property (nonatomic, strong) NSArray<EaseUserDelegate> *contacts;
@property (nonatomic, strong) NSMutableArray *letterTitles;
@property (nonatomic, strong) NSMutableArray *contactLists;


@end

@implementation EaseContactsViewController
@synthesize viewModel = _viewModel;

- (instancetype)initWithModel:(EaseContactsViewModel *)model {
    if (self = [super initWithModel:model]) {
        _viewModel = model;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [EMClient.sharedClient.contactManager addDelegate:self delegateQueue:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf endRefresh];
    });
}

- (void)refreshTabView {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(willBeginRefresh)]) {
        [self.delegate willBeginRefresh];
        return;
    }
    
    __block typeof(self) weakSelf = self;
    [EMClient.sharedClient.contactManager getContactsFromServerWithCompletion:^(NSArray *aList, EMError *aError) {
        if (!aError) {
            NSMutableArray<EaseUserDelegate> *contacts = [NSMutableArray<EaseUserDelegate> array];
            for (NSString *username in aList) {
                EaseContactModel *model = [[EaseContactModel alloc] initWithEaseId:username];
                [contacts addObject:model];
            }
           [weakSelf sortContact:contacts];
        }
        if (self->_viewModel.canRefresh) {
            [weakSelf endRefresh];
        }else {
            [self.tableView reloadData];
        }
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    EaseContactModel *model = [self cellModelFromIndex:indexPath];
    if (self.delegate && [self.delegate respondsToSelector:@selector(easeTableView:cellForRowAtContactModel:)]) {
        UITableViewCell *cell = [self.delegate easeTableView:tableView cellForRowAtContactModel: model];
        if (cell) {
            return cell;
        }
    }
    
    EaseContactCell *cell = [EaseContactCell tableView:tableView cellViewModel:_viewModel];
    cell.model = model;
    
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    
    int letterIndex = -1;
    for (int i = 0 ; i < self.contactLists.count; i++) {
        EaseContactLetterModel *letterModel = self.contactLists[i];
        if ([letterModel.contactLetter isEqualToString:title]) {
            letterIndex = i;
            if (@available(iOS 10.0, *)) {
                UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
                [generator prepare];
                [generator impactOccurred];
            }
            break;
        }
    }
    
    return letterIndex;
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {

    return self.letterTitles;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, _viewModel.sectionTitleLabelHeight + _viewModel.sectionTitleEdgeInsets.bottom + _viewModel.sectionTitleEdgeInsets.top)];
    sectionView.backgroundColor = _viewModel.sectionTitleBgColor;
    UILabel* sectionTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(
                                                                           _viewModel.sectionTitleEdgeInsets.left, _viewModel.sectionTitleEdgeInsets.top,
                                                                           self.tableView.bounds.size.width - _viewModel.sectionTitleEdgeInsets.left - _viewModel.sectionTitleEdgeInsets.right, _viewModel.sectionTitleLabelHeight)];
    sectionTitleLabel.font = _viewModel.sectionTitleFont;
    sectionTitleLabel.textColor = _viewModel.sectionTitleColor;
    sectionTitleLabel.textAlignment = NSTextAlignmentLeft;
    [sectionView addSubview:sectionTitleLabel];

    EaseContactLetterModel *model = self.contactLists[section];
    sectionTitleLabel.text = model.contactLetter;

    return sectionView;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section {
    if (self.customHeaderItems.count > 0 && section == 0) {
        return 0;
    }
    return _viewModel.sectionTitleLabelHeight + _viewModel.sectionTitleEdgeInsets.bottom + _viewModel.sectionTitleEdgeInsets.top;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return self.contactLists.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    EaseContactLetterModel *model = self.contactLists[section];
    return model.contacts.count;
}


- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) API_UNAVAILABLE(tvos)
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(easeTableView:trailingSwipeActionsForRowAtContactModel:actions:)]) {
        NSArray *swipeActions = [self.delegate easeTableView:tableView trailingSwipeActionsForRowAtContactModel:[self cellModelFromIndex:indexPath] actions:nil];
        if (swipeActions) {
            UISwipeActionsConfiguration *actions = [UISwipeActionsConfiguration configurationWithActions:swipeActions];
            actions.performsFirstActionWithFullSwipe = NO;
            return actions;
        }
    }
    
    return nil;
}


- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate && [self.delegate respondsToSelector:@selector(easeTableView:editActionsForRowAtContactModel:actions:)]) {
        NSArray *swipeActions = [self.delegate easeTableView:tableView editActionsForRowAtContactModel:[self cellModelFromIndex:indexPath] actions:nil];
        return swipeActions;
    }
    
    return nil;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate && [self.delegate respondsToSelector:@selector(easeTableView:didSelectRowAtContactModel:)]) {
        return [self.delegate easeTableView:tableView didSelectRowAtContactModel:[self cellModelFromIndex:indexPath]];
    }
}


- (void)sortContact:(NSArray *)contacts {
    
    NSArray *ret = [contacts sortedArrayUsingComparator:^NSComparisonResult(EaseContactModel *obj1, EaseContactModel *obj2) {
        return [obj1.showName compare:obj2.showName options:NSLiteralSearch];
    }];

    UILocalizedIndexedCollation *indexCollation = [UILocalizedIndexedCollation currentCollation];
    NSMutableArray *letters = [[indexCollation sectionTitles] mutableCopy];
    NSMutableArray *contactLists = [NSMutableArray array];
    
    for (NSString *letter in letters) {
        EaseContactLetterModel *letterModel = [[EaseContactLetterModel alloc] init];
        letterModel.contactLetter = letter;
        [contactLists addObject:letterModel];
    }
    
    for (EaseContactModel *model in ret) {
        if ([letters containsObject:model.firstLetter]) {
            NSUInteger index = [letters indexOfObject:model.firstLetter];
            EaseContactLetterModel *letterModel = contactLists[index];
            NSMutableArray *array = [letterModel.contacts mutableCopy];
            if (!array) {
                array = [NSMutableArray array];
            }
            [array addObject:model];
            letterModel.contacts = array;
        }else {
            EaseContactLetterModel *letterModel = contactLists.lastObject;
            NSMutableArray *array = [letterModel.contacts mutableCopy];
            if (!array) {
                array = [NSMutableArray array];
            }
            [array addObject:model];
            letterModel.contacts = array;
        }
    }
    
    if (self.customHeaderItems) {
        [letters insertObject:@"☆" atIndex:0];
        EaseContactLetterModel *model = [[EaseContactLetterModel alloc] init];
        model.contactLetter = @"☆";
        model.contacts = self.customHeaderItems;
        [contactLists insertObject:model atIndex:0];
    }
    
    NSMutableArray *needRemove = [NSMutableArray array];
    for (EaseContactLetterModel *model in contactLists) {
        if (model.contacts.count == 0) {
            [needRemove addObject:model];
        }
    }
    
    [contactLists removeObjectsInArray:needRemove];
    
    self.letterTitles = letters;
    self.contactLists = contactLists;
    [self _updateBackView];
}

- (void)_updateBackView {
    if (self.contactLists.count == 0) {
        [self.tableView.backgroundView setHidden:NO];
    }else {
        [self.tableView.backgroundView setHidden:YES];
    }
}

- (EaseContactModel *)cellModelFromIndex:(NSIndexPath *)indexPath {
    EaseContactLetterModel *model = self.contactLists[indexPath.section];
    EaseContactModel * easeContactModel = model.contacts[indexPath.row];
    return easeContactModel;
}

#pragma mark - setter
- (void)setContacts:(NSArray<EaseUserDelegate> *)contacts {
    _contacts = contacts;
    NSMutableArray *cellModelAry = [NSMutableArray array];
    for (id<EaseUserDelegate> userDelegate in contacts) {
        EaseContactModel *model = [[EaseContactModel alloc] initWithEaseId:userDelegate.easeId];
        model.userDelegate = userDelegate;
        [cellModelAry addObject:model];
    }
    
    [self sortContact:cellModelAry];
}

- (void)setCustomHeaderItems:(NSArray<EaseUserDelegate> *)customHeaderItems {
    _customHeaderItems = customHeaderItems;
    [self sortContact:_contacts];
}

#pragma mark - getter

- (NSMutableArray *)letterTitles {
    if (!_letterTitles) {
        _letterTitles = [NSMutableArray array];
    }
    
    return _letterTitles;
}

- (NSMutableArray *)contactLists {
    if (!_contactLists) {
        _contactLists = [NSMutableArray array];
    }
    
    return _contactLists;
}


@end

@interface EaseContactLetterModel()

@end

@implementation EaseContactLetterModel

@end
