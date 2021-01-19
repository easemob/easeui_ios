//
//  EaseGridCell.h
//  EasePhotoBrowser
//
//  Created by Michael Waterfall on 08/10/2013.
//
//

#import <UIKit/UIKit.h>
#import "EasePhoto.h"
#import "EaseGridViewController.h"

@interface EaseGridCell : UICollectionViewCell {}

@property (nonatomic, weak) EaseGridViewController *gridController;
@property (nonatomic) NSUInteger index;
@property (nonatomic) id <EasePhoto> photo;
@property (nonatomic) BOOL selectionMode;
@property (nonatomic) BOOL isSelected;

- (void)displayImage;

@end
