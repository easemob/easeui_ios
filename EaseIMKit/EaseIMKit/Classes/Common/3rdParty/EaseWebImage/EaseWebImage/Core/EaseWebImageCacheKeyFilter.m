/*
 * This file is part of the EaseWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "EaseWebImageCacheKeyFilter.h"

@interface EaseWebImageCacheKeyFilter ()

@property (nonatomic, copy, nonnull) EaseWebImageCacheKeyFilterBlock block;

@end

@implementation EaseWebImageCacheKeyFilter

- (instancetype)initWithBlock:(EaseWebImageCacheKeyFilterBlock)block {
    self = [super init];
    if (self) {
        self.block = block;
    }
    return self;
}

+ (instancetype)cacheKeyFilterWithBlock:(EaseWebImageCacheKeyFilterBlock)block {
    EaseWebImageCacheKeyFilter *cacheKeyFilter = [[EaseWebImageCacheKeyFilter alloc] initWithBlock:block];
    return cacheKeyFilter;
}

- (NSString *)cacheKeyForURL:(NSURL *)url {
    if (!self.block) {
        return nil;
    }
    return self.block(url);
}

@end
