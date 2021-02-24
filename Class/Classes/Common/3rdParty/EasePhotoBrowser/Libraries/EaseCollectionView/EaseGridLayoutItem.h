//
//  EaseGridLayoutItem.h
//  PSPDFKit
//
//  Copyright (c) 2012-2013 Peter Steinberger. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EaseGridLayoutSection, EaseGridLayoutRow;

// Represents a single grid item; only created for non-uniform-sized grids.
@interface EaseGridLayoutItem : NSObject

@property (nonatomic, unsafe_unretained) EaseGridLayoutSection *section;
@property (nonatomic, unsafe_unretained) EaseGridLayoutRow *rowObject;
@property (nonatomic, assign) CGRect itemFrame;

@end
