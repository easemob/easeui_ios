//
//  EMBottomMoreFunctionView.m
//  EaseIMKit
//
//  Created by 冯钊 on 2022/2/22.
//

#import "EMBottomMoreFunctionView.h"
#import "EMBottomMoreFunctionViewEmojiCell.h"
#import "EMBottomMoreFunctionViewMenuItemCell.h"
#import "EaseExtMenuModel.h"

typedef struct PanData {
    CGFloat beiginY;
    CGFloat beiginBottom;
    CGFloat step[3];
    uint8_t currentStep;
} PanData;

@interface EMBottomMoreFunctionView () <UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UICollectionView *emojiCollectionView;
@property (weak, nonatomic) IBOutlet UITableView *itemTableView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emojiCollectionViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *itemTableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomContainerHeightConstraint;

@property (nonatomic, strong) CAShapeLayer *maskLayer;

@property (nonatomic, strong) NSArray <NSString *>*emojiDataList;
@property (nonatomic, strong) NSArray <EaseExtMenuModel *>*menuItems;

@property (nonatomic, strong) void(^didSelectedMenuItem)(EaseExtMenuModel *);
@property (nonatomic, strong) void(^didSelectedEmoji)(NSString *);

@property (nonatomic, assign) BOOL isShowEmojiList;

@property (nonatomic, assign) PanData panData;

@end

@implementation EMBottomMoreFunctionView

static EMBottomMoreFunctionView *shareView;

+ (instancetype)share {
    if (!shareView) {
        shareView = [NSBundle.mainBundle loadNibNamed:NSStringFromClass(self.class) owner:nil options:nil].firstObject;
    }
    return shareView;
}

+ (void)showMenuItems:(NSArray <EaseExtMenuModel *>*)menuItems
            animation:(BOOL)animation
  didSelectedMenuItem:(nonnull void (^)(EaseExtMenuModel * _Nonnull))didSelectedMenuItem
     didSelectedEmoji:(nonnull void (^)(NSString * _Nonnull))didSelectedEmoji {
    [UIApplication.sharedApplication.keyWindow addSubview:EMBottomMoreFunctionView.share];
    EMBottomMoreFunctionView.share.frame = UIApplication.sharedApplication.keyWindow.bounds;
    EMBottomMoreFunctionView.share.menuItems = menuItems;
    EMBottomMoreFunctionView.share.didSelectedEmoji = didSelectedEmoji;
    EMBottomMoreFunctionView.share.didSelectedMenuItem = didSelectedMenuItem;
    EMBottomMoreFunctionView.share.bgView.alpha = 1;
    EMBottomMoreFunctionView.share.isShowEmojiList = NO;
    [EMBottomMoreFunctionView.share.itemTableView reloadData];
    [EMBottomMoreFunctionView.share.emojiCollectionView reloadData];
    
    EMBottomMoreFunctionView.share.itemTableViewHeightConstraint.constant = 54 * menuItems.count;
    if (@available(iOS 11.0, *)) {
        EMBottomMoreFunctionView.share.bottomContainerHeightConstraint.constant = UIApplication.sharedApplication.keyWindow.safeAreaInsets.bottom;
    }
    if (menuItems.count > 3) {
        EMBottomMoreFunctionView.share.contentViewBottomConstraint.constant = -54 * (CGFloat)(menuItems.count - 3) - EMBottomMoreFunctionView.share.bottomContainerHeightConstraint.constant;
    }
    EMBottomMoreFunctionView.share.emojiCollectionViewHeightConstraint.constant = 30;
}

+ (void)hideWithAnimation:(BOOL)animation needClear:(BOOL)needClear {
    void(^clearFunc)(void) = ^{
        [EMBottomMoreFunctionView.share removeFromSuperview];
        if (needClear) {
            shareView = nil;
        }
    };
    if (animation) {
        EMBottomMoreFunctionView.share.contentViewBottomConstraint.constant = -EMBottomMoreFunctionView.share.frame.size.height;
        [UIView animateWithDuration:0.25 animations:^{
            [EMBottomMoreFunctionView.share layoutIfNeeded];
            EMBottomMoreFunctionView.share.bgView.alpha = 0;
        } completion:^(BOOL finished) {
            clearFunc();
        }];
    } else {
        clearFunc();
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _emojiDataList = @[@"ee_21", @"ee_15", @"ee_1", @"ee_19", @"ee_41", @"ee_28", @"add_reaction"];
    CGFloat spacing = (UIScreen.mainScreen.bounds.size.width - 40 - _emojiDataList.count * 30) / (_emojiDataList.count - 1);
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)_emojiCollectionView.collectionViewLayout;
    layout.itemSize = CGSizeMake(30, 30);
    layout.minimumLineSpacing = 20;
    layout.minimumInteritemSpacing = spacing;
    layout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    [_emojiCollectionView registerNib:[UINib nibWithNibName:@"EMBottomMoreFunctionViewEmojiCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    [_itemTableView registerNib:[UINib nibWithNibName:@"EMBottomMoreFunctionViewMenuItemCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    
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

- (void)switchEmojiListView {
    CGFloat spacing = (UIScreen.mainScreen.bounds.size.width - 24 - _emojiDataList.count * 30) / (_emojiDataList.count - 1);

    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)_emojiCollectionView.collectionViewLayout;
    layout.itemSize = CGSizeMake(30, 30);
    layout.minimumLineSpacing = 20;
    layout.minimumInteritemSpacing = spacing;
    layout.sectionInset = UIEdgeInsetsMake(0, 12, 0, 12);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    [_emojiCollectionView setCollectionViewLayout:layout animated:YES];
    
    _isShowEmojiList = YES;
    [_emojiCollectionView reloadData];
    
    self.emojiCollectionViewHeightConstraint.constant = 280 + 32 * 2;
    self.itemTableViewHeightConstraint.constant = 0;
    [UIView animateWithDuration:0.35 animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.contentViewBottomConstraint.constant += self.itemTableViewHeightConstraint.constant;
        self.itemTableViewHeightConstraint.constant = 0;
    }];
}

- (IBAction)onBgViewTap:(UITapGestureRecognizer *)sender {
    [EMBottomMoreFunctionView hideWithAnimation:YES needClear:NO];
}

- (IBAction)onContentViewPan:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        _panData.beiginY = [sender locationInView:self].y;
        _panData.beiginBottom = _contentViewBottomConstraint.constant;
        _panData.step[0] = 0;
        if (_isShowEmojiList) {
            _panData.step[2] = _mainView.bounds.size.height;
        } else {
            _panData.step[1] = (CGRectGetHeight(_itemTableView.frame) - 3 * 54) + _bottomContainerHeightConstraint.constant;
            _panData.step[2] = _mainView.bounds.size.height;
        }
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

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_isShowEmojiList) {
        return 49;
    } else {
        return _emojiDataList.count;
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    EMBottomMoreFunctionViewEmojiCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    if (_isShowEmojiList) {
        cell.imageName = [NSString stringWithFormat:@"ee_%ld", (long)indexPath.item + 1];
    } else {
        cell.imageName = _emojiDataList[indexPath.item];
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_didSelectedEmoji) {
        if (_isShowEmojiList) {
            _didSelectedEmoji([NSString stringWithFormat:@"ee_%ld", (long)indexPath.item + 1]);
        } else {
            if (indexPath.item < _emojiDataList.count - 1) {
                _didSelectedEmoji(_emojiDataList[indexPath.item]);
            } else {
                [self switchEmojiListView];
            }
        }
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EMBottomMoreFunctionViewMenuItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.menuItem = _menuItems[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_didSelectedMenuItem) {
        _didSelectedMenuItem(_menuItems[indexPath.row]);
    }
}

@end
