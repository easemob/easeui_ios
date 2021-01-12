//
//  EaseCollectionViewItemKey.m
//  PSPDFKit
//
//  Copyright (c) 2012-2013 Peter Steinberger. All rights reserved.
//

#import "EaseCollectionViewItemKey.h"

NSString *const PSTCollectionElementKindCell = @"UICollectionElementKindCell";

@implementation EaseCollectionViewItemKey

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Static

+ (id)collectionItemKeyForCellWithIndexPath:(NSIndexPath *)indexPath {
    EaseCollectionViewItemKey *key = [self.class new];
    key.indexPath = indexPath;
    key.type = EaseCollectionViewItemTypeCell;
    key.identifier = PSTCollectionElementKindCell;
    return key;
}

+ (id)collectionItemKeyForLayoutAttributes:(EaseCollectionViewLayoutAttributes *)layoutAttributes {
    EaseCollectionViewItemKey *key = [self.class new];
    key.indexPath = layoutAttributes.indexPath;
    EaseCollectionViewItemType const itemType = layoutAttributes.representedElementCategory;
    key.type = itemType;
    key.identifier = layoutAttributes.representedElementKind;
    return key;
}

NSString *EaseCollectionViewItemTypeToString(EaseCollectionViewItemType type) {
    switch (type) {
        case EaseCollectionViewItemTypeCell: return @"Cell";
        case EaseCollectionViewItemTypeDecorationView: return @"Decoration";
        case EaseCollectionViewItemTypeSupplementaryView: return @"Supplementary";
        default: return @"<INVALID>";
    }
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p Type = %@ Identifier=%@ IndexPath = %@>", NSStringFromClass(self.class),
                                      self, EaseCollectionViewItemTypeToString(self.type), _identifier, self.indexPath];
}

- (NSUInteger)hash {
    return (([_indexPath hash] + _type) * 31) + [_identifier hash];
}

- (BOOL)isEqual:(id)other {
    if ([other isKindOfClass:self.class]) {
        EaseCollectionViewItemKey *otherKeyItem = (EaseCollectionViewItemKey *)other;
        // identifier might be nil?
        if (_type == otherKeyItem.type && [_indexPath isEqual:otherKeyItem.indexPath] && ([_identifier isEqualToString:otherKeyItem.identifier] || _identifier == otherKeyItem.identifier)) {
            return YES;
        }
    }
    return NO;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    EaseCollectionViewItemKey *itemKey = [self.class new];
    itemKey.indexPath = self.indexPath;
    itemKey.type = self.type;
    itemKey.identifier = self.identifier;
    return itemKey;
}

@end
