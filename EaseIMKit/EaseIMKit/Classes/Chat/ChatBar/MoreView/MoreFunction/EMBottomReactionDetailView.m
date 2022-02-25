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

@import HyphenateChat;

typedef struct PanData {
    CGFloat beiginY;
    CGFloat beiginBottom;
    CGFloat step[3];
    uint8_t currentStep;
} PanData;

@interface EMBottomReactionDetailCollectionItem : NSObject

@property (nonatomic, copy) NSString *messageId;
@property (nonatomic, copy) NSString *reaction;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, assign) CGFloat width;

@end

@implementation EMBottomReactionDetailCollectionItem
@end

@import HyphenateChat;

@interface EMBottomReactionDetailView () <UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UICollectionView *emojiCollectionView;
@property (weak, nonatomic) IBOutlet UITableView *itemTableView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emojiCollectionViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *itemTableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomContainerHeightConstraint;

@property (nonatomic, strong) CAShapeLayer *maskLayer;


@property (nonatomic, strong) EMChatMessage *message;
@property (nonatomic, strong) NSMutableArray <EMBottomReactionDetailCollectionItem *>* collectionItems;

@property (nonatomic, assign) PanData panData;
@property (nonatomic, assign) NSInteger reactionSelectedIndex;

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
    [UIApplication.sharedApplication.keyWindow addSubview:EMBottomReactionDetailView.share];
    EMBottomReactionDetailView.share.frame = UIApplication.sharedApplication.keyWindow.bounds;
    EMBottomReactionDetailView.share.message = message;
    EMBottomReactionDetailView.share.bgView.alpha = 1;
    
    EMBottomReactionDetailView.share.itemTableViewHeightConstraint.constant = 62 * 5.5;
    EMBottomReactionDetailView.share.contentViewBottomConstraint.constant = 0;
    EMBottomReactionDetailView.share.reactionSelectedIndex = 0;
    if (@available(iOS 11.0, *)) {
        EMBottomReactionDetailView.share.bottomContainerHeightConstraint.constant = UIApplication.sharedApplication.keyWindow.safeAreaInsets.bottom;
    }
    
    NSMutableArray <EMBottomReactionDetailCollectionItem *>*array = [NSMutableArray array];
    for (EMMessageReaction *reaction in message.reactionList) {
        EMBottomReactionDetailCollectionItem *item = [[EMBottomReactionDetailCollectionItem alloc] init];
        item.messageId = message.messageId;
        item.reaction = reaction.reaction;
        item.count = reaction.count;
        item.width = [[NSString stringWithFormat:@"%ld", (long)item.count] boundingRectWithSize:CGSizeMake(1000, 1000) options:0 attributes:@{
            NSFontAttributeName: [UIFont systemFontOfSize:14]
        } context:nil].size.width + 48;
        [array addObject:item];
    }
    
    for (int i = 1; i < 50; i ++) {
        EMBottomReactionDetailCollectionItem *item = [[EMBottomReactionDetailCollectionItem alloc] init];
        item.messageId = @"";
        item.reaction = [NSString stringWithFormat:@"ee_%d", i];
        item.count = random() % 10000;
        item.width = [[NSString stringWithFormat:@"%ld", (long)item.count] boundingRectWithSize:CGSizeMake(1000, 1000) options:0 attributes:@{
            NSFontAttributeName: [UIFont systemFontOfSize:14]
        } context:nil].size.width + 48;
        [array addObject:item];
    }
    
    EMBottomReactionDetailView.share.collectionItems = array;
    
    [EMBottomReactionDetailView.share.itemTableView reloadData];
    [EMBottomReactionDetailView.share.emojiCollectionView reloadData];
}

+ (void)hideWithAnimation:(BOOL)animation needClear:(BOOL)needClear {
    void(^clearFunc)(void) = ^{
        [EMBottomReactionDetailView.share removeFromSuperview];
        if (needClear) {
            shareView = nil;
        }
    };
    if (animation) {
        EMBottomReactionDetailView.share.contentViewBottomConstraint.constant = -EMBottomReactionDetailView.share.frame.size.height;
        [UIView animateWithDuration:0.25 animations:^{
            [EMBottomReactionDetailView.share layoutIfNeeded];
            EMBottomReactionDetailView.share.bgView.alpha = 0;
        } completion:^(BOOL finished) {
            clearFunc();
        }];
    } else {
        clearFunc();
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
        
    EMBottomReactionDetailViewCollectionViewLayout *layout = (EMBottomReactionDetailViewCollectionViewLayout *)_emojiCollectionView.collectionViewLayout;
    layout.contentInsets = UIEdgeInsetsMake(0, 12, 0, 12);
    layout.spacing = 4;
    __weak typeof(self)weakSelf = self;
    layout.getCellItemWidth = ^CGFloat(NSIndexPath * _Nonnull indexPath) {
        return weakSelf.collectionItems[indexPath.item].width;
    };
    [_emojiCollectionView registerNib:[UINib nibWithNibName:@"EMBottomReactionDetailReactionCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    [_itemTableView registerNib:[UINib nibWithNibName:@"EMBottomReactionDetailUserCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    
    _collectionItems = [NSMutableArray array];
    
    CGFloat radius = 24;
    UIRectCorner corner = UIRectCornerTopLeft | UIRectCornerTopRight;
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:_mainView.bounds byRoundingCorners:corner cornerRadii:CGSizeMake(radius, radius)];
    _maskLayer = [[CAShapeLayer alloc] init];
    _maskLayer.frame = _mainView.bounds;
    _maskLayer.path = path.CGPath;
    _mainView.layer.mask = _maskLayer;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _maskLayer.frame = _mainView.bounds;
}

- (IBAction)onBgViewTap:(UITapGestureRecognizer *)sender {
    [self.class hideWithAnimation:YES needClear:NO];
}

- (IBAction)onContentViewPan:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        _panData.beiginY = [sender locationInView:self].y;
        _panData.beiginBottom = _contentViewBottomConstraint.constant;
        _panData.step[0] = 0;
        _panData.step[1] = (CGRectGetHeight(_itemTableView.frame) - 3 * 54) + _bottomContainerHeightConstraint.constant;
        _panData.step[2] = _mainView.bounds.size.height;
    } else if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled) {
        CGFloat currentY = [sender locationInView:self].y;
        CGFloat offset = currentY - _panData.beiginY;
        CGFloat newBottom = _panData.beiginBottom - offset;
        if (newBottom > 0) {
            newBottom = 0;
        }
        
        CGFloat minDistance = 0;
        int index = -1;
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
        }];
    } else {
        CGFloat currentY = [sender locationInView:self].y;
        CGFloat offset = currentY - _panData.beiginY;
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
    return _collectionItems.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    EMBottomReactionDetailCollectionItem *item = _collectionItems[indexPath.item];
    EMBottomReactionDetailReactionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.reaction = item.reaction;
    cell.count = item.count;
    cell.reactionSelected = _reactionSelectedIndex == indexPath.item;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EMBottomReactionDetailUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    __weak typeof(self)weakSelf = self;
    cell.didClickRemove = ^{
        [EMClient.sharedClient.reactionManager removeReaction:@"" fromMessage:@""];
    };
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    _reactionSelectedIndex = indexPath.item;
    for (EMBottomReactionDetailReactionCell *cell in [collectionView visibleCells]) {
        cell.reactionSelected = [collectionView indexPathForCell:cell].item == indexPath.item;
    }
}

@end
