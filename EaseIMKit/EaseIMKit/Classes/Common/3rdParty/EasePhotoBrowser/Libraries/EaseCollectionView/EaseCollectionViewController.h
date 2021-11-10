//
//  EaseCollectionViewController.h
//  PSPDFKit
//
//  Copyright (c) 2012-2013 Peter Steinberger. All rights reserved.
//

#import "EaseCollectionViewCommon.h"

@class EaseCollectionViewLayout, EaseCollectionViewController;

// Simple controller-wrapper around EaseCollectionView.
@interface EaseCollectionViewController : UIViewController <EaseCollectionViewDelegate, EaseCollectionViewDataSource>

// Designated initializer.
- (id)initWithCollectionViewLayout:(EaseCollectionViewLayout *)layout;

// Internally used collection view. If not set, created during loadView.
@property (nonatomic, strong) EaseCollectionView *collectionView;

// Defaults to YES, and if YES, any selection is cleared in viewWillAppear:
@property (nonatomic, assign) BOOL clearsSelectionOnViewWillAppear;

@end
