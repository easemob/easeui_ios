/*
 * This file is part of the EaseWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "EaseWebImageDownloaderRequestModifier.h"

@interface EaseWebImageDownloaderRequestModifier ()

@property (nonatomic, copy, nonnull) EaseWebImageDownloaderRequestModifierBlock block;

@end

@implementation EaseWebImageDownloaderRequestModifier

- (instancetype)initWithBlock:(EaseWebImageDownloaderRequestModifierBlock)block {
    self = [super init];
    if (self) {
        self.block = block;
    }
    return self;
}

+ (instancetype)requestModifierWithBlock:(EaseWebImageDownloaderRequestModifierBlock)block {
    EaseWebImageDownloaderRequestModifier *requestModifier = [[EaseWebImageDownloaderRequestModifier alloc] initWithBlock:block];
    return requestModifier;
}

- (NSURLRequest *)modifiedRequestWithRequest:(NSURLRequest *)request {
    if (!self.block) {
        return nil;
    }
    return self.block(request);
}

@end

@implementation EaseWebImageDownloaderRequestModifier (Conveniences)

- (instancetype)initWithMethod:(NSString *)method {
    return [self initWithMethod:method headers:nil body:nil];
}

- (instancetype)initWithHeaders:(NSDictionary<NSString *,NSString *> *)headers {
    return [self initWithMethod:nil headers:headers body:nil];
}

- (instancetype)initWithBody:(NSData *)body {
    return [self initWithMethod:nil headers:nil body:body];
}

- (instancetype)initWithMethod:(NSString *)method headers:(NSDictionary<NSString *,NSString *> *)headers body:(NSData *)body {
    method = method ? [method copy] : @"GET";
    headers = [headers copy];
    body = [body copy];
    return [self initWithBlock:^NSURLRequest * _Nullable(NSURLRequest * _Nonnull request) {
        NSMutableURLRequest *mutableRequest = [request mutableCopy];
        mutableRequest.HTTPMethod = method;
        mutableRequest.HTTPBody = body;
        for (NSString *header in headers) {
            NSString *value = headers[header];
            [mutableRequest setValue:value forHTTPHeaderField:header];
        }
        return [mutableRequest copy];
    }];
}

@end
