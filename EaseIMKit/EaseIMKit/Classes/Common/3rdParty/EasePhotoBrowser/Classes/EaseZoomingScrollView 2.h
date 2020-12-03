//
//  ZoomingScrollView.h
//  EasePhotoBrowser
//
//  Created by Michael Waterfall on 14/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EasePhotoProtocol.h"
#import "EaseTapDetectingImageView.h"
#import "EaseTapDetectingView.h"

@class EasePhotoBrowser, EasePhoto, EaseCaptionView;

@interface EaseZoomingScrollView : UIScrollView <UIScrollViewDelegate, EaseTapDetectingImageViewDelegate, EaseTapDetectingViewDelegate> {

}

@property () NSUInteger index;
@property (nonatomic) id <EasePhoto> photo;
@property (nonatomic, weak) EaseCaptionView *captionView;
@property (nonatomic, weak) UIButton *selectedButton;
@property (nonatomic, weak) UIButton *playButton;

- (id)initWithPhotoBrowser:(EasePhotoBrowser *)browser;
- (void)displayImage;
- (void)displayImageFailure;
- (void)setMaxMinZoomScalesForCurrentBounds;
- (void)prepareForReuse;
- (BOOL)displayingVideo;
- (void)setImageHidden:(BOOL)hidden;

@end
