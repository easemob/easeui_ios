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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopContraint;

@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) CAShapeLayer *bgMaskLayer;

@property (nonatomic, strong) NSArray <NSString *>*emojiDataList;
@property (nonatomic, strong) NSArray <EaseExtMenuModel *>*menuItems;
@property (nonatomic, strong) NSArray <UIBezierPath *>*bgMaskPaths;

@property (nonatomic, weak) id<EMBottomMoreFunctionViewDelegate> delegate;
@property (nonatomic, strong) NSDictionary *userInfo;

@property (nonatomic, assign) BOOL showReaction;
@property (nonatomic, assign) BOOL isShowEmojiList;

@property (nonatomic, assign) PanData panData;

@property (nonatomic, strong) NSMutableArray <UIImageView *>*maskHighlightImageViews;

@end

@implementation EMBottomMoreFunctionView

static EMBottomMoreFunctionView *shareView;

+ (instancetype)share {
    if (!shareView) {
        shareView = [NSBundle.mainBundle loadNibNamed:NSStringFromClass(self.class) owner:nil options:nil].firstObject;
    }
    return shareView;
}

+ (void)showMenuItems:(NSArray<EaseExtMenuModel *> *)menuItems delegate:(id<EMBottomMoreFunctionViewDelegate>)delegate animation:(BOOL)animation {
    [self showMenuItems:menuItems delegate:delegate ligheViews:nil animation:animation userInfo:nil];
}

+ (void)showMenuItems:(NSArray<EaseExtMenuModel *> *)menuItems delegate:(id<EMBottomMoreFunctionViewDelegate>)delegate animation:(BOOL)animation userInfo:(NSDictionary *)userInfo {
    [self showMenuItems:menuItems delegate:delegate ligheViews:nil animation:animation userInfo:userInfo];
}

+ (void)showMenuItems:(NSArray<EaseExtMenuModel *> *)menuItems delegate:(id<EMBottomMoreFunctionViewDelegate>)delegate ligheViews:(NSArray <UIView *>*)views animation:(BOOL)animation userInfo:(NSDictionary *)userInfo {
    [self showMenuItems:menuItems showReaction:NO delegate:delegate ligheViews:views animation:animation userInfo:userInfo];
}

+ (void)showMenuItems:(NSArray<EaseExtMenuModel *> *)menuItems showReaction:(BOOL)showReaction delegate:(id<EMBottomMoreFunctionViewDelegate>)delegate ligheViews:(NSArray<UIView *> *)views animation:(BOOL)animation userInfo:(NSDictionary *)userInfo {
    EMBottomMoreFunctionView *shareView = EMBottomMoreFunctionView.share;
    [UIApplication.sharedApplication.keyWindow addSubview:shareView];
    shareView.frame = UIApplication.sharedApplication.keyWindow.bounds;
    shareView.menuItems = menuItems;
    shareView.delegate = delegate;
    shareView.userInfo = userInfo;
    shareView.bgView.alpha = 1;
    shareView.isShowEmojiList = NO;
    shareView.showReaction = showReaction;
    [shareView.itemTableView reloadData];
    [shareView.emojiCollectionView reloadData];
    shareView.itemTableView.scrollEnabled = NO;
    shareView.emojiCollectionViewHeightConstraint.constant = 40;
    shareView.itemTableViewHeightConstraint.constant = 54 * menuItems.count;
    shareView.bgView.alpha = 0;
    shareView.maskHighlightViews = views;
    shareView.emojiCollectionView.hidden = !showReaction;
    shareView.tableViewTopContraint.constant = showReaction ? 83 : 31;
    
    if (showReaction) {
        CGFloat spacing = (UIScreen.mainScreen.bounds.size.width - 30 - shareView.emojiDataList.count * 40) / (shareView.emojiDataList.count - 1);
        UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)shareView.emojiCollectionView.collectionViewLayout;
        layout.itemSize = CGSizeMake(40, 40);
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = floor(spacing);
        layout.sectionInset = UIEdgeInsetsMake(0, 15, 0, 15);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    
    if (animation) {
        [shareView layoutIfNeeded];
        shareView.contentViewBottomConstraint.constant = -shareView.mainView.bounds.size.height;
        [shareView layoutIfNeeded];
        if (menuItems.count > 3) {
            shareView.contentViewBottomConstraint.constant = -54 * (CGFloat)(menuItems.count - 3) - EMBottomMoreFunctionView.share.bottomContainerHeightConstraint.constant;
        } else {
            shareView.contentViewBottomConstraint.constant = 0;
        }
        [UIView animateWithDuration:0.25 animations:^{
            [shareView layoutIfNeeded];
            shareView.bgView.alpha = 1;
        } completion:^(BOOL finished) {
            [shareView resetPanData];
        }];
    } else {
        shareView.bgView.alpha = 1;
        shareView.contentViewBottomConstraint.constant = -350 - shareView.bottomContainerHeightConstraint.constant;
        [shareView layoutIfNeeded];
        [shareView resetPanData];
    }
}

+ (void)updateHighlightViews:(nullable NSArray <UIView *>*)views {
    shareView.maskHighlightViews = views;
}

+ (void)hideWithAnimation:(BOOL)animation needClear:(BOOL)needClear {
    void(^clearFunc)(void) = ^{
        [shareView removeFromSuperview];
        if (needClear) {
            shareView = nil;
        }
    };
    if (animation) {
        shareView.contentViewBottomConstraint.constant = -shareView.frame.size.height;
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

- (UIImage *)convertViewToImage:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *imageRet = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageRet;
}

- (void)setMaskHighlightViews:(NSArray<UIView *> *)maskHighlightViews {
    if (!_maskHighlightImageViews) {
        _maskHighlightImageViews = [NSMutableArray array];
    }
    if (maskHighlightViews.count > _maskHighlightImageViews.count) {
        NSUInteger loopCount = maskHighlightViews.count - _maskHighlightImageViews.count;
        for (int i = 0; i < loopCount; i ++) {
            UIImageView *imageView = [[UIImageView alloc] init];
            [_bgView addSubview:imageView];
            [_maskHighlightImageViews addObject:imageView];
        }
    }
    
    for (int i = 0; i < _maskHighlightImageViews.count; i ++) {
        if (i >= maskHighlightViews.count) {
            _maskHighlightImageViews[i].hidden = YES;
        } else {
            UIView *highlightView = maskHighlightViews[i];
            UIImageView *imageView = _maskHighlightImageViews[i];
            imageView.hidden = NO;
            imageView.image = [self convertViewToImage:highlightView];
            imageView.frame = [highlightView.superview convertRect:highlightView.frame toView:UIApplication.sharedApplication.keyWindow];
        }
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    if (@available(iOS 11.0, *)) {
        _bottomContainerHeightConstraint.constant = UIApplication.sharedApplication.keyWindow.safeAreaInsets.bottom;
    }
    
    _emojiDataList = @[@"emoji_40", @"emoji_43", @"emoji_37", @"emoji_36", @"emoji_15", @"emoji_10", @"add_reaction"];
    [_emojiCollectionView registerNib:[UINib nibWithNibName:@"EMBottomMoreFunctionViewEmojiCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    [_itemTableView registerNib:[UINib nibWithNibName:@"EMBottomMoreFunctionViewMenuItemCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    
    _shapeLayer = [[CAShapeLayer alloc] init];
    _mainView.layer.mask = _shapeLayer;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _shapeLayer.frame = _mainView.bounds;
    _bgMaskLayer.frame = self.bounds;
    
    CGFloat radius = 24;
    UIRectCorner corner = UIRectCornerTopLeft | UIRectCornerTopRight;
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:_mainView.bounds byRoundingCorners:corner cornerRadii:CGSizeMake(radius, radius)];
    
    _shapeLayer.frame = _mainView.bounds;
    _shapeLayer.path = path.CGPath;
}

- (void)resetPanData {
    _panData.step[0] = 0;
    if (_menuItems.count > 3) {
        _panData.step[1] = (_menuItems.count - 3) * 54 + shareView.bottomContainerHeightConstraint.constant;
    } else {
        _panData.step[1] = 0;
    }
    _panData.step[2] = shareView.mainView.bounds.size.height;
}

- (void)switchEmojiListView {
    CGFloat spacing = (UIScreen.mainScreen.bounds.size.width - 14 - _emojiDataList.count * 40) / (_emojiDataList.count - 1);

    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)_emojiCollectionView.collectionViewLayout;
    layout.itemSize = CGSizeMake(40, 40);
    layout.minimumInteritemSpacing = floor(spacing);
    layout.sectionInset = UIEdgeInsetsMake(0, 7, 0, 7);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    [_emojiCollectionView setCollectionViewLayout:layout animated:YES];
    
    _isShowEmojiList = YES;
    [_emojiCollectionView reloadData];
    
    _emojiCollectionViewHeightConstraint.constant = 344;
    self.contentViewBottomConstraint.constant -= 344 - 36 - self.itemTableViewHeightConstraint.constant;
    _itemTableViewHeightConstraint.constant = 0;
    [UIView animateWithDuration:0.35 animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        self->_panData.step[1] = self.mainView.bounds.size.height - self->_panData.step[2] + self->_panData.step[1];
        self->_panData.step[2] = self.mainView.bounds.size.height;
    }];
}

- (IBAction)onBgViewTap:(UITapGestureRecognizer *)sender {
    [EMBottomMoreFunctionView hideWithAnimation:YES needClear:NO];
}

- (IBAction)onContentViewPan:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        _panData.beiginBottom = _contentViewBottomConstraint.constant;
    } else if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled) {
        CGFloat offset = [sender translationInView:self].y;
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
            _bgView.alpha = 1 - ((-newBottom - _panData.step[1]) / (_panData.step[2] - _panData.step[1]));
        } else {
            _bgView.alpha = 1;
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
        cell.imageName = [NSString stringWithFormat:@"emoji_%ld", (long)indexPath.item + 1];
    } else {
        cell.imageName = _emojiDataList[indexPath.item];
    }
    
    if (!_isShowEmojiList && indexPath.item >= _emojiDataList.count - 1) {
        cell.added = NO;
    } else {
        if (_delegate && [_delegate conformsToProtocol:@protocol(EMBottomMoreFunctionViewDelegate)] && [_delegate respondsToSelector:@selector(bottomMoreFunctionView:getEmojiIsSelected:userInfo:)]) {
            cell.added = [_delegate bottomMoreFunctionView:self getEmojiIsSelected:cell.imageName userInfo:_userInfo];
        } else {
            cell.added = NO;
        }
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (!_isShowEmojiList && indexPath.item >= _emojiDataList.count - 1) {
        [self switchEmojiListView];
        return;
    }
    
    if (_delegate && [_delegate conformsToProtocol:@protocol(EMBottomMoreFunctionViewDelegate)]) {
        if ([_delegate respondsToSelector:@selector(bottomMoreFunctionView:didSelectedEmoji:changeSelectedStateHandle:)]) {
            __weak typeof(self)weakSelf = self;
            if (_isShowEmojiList) {
                [_delegate bottomMoreFunctionView:self didSelectedEmoji:[NSString stringWithFormat:@"emoji_%ld", (long)indexPath.item + 1] changeSelectedStateHandle:^{
                    [weakSelf.emojiCollectionView reloadData];
                }];
            } else {
                [_delegate bottomMoreFunctionView:self didSelectedEmoji:_emojiDataList[indexPath.item] changeSelectedStateHandle:^{
                    [weakSelf.emojiCollectionView reloadData];
                }];
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
    if (_delegate && [_delegate conformsToProtocol:@protocol(EMBottomMoreFunctionViewDelegate)] && [_delegate respondsToSelector:@selector(bottomMoreFunctionView:didSelectedMenuItem:)]) {
        [_delegate bottomMoreFunctionView:self didSelectedMenuItem:_menuItems[indexPath.row]];
    }
}

@end
