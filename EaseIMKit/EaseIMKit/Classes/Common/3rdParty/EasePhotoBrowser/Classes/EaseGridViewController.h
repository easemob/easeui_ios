//
//  EaseGridViewController.h
//  EasePhotoBrowser
//
//  Created by Michael Waterfall on 08/10/2013.
//
//

#import <UIKit/UIKit.h>
#import "EasePhotoBrowser.h"

@interface EaseGridViewController : UICollectionViewController {}

@property (nonatomic, assign) EasePhotoBrowser *browser;
@property (nonatomic) BOOL selectionMode;
@property (nonatomic) CGPoint initialContentOffset;

- (void)adjustOffsetsAsRequired;

@end
