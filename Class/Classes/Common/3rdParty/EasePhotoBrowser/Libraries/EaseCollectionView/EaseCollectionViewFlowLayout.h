//
//  EaseCollectionViewFlowLayout.h
//  PSPDFKit
//
//  Copyright (c) 2012-2013 Peter Steinberger. All rights reserved.
//

#import "EaseCollectionViewLayout.h"

extern NSString *const PSTCollectionElementKindSectionHeader;
extern NSString *const PSTCollectionElementKindSectionFooter;

typedef NS_ENUM(NSInteger, EaseCollectionViewScrollDirection) {
    EaseCollectionViewScrollDirectionVertical,
    EaseCollectionViewScrollDirectionHorizontal
};

@protocol EaseCollectionViewDelegateFlowLayout <EaseCollectionViewDelegate>
@optional

- (CGSize)collectionView:(EaseCollectionView *)collectionView layout:(EaseCollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
- (UIEdgeInsets)collectionView:(EaseCollectionView *)collectionView layout:(EaseCollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section;
- (CGFloat)collectionView:(EaseCollectionView *)collectionView layout:(EaseCollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section;
- (CGFloat)collectionView:(EaseCollectionView *)collectionView layout:(EaseCollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section;
- (CGSize)collectionView:(EaseCollectionView *)collectionView layout:(EaseCollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section;
- (CGSize)collectionView:(EaseCollectionView *)collectionView layout:(EaseCollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section;
- (EaseCollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;

@end

@class EaseGridLayoutInfo;

@interface EaseCollectionViewFlowLayout : EaseCollectionViewLayout

@property (nonatomic) CGFloat minimumLineSpacing;
@property (nonatomic) CGFloat minimumInteritemSpacing;
@property (nonatomic) CGSize itemSize; // for the cases the delegate method is not implemented
@property (nonatomic) EaseCollectionViewScrollDirection scrollDirection; // default is EaseCollectionViewScrollDirectionVertical
@property (nonatomic) CGSize headerReferenceSize;
@property (nonatomic) CGSize footerReferenceSize;

@property (nonatomic) UIEdgeInsets sectionInset;

/*
 Row alignment options exits in the official UICollectionView, but hasn't been made public API.

 Here's a snippet to test this on UICollectionView:

 NSMutableDictionary *rowAlign = [[flowLayout valueForKey:@"_rowAlignmentsOptionsDictionary"] mutableCopy];
 rowAlign[@"UIFlowLayoutCommonRowHorizontalAlignmentKey"] = @(1);
 rowAlign[@"UIFlowLayoutLastRowHorizontalAlignmentKey"] = @(3);
 [flowLayout setValue:rowAlign forKey:@"_rowAlignmentsOptionsDictionary"];
 */
@property (nonatomic, strong) NSDictionary *rowAlignmentOptions;

@end

// @steipete addition, private API in UICollectionViewFlowLayout
extern NSString *const PSTFlowLayoutCommonRowHorizontalAlignmentKey;
extern NSString *const PSTFlowLayoutLastRowHorizontalAlignmentKey;
extern NSString *const PSTFlowLayoutRowVerticalAlignmentKey;

typedef NS_ENUM(NSInteger, PSTFlowLayoutHorizontalAlignment) {
    PSTFlowLayoutHorizontalAlignmentLeft,
    PSTFlowLayoutHorizontalAlignmentCentered,
    PSTFlowLayoutHorizontalAlignmentRight,
    PSTFlowLayoutHorizontalAlignmentJustify // 3; default except for the last row
};
// TODO: settings for UIFlowLayoutRowVerticalAlignmentKey


/*
@interface EaseCollectionViewFlowLayout (Private)

- (CGSize)synchronizeLayout;

// For items being inserted or deleted, the collection view calls some different methods, which you should override to provide the appropriate layout information.
- (EaseCollectionViewLayoutAttributes *)initialLayoutAttributesForFooterInInsertedSection:(NSInteger)section;
- (EaseCollectionViewLayoutAttributes *)initialLayoutAttributesForHeaderInInsertedSection:(NSInteger)section;
- (EaseCollectionViewLayoutAttributes *)initialLayoutAttributesForInsertedItemAtIndexPath:(NSIndexPath *)indexPath;
- (EaseCollectionViewLayoutAttributes *)finalLayoutAttributesForFooterInDeletedSection:(NSInteger)section;
- (EaseCollectionViewLayoutAttributes *)finalLayoutAttributesForHeaderInDeletedSection:(NSInteger)section;
- (EaseCollectionViewLayoutAttributes *)finalLayoutAttributesForDeletedItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)_updateItemsLayout;
- (void)_getSizingInfos;
- (void)_updateDelegateFlags;

- (EaseCollectionViewLayoutAttributes *)layoutAttributesForFooterInSection:(NSInteger)section;
- (EaseCollectionViewLayoutAttributes *)layoutAttributesForHeaderInSection:(NSInteger)section;
- (EaseCollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath usingData:(id)data;
- (EaseCollectionViewLayoutAttributes *)layoutAttributesForFooterInSection:(NSInteger)section usingData:(id)data;
- (EaseCollectionViewLayoutAttributes *)layoutAttributesForHeaderInSection:(NSInteger)section usingData:(id)data;

- (id)indexesForSectionFootersInRect:(CGRect)rect;
- (id)indexesForSectionHeadersInRect:(CGRect)rect;
- (id)indexPathsForItemsInRect:(CGRect)rect usingData:(id)arg2;
- (id)indexesForSectionFootersInRect:(CGRect)rect usingData:(id)arg2;
- (id)indexesForSectionHeadersInRect:(CGRect)arg1 usingData:(id)arg2;
- (CGRect)_frameForItemAtSection:(int)arg1 andRow:(int)arg2 usingData:(id)arg3;
- (CGRect)_frameForFooterInSection:(int)arg1 usingData:(id)arg2;
- (CGRect)_frameForHeaderInSection:(int)arg1 usingData:(id)arg2;
- (void)_invalidateLayout;
- (NSIndexPath *)indexPathForItemAtPoint:(CGPoint)arg1;
- (EaseCollectionViewLayoutAttributes *)_layoutAttributesForItemsInRect:(CGRect)arg1;
- (CGSize)collectionViewContentSize;
- (void)finalizeCollectionViewUpdates;
- (void)_invalidateButKeepDelegateInfo;
- (void)_invalidateButKeepAllInfo;
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)arg1;
- (id)layoutAttributesForElementsInRect:(CGRect)arg1;
- (void)invalidateLayout;
- (id)layoutAttributesForItemAtIndexPath:(id)arg1;

@end
*/
