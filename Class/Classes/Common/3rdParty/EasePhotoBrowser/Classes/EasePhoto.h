//
//  EasePhoto.h
//  EasePhotoBrowser
//
//  Created by Michael Waterfall on 17/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "EasePhotoProtocol.h"

// This class models a photo/image and it's caption
// If you want to handle photos, caching, decompression
// yourself then you can simply ensure your custom data model
// conforms to EasePhotoProtocol
@interface EasePhoto : NSObject <EasePhoto>

@property (nonatomic, strong) NSString *caption;
@property (nonatomic) BOOL emptyImage;
@property (nonatomic) BOOL isVideo;

+ (EasePhoto *)photoWithImage:(UIImage *)image;
+ (EasePhoto *)photoWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize;

- (id)init;
- (id)initWithImage:(UIImage *)image;
- (id)initWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize;

@end

