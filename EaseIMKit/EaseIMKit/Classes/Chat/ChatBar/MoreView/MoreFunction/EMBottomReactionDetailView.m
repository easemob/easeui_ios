//
//  EMBottomReactionDetailView.m
//  EaseIMKit
//
//  Created by 冯钊 on 2022/2/24.
//

#import "EMBottomReactionDetailView.h"

#import "EMBottomReactionDetailViewCollectionViewLayout.h"
#import "EMBottomReactionDetailUserCell.h"
#import "EMBottomReactionDetailReactionCell.h"
#import "PageWithId.h"

@import HyphenateChat;
@import MJRefresh;

typedef struct PanData {
    CGFloat beiginBottom;
    CGFloat step[3];
    uint8_t currentStep;
} PanData;

@interface EMBottomReactionDetailView () <UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UICollectionView *emojiCollectionView;
@property (weak, nonatomic) IBOutlet UITableView *itemTableView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emojiCollectionViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomContainerHeightConstraint;

@property (nonatomic, strong) CAShapeLayer *maskLayer;


@property (nonatomic, strong) EMChatMessage *message;
@property (nonatomic, strong) NSMutableDictionary <NSNumber *, NSNumber *>*widthCache;

@property (nonatomic, assign) PanData panData;

@property (nonatomic, assign) NSInteger reactionSelectedIndex;
@property (nonatomic, strong) NSMutableDictionary<NSString *, PageWithId<NSString *>*>*reactionUserListMap;

@property (nonatomic, copy) void(^didRemoveSelfReaction)(NSString *);

@end

@implementation EMBottomReactionDetailView

static EMBottomReactionDetailView *shareView;

+ (instancetype)share {
    if (!shareView) {
        shareView = [NSBundle.mainBundle loadNibNamed:NSStringFromClass(self.class) owner:nil options:nil].firstObject;
    }
    return shareView;
}

+ (void)showMenuItems:(EMChatMessage *)message animation:(BOOL)animation didRemoveSelfReaction:(void (^)(NSString * _Nonnull))didRemoveSelfReaction {
    EMBottomReactionDetailView *shareView = EMBottomReactionDetailView.share;
    [UIApplication.sharedApplication.keyWindow addSubview:shareView];
    shareView.frame = UIApplication.sharedApplication.keyWindow.bounds;
    shareView.message = message;
    shareView.bgView.alpha = 1;
    shareView.reactionSelectedIndex = 0;
    shareView.itemTableView.scrollEnabled = NO;
    shareView.didRemoveSelfReaction = didRemoveSelfReaction;
    
    if (animation) {
        [shareView layoutIfNeeded];
        shareView.contentViewBottomConstraint.constant = -shareView.mainView.bounds.size.height;
        [shareView layoutIfNeeded];
        shareView.contentViewBottomConstraint.constant = -350 - shareView.bottomContainerHeightConstraint.constant;
        [UIView animateWithDuration:0.25 animations:^{
            [shareView layoutIfNeeded];
        }];
    } else {
        shareView.contentViewBottomConstraint.constant = -350 - shareView.bottomContainerHeightConstraint.constant;
    }
    
    if (!shareView.widthCache) {
        shareView.widthCache = [NSMutableDictionary dictionary];
    } else if (shareView.widthCache.count > 200) {
        // 最大缓存200个
        [shareView.widthCache removeAllObjects];
    }
    for (EMMessageReaction *reaction in message.reactionList) {
        if (!shareView.widthCache[@(reaction.count)]) {
            CGFloat width = [[NSString stringWithFormat:@"%ld", (long)reaction.count] boundingRectWithSize:CGSizeMake(1000, 1000) options:0 attributes:@{
                NSFontAttributeName: [UIFont systemFontOfSize:14]
            } context:nil].size.width + 48;
            shareView.widthCache[@(reaction.count)] = @(width);
        }
    }
    
    [shareView.emojiCollectionView reloadData];
    [shareView loadUserListData:YES];
}

+ (void)hideWithAnimation:(BOOL)animation needClear:(BOOL)needClear {
    [shareView.reactionUserListMap removeAllObjects];
    void(^clearFunc)(void) = ^{
        [shareView.itemTableView.mj_header endRefreshing];
        [shareView.itemTableView.mj_footer endRefreshing];
        [shareView removeFromSuperview];
        if (needClear) {
            shareView = nil;
        }
    };
    if (animation) {
        shareView.contentViewBottomConstraint.constant = -EMBottomReactionDetailView.share.frame.size.height;
        [UIView animateWithDuration:0.25 animations:^{
            [shareView layoutIfNeeded];
            shareView.bgView.alpha = 0;
        } completion:^(BOOL finished) {
            clearFunc();
        }];
    } else {
        clearFunc();
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
        
    _reactionUserListMap = [NSMutableDictionary dictionary];
    
    if (@available(iOS 11.0, *)) {
        _bottomContainerHeightConstraint.constant = UIApplication.sharedApplication.keyWindow.safeAreaInsets.bottom;
    }
    
    EMBottomReactionDetailViewCollectionViewLayout *layout = (EMBottomReactionDetailViewCollectionViewLayout *)_emojiCollectionView.collectionViewLayout;
    layout.contentInsets = UIEdgeInsetsMake(0, 12, 0, 12);
    layout.spacing = 4;
    __weak typeof(self)weakSelf = self;
    layout.getCellItemWidth = ^CGFloat(NSIndexPath * _Nonnull indexPath) {
        int count = (int)weakSelf.message.reactionList[indexPath.item].count;
        return weakSelf.widthCache[@(count)].floatValue;
    };
    [_emojiCollectionView registerNib:[UINib nibWithNibName:@"EMBottomReactionDetailReactionCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    [_itemTableView registerNib:[UINib nibWithNibName:@"EMBottomReactionDetailUserCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    
    _maskLayer = [[CAShapeLayer alloc] init];
    _mainView.layer.mask = _maskLayer;
    
    _itemTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadUserListData:YES];
    }];
    
    _itemTableView.mj_footer = [MJRefreshBackStateFooter footerWithRefreshingBlock:^{
        [weakSelf loadUserListData:NO];
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat radius = 24;
    UIRectCorner corner = UIRectCornerTopLeft | UIRectCornerTopRight;
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:_mainView.bounds byRoundingCorners:corner cornerRadii:CGSizeMake(radius, radius)];
    _maskLayer.frame = _mainView.bounds;
    _maskLayer.path = path.CGPath;
}

- (void)loadUserListData:(BOOL)refresh {
    if (_message.reactionList.count <= _reactionSelectedIndex) {
        return;
    }
    NSString *reaction = _message.reactionList[_reactionSelectedIndex].reaction;
    PageWithId<NSString *> *page = _reactionUserListMap[reaction];
    if (!page) {
        page = [[PageWithId alloc] init];
        _reactionUserListMap[reaction] = page;
    }
    NSString *lastId = @"";
    if (!refresh && page.lastId.length > 0) {
        lastId = page.lastId;
    }
    
    __weak typeof(self)weakSelf = self;
    [EMClient.sharedClient.chatManager getReactionDetail:_message.messageId reaction:reaction cursor:lastId pageSize:30 completion:^(EMMessageReaction *reaction, NSString *cursor, EMError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [weakSelf.itemTableView.mj_header endRefreshing];
                [weakSelf.itemTableView.mj_footer endRefreshing];
                return;
            }
            if (refresh) {
                [page clear];
            }
            if (page.dataList.count <= 0 && reaction.isAddedBySelf) {
                [page appendData:@[EMClient.sharedClient.currentUsername] lastId:cursor];
            }
            // 自己的操作置顶
            NSArray <NSString *>*userList = reaction.userList;
            if (page.userInfo[@"index"] || !reaction.isAddedBySelf) {
                [page appendData:userList lastId:cursor];
            } else {
                NSUInteger index = [userList indexOfObject:EMClient.sharedClient.currentUsername];
                if (index == NSNotFound) {
                    [page appendData:userList lastId:cursor];
                } else {
                    if (index != 0) {
                        [page appendData:[userList subarrayWithRange:NSMakeRange(0, index)] lastId:cursor];
                    }
                    if (index < userList.count - 1) {
                        [page appendData:[userList subarrayWithRange:NSMakeRange(index + 1, userList.count - index - 1)] lastId:cursor];
                    }
                    page.userInfo[@"index"] = @(index);
                }
            }
            [weakSelf.itemTableView reloadData];
            [weakSelf.itemTableView.mj_header endRefreshing];
            if (cursor.length <= 0) {
                [weakSelf.itemTableView.mj_footer endRefreshingWithNoMoreData];
            } else {
                [weakSelf.itemTableView.mj_footer endRefreshing];
            }
        });
    }];
}

- (IBAction)onBgViewTap:(UITapGestureRecognizer *)sender {
    [self.class hideWithAnimation:YES needClear:NO];
}

- (IBAction)onContentViewPan:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        _panData.beiginBottom = _contentViewBottomConstraint.constant;
        _panData.step[0] = 0;
        _panData.step[1] = 350 + _bottomContainerHeightConstraint.constant;
        _panData.step[2] = _mainView.bounds.size.height;
    } else if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled) {
        int index = -1;
        CGFloat offset = [sender translationInView:self].y;
        CGFloat newBottom = _panData.beiginBottom - offset;
        if (newBottom > 0) {
            newBottom = 0;
        }
        
        CGFloat minDistance = 0;
        
        for (int i = 0; i < 3; i ++) {
            CGFloat distance = fabs(_panData.step[i] + newBottom);
            if (index < 0 || minDistance > distance) {
                index = i;
                minDistance = distance;
            }
        }
        
        _panData.currentStep = index;
        _contentViewBottomConstraint.constant = -_panData.step[index];
        [UIView animateWithDuration:0.25 animations:^{
            [self layoutIfNeeded];
            if (index == 2) {
                self.bgView.alpha = 0;
            } else {
                self.bgView.alpha = 1;
            }
        } completion:^(BOOL finished) {
            if (index == 2) {
                [self removeFromSuperview];
            }
            self.itemTableView.scrollEnabled = index == 0 && self.panData.step[1] != 0;
        }];
    } else {
        CGFloat offset = [sender translationInView:self].y;
        CGFloat newBottom = _panData.beiginBottom - offset;
        if (newBottom > -_panData.step[0]) {
            newBottom = -_panData.step[0];
        } else if (newBottom < -_panData.step[2]) {
            newBottom = -_panData.step[2];
        }
        _contentViewBottomConstraint.constant = newBottom;
        if (-newBottom >= _panData.step[1] && -newBottom <= _panData.step[2]) {
            self.bgView.alpha = 1 - ((-newBottom - _panData.step[1]) / (_panData.step[2] - _panData.step[1]));
        } else {
            self.bgView.alpha = 1;
        }
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _message.reactionList.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    EMMessageReaction *reaction = _message.reactionList[indexPath.item];
    EMBottomReactionDetailReactionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.reaction = reaction.reaction;
    cell.count = reaction.count;
    cell.reactionSelected = _reactionSelectedIndex == indexPath.item;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_message.reactionList.count > _reactionSelectedIndex) {
        NSString *reaction = _message.reactionList[_reactionSelectedIndex].reaction;
        return _reactionUserListMap[reaction].dataList.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reaction = [_message.reactionList objectAtIndex:_reactionSelectedIndex].reaction;
    EMBottomReactionDetailUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    __weak typeof(self)weakSelf = self;
    cell.didClickRemove = ^{
        [EMClient.sharedClient.chatManager removeReaction:reaction fromMessage:weakSelf.message.messageId completion:^(EMError * _Nullable error) {
            if (!error && weakSelf.didRemoveSelfReaction) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSInteger reactionCount = weakSelf.message.reactionList.count;
                    if (reactionCount <= 0) {
                        [EMBottomReactionDetailView hideWithAnimation:YES needClear:NO];
                        return;
                    }
                    NSInteger selectedIndex = weakSelf.reactionSelectedIndex;
                    if (selectedIndex >= reactionCount) {
                        selectedIndex = reactionCount - 1;
                    }
                    [weakSelf.emojiCollectionView reloadData];
                    [weakSelf collectionView:weakSelf.emojiCollectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:selectedIndex inSection:0]];
                    weakSelf.didRemoveSelfReaction(reaction);
                });
            }
        }];
    };
    PageWithId *page = _reactionUserListMap[reaction];
    if (page.dataList.count > indexPath.row) {
        cell.userId = page.dataList[indexPath.row];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    _reactionSelectedIndex = indexPath.item;
    [_itemTableView.mj_footer endRefreshing];
    for (EMBottomReactionDetailReactionCell *cell in [collectionView visibleCells]) {
        cell.reactionSelected = [collectionView indexPathForCell:cell].item == indexPath.item;
    }
    [self loadUserListData:YES];
}

@end
