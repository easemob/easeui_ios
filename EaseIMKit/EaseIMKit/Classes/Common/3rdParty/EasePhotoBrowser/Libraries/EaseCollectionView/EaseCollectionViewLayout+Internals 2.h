//
//  EaseCollectionViewLayout+Internals.h
//  FMEaseCollectionView
//
//  Created by Scott Talbot on 27/02/13.
//  Copyright (c) 2013 Scott Talbot. All rights reserved.
//

#import "EaseCollectionViewLayout.h"


@interface EaseCollectionViewLayout (Internals)

@property (nonatomic, copy, readonly) NSDictionary *decorationViewClassDict;
@property (nonatomic, copy, readonly) NSDictionary *decorationViewNibDict;
@property (nonatomic, copy, readonly) NSDictionary *decorationViewExternalObjectsTables;

@end
