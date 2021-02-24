//
//  EaseCollectionViewCommon.h
//  PSPDFKit
//
//  Copyright (c) 2012-2013 Peter Steinberger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Mostly a debug feature, makes classes from UICollection* compatible with PSTCollection*
// (e.g. adding the "real" UICollectionViewFlowLayout to EaseCollectionView.
//#define kPSUIInteroperabilityEnabled

@class EaseCollectionView, EaseCollectionViewCell, EaseCollectionReusableView;

@protocol EaseCollectionViewDataSource <NSObject>
@required

- (NSInteger)collectionView:(EaseCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (EaseCollectionViewCell *)collectionView:(EaseCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;

@optional

- (NSInteger)numberOfSectionsInCollectionView:(EaseCollectionView *)collectionView;

// The view that is returned must be retrieved from a call to -dequeueReusableSupplementaryViewOfKind:withReuseIdentifier:forIndexPath:
- (EaseCollectionReusableView *)collectionView:(EaseCollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;

@end

@protocol EaseCollectionViewDelegate <UIScrollViewDelegate>
@optional

// Methods for notification of selection/deselection and highlight/unhighlight events.
// The sequence of calls leading to selection from a user touch is:
//
// (when the touch begins)
// 1. -collectionView:shouldHighlightItemAtIndexPath:
// 2. -collectionView:didHighlightItemAtIndexPath:
//
// (when the touch lifts)
// 3. -collectionView:shouldSelectItemAtIndexPath: or -collectionView:shouldDeselectItemAtIndexPath:
// 4. -collectionView:didSelectItemAtIndexPath: or -collectionView:didDeselectItemAtIndexPath:
// 5. -collectionView:didUnhighlightItemAtIndexPath:
- (BOOL)collectionView:(EaseCollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)collectionView:(EaseCollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)collectionView:(EaseCollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath;

- (BOOL)collectionView:(EaseCollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath;

- (BOOL)collectionView:(EaseCollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath; // called when the user taps on an already-selected item in multi-select mode
- (void)collectionView:(EaseCollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)collectionView:(EaseCollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)collectionView:(EaseCollectionView *)collectionView didEndDisplayingCell:(EaseCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)collectionView:(EaseCollectionView *)collectionView didEndDisplayingSupplementaryView:(EaseCollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath;

// These methods provide support for copy/paste actions on cells.
// All three should be implemented if any are.
- (BOOL)collectionView:(EaseCollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath;

- (BOOL)collectionView:(EaseCollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender;

- (void)collectionView:(EaseCollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender;

@end
