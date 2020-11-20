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

@interface EaseContactsViewController () <EMContactManagerDelegate>
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
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
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
    static NSString *cellId = @"ContactCell";
    EaseContactCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[EaseContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    id<EaseContactDelegate> easeContactModel;
    if (!_viewModel.letterIndex) {
        if (indexPath.section == 0) {
            easeContactModel = self.normalItems[indexPath.row];
        }else {
            easeContactModel = self.contacts[indexPath.row];
        }
    }
    
    else {
        NSArray *letterAry = self.contactLists[indexPath.section];
        easeContactModel = letterAry[indexPath.row];
    }
    
    
    cell.model = easeContactModel;
    
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if (!_viewModel.letterIndex) {
        return 0;
    }
    return index;
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (!_viewModel.letterIndex) {
        return nil;
    }
    
    return self.letterTitles;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (!_viewModel.letterIndex) {
        return nil;
    }
    
    if (section == 0 && self.normalItems) {
        return nil;
    }
    
    return self.letterTitles[section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!_viewModel.letterIndex) {
        return 2;
    }
    
    return self.contactLists.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!_viewModel.letterIndex) {
        if (section == 0) {
            return self.normalItems.count;
        } else if (section == 1){
            return self.contacts.count;
        } else {
            return 0;
        }
    }
    
    NSArray *contacts = (NSArray *)self.contactLists[section];
    return contacts.count;
}


- (id<EaseContactDelegate>)modelWithIndexPath:(NSIndexPath *)indexPath {
    if (!_viewModel.letterIndex) {
        return (id<EaseContactDelegate>)self.contacts[indexPath.row];
    }
    NSArray *letterAry = self.contactLists[indexPath.section];
    return (id<EaseContactDelegate>)letterAry[indexPath.row];
}



- (void)sortContact:(NSArray<EaseContactDelegate> *)contacts {
    
    NSArray *ret = [contacts sortedArrayUsingComparator:^NSComparisonResult(id <EaseContactDelegate> obj1, id<EaseContactDelegate> obj2) {
        return [obj1.showName compare:obj2.showName options:NSLiteralSearch];
    }];
    
    if (!_viewModel.letterIndex) {
        self.contacts = (NSArray<EaseContactDelegate> *)ret;
    }

    NSMutableArray *letters = [NSMutableArray array];
    NSMutableArray *contactLists = [NSMutableArray array];
    
    if (self.normalItems) {
        [letters addObject:@"☆"];
        [contactLists addObject:self.normalItems];
    }
    
    
    for (EaseContactModel *model in ret) {
        if ([letters containsObject:model.firstLetter]) {
            NSUInteger index = [letters indexOfObject:model.firstLetter];
            NSMutableArray *array = [contactLists[index] mutableCopy];
            [array addObject:model];
            contactLists[index] = array;
        }else {
            NSMutableArray *ary = [NSMutableArray array];
            [ary addObject:model];
            [letters addObject:model.firstLetter];
            [contactLists addObject:ary];
        }
    }
    
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
