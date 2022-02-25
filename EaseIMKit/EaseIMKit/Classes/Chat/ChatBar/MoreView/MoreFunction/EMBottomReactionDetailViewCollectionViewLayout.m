//
//  EMBottomReactionDetailViewCollectionViewLayout.m
//  EaseIMKit
//
//  Created by 冯钊 on 2022/2/24.
//

#import "EMBottomReactionDetailViewCollectionViewLayout.h"

@interface EMBottomReactionDetailViewCollectionViewLayout ()

@property (nonatomic, strong) NSMutableArray <UICollectionViewLayoutAttributes *>*attrs;

@property (nonatomic, assign) CGFloat beginX;

@end

@implementation EMBottomReactionDetailViewCollectionViewLayout

- (void)prepareLayout {
    [super prepareLayout];
    _beginX = _contentInsets.left;
    
    if (!_attrs) {
        _attrs = [NSMutableArray array];
    } else {
        [_attrs removeAllObjects];
    }
    
    NSInteger loopCount = [self.collectionView numberOfItemsInSection:0];
    for (NSInteger i = 0; i < loopCount; i ++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        CGFloat w = _getCellItemWidth ? _getCellItemWidth(indexPath) : 0;
        attr.frame = CGRectMake(_beginX, _contentInsets.top, w, self.collectionView.bounds.size.height);
        if ([self.collectionView numberOfItemsInSection:0] > indexPath.item + 1) {
            _beginX += (w + _spacing);
        } else {
            _beginX += w;
        }
        [_attrs addObject:attr];
    }
}

- (NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    return _attrs;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return _attrs[indexPath.item];
}

- (CGSize)collectionViewContentSize {
    return CGSizeMake(_beginX + _contentInsets.right, self.collectionView.bounds.size.height);
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

@end
