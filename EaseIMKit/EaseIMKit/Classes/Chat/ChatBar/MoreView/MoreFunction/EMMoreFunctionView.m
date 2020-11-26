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
    return 30;
}
- (CGFloat)xOffset
{
    return (self.collectionViewSize.width - self.cellLonger * self.rowCount) / (self.rowCount + 1);
}
- (CGFloat)yOffset
{
    return (self.collectionViewSize.height - (self.cellLonger + 13) * self.columCount) / (self.columCount + 1);
}
- (CGSize)collectionViewSize
{
    if (_type == ExtTypeChatBar) {
        return CGSizeMake([UIScreen mainScreen].bounds.size.width, 200);
    }
    return CGSizeMake(self.rowCount * 50 , self.columCount * 50);
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
@end


@interface EMMoreFunctionView()<UICollectionViewDataSource,SessionToolbarCellDelegate>
{
    NSInteger _itemCount;
}

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) EaseExtMenuViewModel *menuViewmModel;
@property (nonatomic, strong) NSMutableArray<EaseExtMenuModel*> *extMenuModelArray;

@end

@implementation EMMoreFunctionView

- (instancetype)initWithextMenuModelArray:(NSMutableArray<EaseExtMenuModel*>*)extMenuModelArray menuViewModel:(EaseExtMenuViewModel*)menuViewModel
{
    self = [super init];
    if (self) {
        _extMenuModelArray = extMenuModelArray;
        _menuViewmModel = menuViewModel;
        _itemCount = [extMenuModelArray count];
        [self _setupUI];
    }
    return self;
}

- (CGSize)getExtViewSize
{
    return _menuViewmModel.collectionViewSize;
}

- (void)_setupUI {
    //抛出
    //self.backgroundColor = [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1.0];
    self.backgroundColor = [UIColor systemGrayColor];
    
    HorizontalLayout *layout = [[HorizontalLayout alloc] initWithOffset:_menuViewmModel.xOffset yOffset:_menuViewmModel.yOffset];
    layout.itemSize = CGSizeMake(_menuViewmModel.cellLonger, _menuViewmModel.cellLonger + 13.f);
    layout.rowCount = _menuViewmModel.rowCount;
    layout.columCount = _menuViewmModel.columCount;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, _menuViewmModel.collectionViewSize.width, _menuViewmModel.collectionViewSize.height) collectionViewLayout:layout];
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
    [cell personalizeToolbar:extMenuItem];
    cell.delegate = self;
    return cell;
}

#pragma mark - SessionToolbarCellDelegate

- (void)toolbarCellDidSelected:(EaseExtMenuModel*)menuItemModel
{
    if (menuItemModel.itemDidSelectedHandle) {
        menuItemModel.itemDidSelectedHandle(menuItemModel.funcDesc);
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
    self.toolBtn.layer.cornerRadius = 8;
    self.toolBtn.layer.masksToBounds = YES;
    self.toolBtn.imageEdgeInsets = UIEdgeInsetsMake(2, 10, 2, 10);
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
    self.toolLabel.textColor = [UIColor whiteColor];
    
    [self.toolLabel setFont:[UIFont systemFontOfSize:10.0]];
    self.toolLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.toolLabel];
    [self.toolLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.toolBtn.mas_bottom).offset(3);
        make.width.mas_equalTo(@(_cellLonger));
        make.height.equalTo(@10);
        make.left.equalTo(self.contentView);
    }];
}

- (void)personalizeToolbar:(EaseExtMenuModel*)menuItemModel{
    _menuItemModel = menuItemModel;
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
