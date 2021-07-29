//
//  EaseCollectionViewController.m
//  PSPDFKit
//
//  Copyright (c) 2012-2013 Peter Steinberger. All rights reserved.
//

#import "EaseCollectionViewController.h"
#import "EaseCollectionView.h"

@interface EaseCollectionViewController () {
    EaseCollectionViewLayout *_layout;
    EaseCollectionView *_collectionView;
    struct {
        unsigned int clearsSelectionOnViewWillAppear : 1;
        unsigned int appearsFirstTime : 1; // PST extension!
    }_collectionViewControllerFlags;
    char filler[320]; // [HACK] Our class needs to be larger than Apple's class for the superclass change to work.
}
@property (nonatomic, strong) EaseCollectionViewLayout *layout;
@end

@implementation EaseCollectionViewController

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.layout = [EaseCollectionViewFlowLayout new];
        self.clearsSelectionOnViewWillAppear = YES;
        _collectionViewControllerFlags.appearsFirstTime = YES;
    }
    return self;
}

- (id)initWithCollectionViewLayout:(EaseCollectionViewLayout *)layout {
    if ((self = [super init])) {
        self.layout = layout;
        self.clearsSelectionOnViewWillAppear = YES;
        _collectionViewControllerFlags.appearsFirstTime = YES;
    }
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewController

- (void)loadView {
    [super loadView];

    // if this is restored from IB, we don't have plain main view.
    if ([self.view isKindOfClass:EaseCollectionView.class]) {
        _collectionView = (EaseCollectionView *)self.view;
        self.view = [[UIView alloc] initWithFrame:self.view.bounds];
        self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }

    if (_collectionView.delegate == nil) _collectionView.delegate = self;
    if (_collectionView.dataSource == nil) _collectionView.dataSource = self;

    // only create the collection view if it is not already created (by IB)
    if (!_collectionView) {
        self.collectionView = [[EaseCollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:self.layout];
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // This seems like a hack, but is needed for real compatibility
    // There can be implementations of loadView that don't call super and don't set the view, yet it works in UICollectionViewController.
    if (!self.isViewLoaded) {
        self.view = [[UIView alloc] initWithFrame:CGRectZero];
    }

    // Attach the view
    if (self.view != self.collectionView) {
        [self.view addSubview:self.collectionView];
        self.collectionView.frame = self.view.bounds;
        self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (_collectionViewControllerFlags.appearsFirstTime) {
        [_collectionView reloadData];
        _collectionViewControllerFlags.appearsFirstTime = NO;
    }

    if (_collectionViewControllerFlags.clearsSelectionOnViewWillAppear) {
        for (NSIndexPath *aIndexPath in [[_collectionView indexPathsForSelectedItems] copy]) {
            [_collectionView deselectItemAtIndexPath:aIndexPath animated:animated];
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Lazy load the collection view

- (EaseCollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[EaseCollectionView alloc] initWithFrame:UIScreen.mainScreen.bounds collectionViewLayout:self.layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;

        // If the collection view isn't the main view, add it.
        if (self.isViewLoaded && self.view != self.collectionView) {
            [self.view addSubview:self.collectionView];
            self.collectionView.frame = self.view.bounds;
            self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        }
    }
    return _collectionView;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Properties

- (void)setClearsSelectionOnViewWillAppear:(BOOL)clearsSelectionOnViewWillAppear {
    _collectionViewControllerFlags.clearsSelectionOnViewWillAppear = clearsSelectionOnViewWillAppear;
}

- (BOOL)clearsSelectionOnViewWillAppear {
    return _collectionViewControllerFlags.clearsSelectionOnViewWillAppear;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - EaseCollectionViewDataSource

- (NSInteger)collectionView:(EaseCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 0;
}

- (EaseCollectionViewCell *)collectionView:(EaseCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
