//
//  EaseCollectionViewCell.h
//  PSPDFKit
//
//  Copyright (c) 2012-2013 Peter Steinberger. All rights reserved.
//

#import "EaseCollectionViewCommon.h"

@class EaseCollectionViewLayout, EaseCollectionView, EaseCollectionViewLayoutAttributes;

@interface EaseCollectionReusableView : UIView

@property (nonatomic, readonly, copy) NSString *reuseIdentifier;

// Override in subclasses. Called before instance is returned to the reuse queue.
- (void)prepareForReuse;

// Apply layout attributes on cell.
- (void)applyLayoutAttributes:(EaseCollectionViewLayoutAttributes *)layoutAttributes;
- (void)willTransitionFromLayout:(EaseCollectionViewLayout *)oldLayout toLayout:(EaseCollectionViewLayout *)newLayout;
- (void)didTransitionFromLayout:(EaseCollectionViewLayout *)oldLayout toLayout:(EaseCollectionViewLayout *)newLayout;

@end

@interface EaseCollectionReusableView (Internal)
@property (nonatomic, unsafe_unretained) EaseCollectionView *collectionView;
@property (nonatomic, copy) NSString *reuseIdentifier;
@property (nonatomic, strong, readonly) EaseCollectionViewLayoutAttributes *layoutAttributes;
@end


@interface EaseCollectionViewCell : EaseCollectionReusableView

@property (nonatomic, readonly) UIView *contentView; // add custom subviews to the cell's contentView

// Cells become highlighted when the user touches them.
// The selected state is toggled when the user lifts up from a highlighted cell.
// Override these methods to provide custom UI for a selected or highlighted state.
// The collection view may call the setters inside an animation block.
@property (nonatomic, getter=isSelected) BOOL selected;
@property (nonatomic, getter=isHighlighted) BOOL highlighted;

// The background view is a subview behind all other views.
// If selectedBackgroundView is different than backgroundView, it will be placed above the background view and animated in on selection.
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *selectedBackgroundView;

@end
