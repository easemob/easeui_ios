/*
 * This file is part of the EaseWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "EaseWebImageOptionsProcessor.h"

@interface EaseWebImageOptionsResult ()

@property (nonatomic, assign) EaseWebImageOptions options;
@property (nonatomic, copy, nullable) EaseWebImageContext *context;

@end

@implementation EaseWebImageOptionsResult

- (instancetype)initWithOptions:(EaseWebImageOptions)options context:(EaseWebImageContext *)context {
    self = [super init];
    if (self) {
        self.options = options;
        self.context = context;
    }
    return self;
}

@end

@interface EaseWebImageOptionsProcessor ()

@property (nonatomic, copy, nonnull) EaseWebImageOptionsProcessorBlock block;

@end

@implementation EaseWebImageOptionsProcessor

- (instancetype)initWithBlock:(EaseWebImageOptionsProcessorBlock)block {
    self = [super init];
    if (self) {
        self.block = block;
    }
    return self;
}

+ (instancetype)optionsProcessorWithBlock:(EaseWebImageOptionsProcessorBlock)block {
    EaseWebImageOptionsProcessor *optionsProcessor = [[EaseWebImageOptionsProcessor alloc] initWithBlock:block];
    return optionsProcessor;
}

- (EaseWebImageOptionsResult *)processedResultForURL:(NSURL *)url options:(EaseWebImageOptions)options context:(EaseWebImageContext *)context {
    if (!self.block) {
        return nil;
    }
    return self.block(url, options, context);
}

@end
