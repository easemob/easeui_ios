//
//  EMMoreFunctionView.m
//  EaseIM
//
//  Created by 娜塔莎 on 2019/10/23.
//  Copyright © 2019 娜塔莎. All rights reserved.
//

#define pageSize 8

#import "EMMoreFunctionView.h"
#import "HorizontalLayout.h"
#import "UIImage+EaseUI.h"

@implementation EaseExtMenuViewModel
- (instancetype)initWithType:(ExtType)type itemCount:(NSInteger)itemCount
{
    self = [super init];
    if (self) {
        _type = type;
        _itemCount = itemCount;
        return self;
    }
    return self;
}
- (CGFloat)cellLonger
{
    if (_type == ExtTypeChatBar) {
        return 60;
    }
    return 50;
}
- (CGFloat)xOffset
{
    return (self.collectionViewSize.width - self.cellLonger * self.rowCount) / (self.rowCount + 1);
}
- (CGFloat)yOffset
{
    return (self.collectionViewSize.height - (self.cellLonger + 18) * self.columCount) / (self.columCount + 1);
}
- (CGSize)collectionViewSize
{
    if (_type == ExtTypeChatBar) {
        return CGSizeMake([UIScreen mainScreen].bounds.size.width, 200);
    }
    return CGSizeMake(self.rowCount * 50 , self.columCount * 80);
}
- (NSInteger)rowCount
{
    if (_type == ExtTypeChatBar) {
        return 4;
    }
    return _itemCount > 6 ? 6 : _itemCount;
}
- (NSInteger)columCount
{
    if (_type == ExtTypeChatBar) {
        return 2;
    }
    return _itemCount > 6 ? 2 : 1;
}
- (CGFloat)fontSize
{
    if (_type == ExtTypeChatBar) {
        return 12;
    }
    return 12;
}
- (UIColor *)fontColor
{
    if (_type == ExtTypeChatBar) {
        return inputBarFontColor;
    }
    return longPressFontColor;
}
- (UIColor *)bgColor
{
    if (_type == ExtTypeChatBar) {
        return inputBarBgColor;
    }
    return longPressBgColor;
}
@end


@interface EMMoreFunctionView()<UICollectionViewDataSource,SessionToolbarCellDelegate>
{
    NSInteger _itemCount;
}

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) EaseExtMenuViewModel *menuViewModel;
@property (nonatomic, strong) NSMutableArray<EaseExtMenuModel*> *extMenuModelArray;

@end

@implementation EMMoreFunctionView

- (instancetype)initWithextMenuModelArray:(NSMutableArray<EaseExtMenuModel*>*)extMenuModelArray menuViewModel:(EaseExtMenuViewModel*)menuViewModel
{
    self = [super init];
    if (self) {
        _extMenuModelArray = extMenuModelArray;
        _menuViewModel = menuViewModel;
        _itemCount = [extMenuModelArray count];
        [self _setupUI];
    }
    return self;
}

- (CGSize)getExtViewSize
{
    return _menuViewModel.collectionViewSize;
}

- (void)_setupUI {
    self.backgroundColor = _menuViewModel.bgColor;
    
    HorizontalLayout *layout = [[HorizontalLayout alloc] initWithOffset:_menuViewModel.xOffset yOffset:_menuViewModel.yOffset];
    layout.itemSize = CGSizeMake(_menuViewModel.cellLonger, _menuViewModel.cellLonger + 23.f);
    layout.rowCount = _menuViewModel.rowCount;
    layout.columCount = _menuViewModel.columCount;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, _menuViewModel.collectionViewSize.width, _menuViewModel.collectionViewSize.height) collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.dataSource = self;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.alwaysBounceHorizontal = YES;
    self.collectionView.pagingEnabled = YES;
    [self addSubview:self.collectionView];
    
    [self.collectionView registerClass:[SessionToolbarCell class] forCellWithReuseIdentifier:@"cell"];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if (_itemCount < pageSize) {
        return 1;
    }
    if (_itemCount % pageSize == 0) {
        return _itemCount / pageSize;
    }
    return _itemCount / pageSize + 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_itemCount < pageSize) {
        return _itemCount;
    }
    if ((section+1) * pageSize <= _itemCount) {
        return pageSize;
    }
    return (_itemCount - section * pageSize);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SessionToolbarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    NSInteger index = indexPath.section * pageSize + indexPath.row;
    EaseExtMenuModel *extMenuItem = (EaseExtMenuModel *)_extMenuModelArray[index];
    [cell personalizeToolbar:extMenuItem menuViewMode:_menuViewModel];
    cell.delegate = self;
    return cell;
}

#pragma mark - SessionToolbarCellDelegate

- (void)toolbarCellDidSelected:(EaseExtMenuModel*)menuItemModel
{
    if (menuItemModel.itemDidSelectedHandle) {
        menuItemModel.itemDidSelectedHandle(menuItemModel.funcDesc, YES);
    }
    if (_menuViewModel.type != ExtTypeChatBar) {
        [self removeFromSuperview];
    }
}

@end


@interface SessionToolbarCell()
{
    CGFloat _cellLonger;
}
@property (nonatomic, strong) UIButton *toolBtn;
@property (nonatomic, strong) UILabel *toolLabel;
@property (nonatomic, strong) EaseExtMenuModel *menuItemModel;
@end

@implementation SessionToolbarCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _cellLonger = frame.size.width;
        [self _setupToolbar];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)_setupToolbar {
    self.toolBtn = [[UIButton alloc]init];
    self.toolBtn.layer.masksToBounds = YES;
    [self.toolBtn addTarget:self action:@selector(cellTapAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.toolBtn];
    self.toolBtn.backgroundColor = [UIColor whiteColor];
    [self.toolBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top);
        make.width.mas_equalTo(@(_cellLonger));
        make.height.mas_equalTo(@(_cellLonger));
        make.left.equalTo(self.contentView);
    }];
    
    self.toolLabel = [[UILabel alloc]init];
    self.toolLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.toolLabel];
    [self.toolLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.toolBtn.mas_bottom).offset(3);
        make.width.mas_equalTo(@(_cellLonger));
        make.height.equalTo(@20);
        make.left.equalTo(self.contentView);
    }];
}

- (void)personalizeToolbar:(EaseExtMenuModel*)menuItemModel menuViewMode:(EaseExtMenuViewModel*)menuViewModel {
    _menuItemModel = menuItemModel;
    self.toolLabel.textColor = menuViewModel.fontColor;
    [self.toolLabel setFont:[UIFont systemFontOfSize:menuViewModel.fontSize]];
    [_toolBtn setImage:_menuItemModel.icon forState:UIControlStateNormal];
    [_toolLabel setText:_menuItemModel.funcDesc];
}

#pragma mark - Action

- (void)cellTapAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(toolbarCellDidSelected:)]) {
        [self.delegate toolbarCellDidSelected:_menuItemModel];
    }
}

@end
