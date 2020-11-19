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

@implementation EMExtModel
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
        return 55;
    }
    return 30;
}
- (CGSize)collectionViewSize
{
    if (_type == ExtTypeChatBar) {
        return CGSizeMake([UIScreen mainScreen].bounds.size.width, 200);
    }
    return CGSizeMake(self.rowCount * 55 , self.columCount * 55);
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
    NSMutableArray<UIImage*> *_toolbarImgArray;
    NSMutableArray<NSString*> *_toolbarDescArray;
    BOOL _isCustom;
    NSInteger _itemImgCount;
    NSInteger _itemDescCount;
}

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) EMConversation *conversation;
@property (nonatomic, strong) EMMessageCell *messageCell;
@property (nonatomic, strong) EMExtModel *model;

@end

@implementation EMMoreFunctionView

- (instancetype)initWithConversation:(EMConversation *)conversation itemDescArray:(NSMutableArray<NSString*>*)itemDescArray itemImgArray:(NSMutableArray<UIImage*>*)itemImgArray isCustom:(BOOL)isCustom
{
    self = [super init];
    if(self){
        _isCustom = isCustom;
        if (_isCustom) {
            _toolbarDescArray = itemDescArray;
            _toolbarImgArray = itemImgArray;
        } else {
            _conversation = conversation;
            _toolbarImgArray = [[NSMutableArray<UIImage*> alloc]init];
            [_toolbarImgArray addObject:[UIImage imageNamed:@"photo-album"]];
            [_toolbarImgArray addObject:[UIImage imageNamed:@"camera"]];
            [_toolbarImgArray addObject:[UIImage imageNamed:@"video_conf"]];
            [_toolbarImgArray addObject:[UIImage imageNamed:@"location"]];
            [_toolbarImgArray addObject:[UIImage imageNamed:@"icloudFile"]];
            _toolbarDescArray = [NSMutableArray arrayWithArray:@[@"相册",@"相机",@"音视频",@"位置",@"文件"]];
            if (_conversation.type == EMConversationTypeGroupChat) {
                if ([[EMClient.sharedClient.groupManager getGroupSpecificationFromServerWithId:_conversation.conversationId error:nil].owner isEqualToString:EMClient.sharedClient.currentUsername]) {
                    [_toolbarImgArray addObject:[UIImage imageNamed:@"pin_readReceipt"]];
                    [_toolbarDescArray addObject:@"群组回执"];
                }
            }
            if (_conversation.type == EMConversationTypeChatRoom) {
                [_toolbarImgArray removeObjectAtIndex:2];
                [_toolbarDescArray removeObject:@"音视频"];
            }
        }
        _itemImgCount = [_toolbarImgArray count];
        _itemDescCount = [_toolbarDescArray count];
        _model = [[EMExtModel alloc]initWithType:ExtTypeChatBar itemCount:_itemImgCount];
        [self _setupUI];
    }
    
    return self;
}

- (instancetype)initWithMessageCell:(EMMessageCell *)messageCell itemDescArray:(NSMutableArray<NSString*>*)itemDescArray itemImgArray:(NSMutableArray<UIImage*>*)itemImgArray isCustom:(BOOL)isCustom
{
    self = [super init];
    if(self){
        _isCustom = isCustom;
        _messageCell = messageCell;
        if (_isCustom) {
            _toolbarDescArray = itemDescArray;
            _toolbarImgArray = itemImgArray;
        } else {
            _toolbarImgArray = [[NSMutableArray<UIImage*> alloc]init];
            [_toolbarImgArray addObject:[UIImage imageNamed:@"photo-album"]];
            [_toolbarImgArray addObject:[UIImage imageNamed:@"camera"]];
            [_toolbarImgArray addObject:[UIImage imageNamed:@"video_conf"]];
            [_toolbarImgArray addObject:[UIImage imageNamed:@"location"]];
            [_toolbarImgArray addObject:[UIImage imageNamed:@"icloudFile"]];
            [_toolbarImgArray addObject:[UIImage imageNamed:@"icloudFile"]];
            [_toolbarImgArray addObject:[UIImage imageNamed:@"icloudFile"]];
            [_toolbarImgArray addObject:[UIImage imageNamed:@"icloudFile"]];
            [_toolbarImgArray addObject:[UIImage imageNamed:@"icloudFile"]];
            [_toolbarImgArray addObject:[UIImage imageNamed:@"icloudFile"]];
            [_toolbarImgArray addObject:[UIImage imageNamed:@"icloudFile"]];
            [_toolbarImgArray addObject:[UIImage imageNamed:@"icloudFile"]];
            [_toolbarImgArray addObject:[UIImage imageNamed:@"icloudFile"]];
            _toolbarDescArray = [NSMutableArray arrayWithArray:@[@"相册",@"相机",@"音视频",@"位置",@"文件"]];
        }
        _itemImgCount = [_toolbarImgArray count];;
        _itemDescCount = [_toolbarDescArray count];
        _model = [[EMExtModel alloc]initWithType:ExtTypeLongPress itemCount:_itemImgCount];
        [self _setupUI];
    }
    
    return self;
}

- (void)_setupUI {
    //抛出
    //self.backgroundColor = [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1.0];
    self.backgroundColor = [UIColor systemGrayColor];
    
    HorizontalLayout *layout = [[HorizontalLayout alloc] init];
    layout.itemSize = CGSizeMake(_model.cellLonger, _model.cellLonger + 13.f);
    layout.rowCount = _model.rowCount;
    layout.columCount = _model.columCount;
    layout.sectionInset = UIEdgeInsetsMake(10, 0, 0, 0);
    layout.minimumLineSpacing = [UIScreen mainScreen].bounds.size.width / 17;
    layout.minimumInteritemSpacing = 10;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, _model.collectionViewSize.width, _model.collectionViewSize.height) collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.dataSource = self;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = YES;
    self.collectionView.alwaysBounceHorizontal = YES;
    self.collectionView.pagingEnabled = YES;
    [self addSubview:self.collectionView];
    
    [self.collectionView registerClass:[SessionToolbarCell class] forCellWithReuseIdentifier:@"cell"];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if (_itemImgCount < pageSize) {
        return 1;
    }
    if (_itemImgCount % pageSize == 0) {
        return _itemImgCount / pageSize;
    }
    return _itemImgCount / pageSize + 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_itemImgCount < pageSize) {
        return _itemImgCount;
    }
    if ((section+1) * pageSize <= _itemImgCount) {
        return pageSize;
    }
    return (_itemImgCount - section * pageSize);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SessionToolbarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    NSInteger index = indexPath.section * pageSize + indexPath.row;
    [cell personalizeToolbar:_toolbarImgArray[index] funcDesc:(index < _itemDescCount) ? _toolbarDescArray[index] : @"" tag:index];
    cell.delegate = self;
    return cell;
}

#pragma mark - SessionToolbarCellDelegate

- (void)toolbarCellDidSelected:(NSInteger)tag itemDesc:(NSString*)itemDesc
{
    //custom
    if (_isCustom) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(chatBarMoreFunctionAction:itemDesc:extType:)]) {
            [self.delegate chatBarMoreFunctionAction:tag itemDesc:itemDesc extType:_model.type];
        }
        return;
    }
    /*
    //default
    if (tag == 5) {
        //群组回执
        if (self.delegate && [self.delegate respondsToSelector:@selector(chatBarMoreFunctionReadReceipt)])
            [self.delegate chatBarMoreFunctionReadReceipt];
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatBarMoreFunctionAction:)])
        [self.delegate chatBarMoreFunctionAction:tag];*/
}

@end


@interface SessionToolbarCell()
{
    NSInteger _tag;
    CGFloat _cellLonger;
}
@property (nonatomic, strong) UIButton *toolBtn;
@property (nonatomic, strong) UILabel *toolLabel;
@end

@implementation SessionToolbarCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _cellLonger = frame.size.width;
        [self _setupToolbar];
        _tag = -1;
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
    self.toolLabel.textColor = [UIColor colorWithRed:163/255.0 green:163/255.0 blue:163/255.0 alpha:1.0];
    
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

- (void)personalizeToolbar:(UIImage*)itemImg funcDesc:(NSString *)funcDesc tag:(NSInteger)tag
{
    [_toolBtn setImage:itemImg forState:UIControlStateNormal];
    [_toolLabel setText:funcDesc];
    _tag = tag;
}

#pragma mark - Action

- (void)cellTapAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(toolbarCellDidSelected:itemDesc:)]) {
        [self.delegate toolbarCellDidSelected:_tag itemDesc:_toolLabel.text];
    }
}

@end
