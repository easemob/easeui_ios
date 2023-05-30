//
//  EaseURLPreviewManager.m
//  EaseIMKit
//
//  Created by 冯钊 on 2023/5/23.
//

#import "EaseURLPreviewManager.h"
#import "XPathQuery.h"
#import "TFHpple.h"
#import "TFHppleElement.h"

@implementation EaseURLPreviewResult
@end

@interface EaseURLPreviewCallback : NSObject

@property (nonatomic, strong) EaseURLPreviewResult *result;
@property (nonatomic, strong) NSMutableArray <EaseURLPreviewSuccessBlock>*successBlocks;
@property (nonatomic, strong) NSMutableArray <EaseURLPreviewFailedBlock>*failedBlocks;

@end

@implementation EaseURLPreviewCallback
@end

@interface EaseURLPreviewManager ()

@property (nonatomic, strong) NSMutableDictionary <NSURL *, EaseURLPreviewCallback *>*callbackDict;

@end

@implementation EaseURLPreviewManager

+ (instancetype)shared
{
    static EaseURLPreviewManager *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[EaseURLPreviewManager alloc] init];
        shared.callbackDict = [NSMutableDictionary dictionary];
    }); 
    return shared;
}

- (EaseURLPreviewResult *)resultWithURL:(NSURL *)url
{
    return _callbackDict[url].result;
}

- (void)preview:(NSURL *)url successHandle:(void (^)(EaseURLPreviewResult * _Nonnull))successHandle faieldHandle:(void (^)(void))faieldHandle
{
    if (!successHandle) {
        return;
    }
    EaseURLPreviewResult *result = _callbackDict[url].result;
    if (result) {
        if (result.state == EaseURLPreviewStateSuccess) {
            successHandle(result);
            return;
        } else if (result.state == EaseURLPreviewStateFaild) {
            faieldHandle();
            return;
        }
    }
    
    EaseURLPreviewCallback *callback = _callbackDict[url];
    if (!callback) {
        callback = [[EaseURLPreviewCallback alloc] init];
        result = [[EaseURLPreviewResult alloc] init];
        result.state = EaseURLPreviewStateLoading;
        callback.result = result;
        _callbackDict[url] = callback;
    }
    
    if (!callback.successBlocks) {
        callback.successBlocks = [NSMutableArray array];
    }
    [callback.successBlocks addObject:successHandle];
    
    if (faieldHandle) {
        if (!callback.failedBlocks) {
            callback.failedBlocks = [NSMutableArray array];
        }
        [callback.failedBlocks addObject:faieldHandle];
    }
    
    NSURLSessionDataTask *task = [NSURLSession.sharedSession dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error || data.length <= 0) {
            result.state = EaseURLPreviewStateFaild;
            dispatch_async(dispatch_get_main_queue(), ^{
                for (EaseURLPreviewFailedBlock block in callback.failedBlocks) {
                    block();
                }
                callback.successBlocks = nil;
                callback.failedBlocks = nil;
            });
            return;
        }
        
        if ([response isKindOfClass:NSHTTPURLResponse.class]) {
            if (![((NSHTTPURLResponse *)response).allHeaderFields[@"content-type"] hasPrefix:@"text"]) {
                result.state = EaseURLPreviewStateFaild;
                dispatch_async(dispatch_get_main_queue(), ^{
                    for (EaseURLPreviewFailedBlock block in callback.failedBlocks) {
                        block();
                    }
                    callback.successBlocks = nil;
                    callback.failedBlocks = nil;
                });
                return;
            }
        }
        
        TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
        TFHppleElement *titleElement = [xpathParser searchWithXPathQuery:@"//title"].firstObject;
        result.title = [titleElement content];
        
        NSArray <TFHppleElement *> *metaElements = [xpathParser searchWithXPathQuery:@"//meta"];
        for (TFHppleElement *element in metaElements) {
            if ([[element objectForKey:@"property"] containsString:@"description"] || [[element objectForKey:@"name"] isEqualToString:@"description"]) {
                result.desc = [element objectForKey:@"content"];
            }
            if ([[element objectForKey:@"property"] containsString:@"image"] && [[element objectForKey:@"content"] containsString:@"http"]) {
                result.imageUrl = [element objectForKey:@"content"];
            }
        }
        if (!result.imageUrl) {
            TFHppleElement *imgElement = [xpathParser peekAtSearchWithXPathQuery:@"//img"];
            if (imgElement) {
                NSString *resultUrl = [imgElement objectForKey:@"src"];
                if ([resultUrl hasPrefix:@"//"]) {
                    if ([url.absoluteString.lowercaseString hasPrefix:@"https"]) {
                        result.imageUrl = [@"https:" stringByAppendingString:resultUrl];
                    } else if ([url.absoluteString.lowercaseString hasPrefix:@"http"]) {
                        result.imageUrl = [@"http:" stringByAppendingString:resultUrl];
                    }
                } else if ([resultUrl hasPrefix:@"/"]) {
                    NSString *protocol;
                    if ([url.absoluteString.lowercaseString hasPrefix:@"https"]) {
                        protocol = @"https";
                    } else if ([url.absoluteString.lowercaseString hasPrefix:@"http"]) {
                        protocol = @"http";
                    }
                    result.imageUrl = [NSString stringWithFormat:@"%@://%@%@", protocol, url.host, resultUrl];
                } else {
                    result.imageUrl = resultUrl;
                }
            }
        }
        result.state = EaseURLPreviewStateSuccess;
        dispatch_async(dispatch_get_main_queue(), ^{
            for (EaseURLPreviewSuccessBlock block in callback.successBlocks) {
                block(result);
            }
            callback.successBlocks = nil;
            callback.failedBlocks = nil;
        });
    }];
    [task resume];
}

@end
