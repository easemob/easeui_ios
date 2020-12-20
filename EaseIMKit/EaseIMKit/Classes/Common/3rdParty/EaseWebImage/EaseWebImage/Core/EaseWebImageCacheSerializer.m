/*
 * This file is part of the EaseWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "EaseWebImageCacheSerializer.h"

@interface EaseWebImageCacheSerializer ()

@property (nonatomic, copy, nonnull) EaseWebImageCacheSerializerBlock block;

@end

@implementation EaseWebImageCacheSerializer

- (instancetype)initWithBlock:(EaseWebImageCacheSerializerBlock)block {
    self = [super init];
    if (self) {
        self.block = block;
    }
    return self;
}

+ (instancetype)cacheSerializerWithBlock:(EaseWebImageCacheSerializerBlock)block {
    EaseWebImageCacheSerializer *cacheSerializer = [[EaseWebImageCacheSerializer alloc] initWithBlock:block];
    return cacheSerializer;
}

- (NSData *)cacheDataWithImage:(UIImage *)image originalData:(NSData *)data imageURL:(nullable NSURL *)imageURL {
    if (!self.block) {
        return nil;
    }
    return self.block(image, data, imageURL);
}

@end
