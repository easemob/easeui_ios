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
#import <Hyphenate/Hyphenate.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <Masonry/Masonry.h>

@interface EaseContactsViewController () <EMContactManagerDelegate,UITableViewDelegate,UITableViewDataSource>
{
    EaseContactsViewModel *_viewModel;
}


@property (nonatomic, strong) NSMutableArray *letterTitles;
@property (nonatomic, strong) NSMutableArray *contactLists;

@end

@implementation EaseContactsViewController
@synthesize viewModel = _viewModel;

- (instancetype)initWithViewModel:(EaseContactsViewModel *)model {
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
    [self refreshTabView];
}


- (void)refreshTabView {
    __block typeof(self) weakSelf = self;
    [EMClient.sharedClient.contactManager getContactsFromServerWithCompletion:^(NSArray *aList, EMError *aError) {
        if (!aError) {
            NSMutableArray<EaseContactDelegate> *contacts = [NSMutableArray<EaseContactDelegate> array];
            for (NSString *username in aList) {
                EaseContactModel *model = [[EaseContactModel alloc] initWithShowName:username];
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
    
    id<EaseContactDelegate> easeContactModel;

    
    if (self.delegate && [self.delegate respondsToSelector:@selector(easeTableView:cellForRowAtContact:)]) {
        return [self.delegate easeTableView:tableView cellForRowAtContact: easeContactModel];
    }
    
    
    else {
        EaseContactLetterModel *model = self.contactLists[indexPath.section];
        easeContactModel = model.contacts[indexPath.row];
    }
    
    static NSString *cellId = @"ContactCell";
    EaseContactCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[EaseContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    
    cell.model = easeContactModel;
    
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {

    return index;
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {

    return self.letterTitles;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

    if (section == 0 && self.customHeaderItems) {
        return nil;
    }
    
    EaseContactLetterModel *model = self.contactLists[section];
    
    return model.contactLetter;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return self.contactLists.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    EaseContactLetterModel *model = self.contactLists[section];
    return model.contacts.count;
}

- (void)sortContact:(NSArray<EaseContactDelegate> *)contacts {
    
    NSArray *ret = [contacts sortedArrayUsingComparator:^NSComparisonResult(id <EaseContactDelegate> obj1, id<EaseContactDelegate> obj2) {
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
