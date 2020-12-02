//
//  EaseCollectionViewItemKey.h
//  PSPDFKit
//
//  Copyright (c) 2012-2013 Peter Steinberger. All rights reserved.
//

#import "EaseCollectionViewCommon.h"
#import "EaseCollectionViewLayout.h"

extern NSString *const PSTCollectionElementKindCell;
extern NSString *const PSTCollectionElementKindDecorationView;
@class EaseCollectionViewLayoutAttributes;

NSString *EaseCollectionViewItemTypeToString(EaseCollectionViewItemType type); // debug helper

// Used in NSDictionaries
@interface EaseCollectionViewItemKey : NSObject <NSCopying>

+ (id)collectionItemKeyForLayoutAttributes:(EaseCollectionViewLayoutAttributes *)layoutAttributes;

+ (id)collectionItemKeyForCellWithIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, assign) EaseCollectionViewItemType type;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) NSString *identifier;

@end
