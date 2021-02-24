/*
 * This file is part of the EaseWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "EaseWebImageDownloaderOperation.h"
#import "EaseWebImageError.h"
#import "EaseInternalMacros.h"
#import "EaseWebImageDownloaderResponseModifier.h"
#import "EaseWebImageDownloaderDecryptor.h"

static NSString *const kProgressCallbackKey = @"progress";
static NSString *const kCompletedCallbackKey = @"completed";

typedef NSMutableDictionary<NSString *, id> EaseCallbacksDictionary;

@interface EaseWebImageDownloaderOperation ()

@property (strong, nonatomic, nonnull) NSMutableArray<EaseCallbacksDictionary *> *callbackBlocks;

@property (assign, nonatomic, readwrite) EaseWebImageDownloaderOptions options;
@property (copy, nonatomic, readwrite, nullable) EaseWebImageContext *context;

@property (assign, nonatomic, getter = isExecuting) BOOL executing;
@property (assign, nonatomic, getter = isFinished) BOOL finished;
@property (strong, nonatomic, nullable) NSMutableData *imageData;
@property (copy, nonatomic, nullable) NSData *cachedData; // for `EaseWebImageDownloaderIgnoreCachedResponse`
@property (assign, nonatomic) NSUInteger expectedSize; // may be 0
@property (assign, nonatomic) NSUInteger receivedSize;
@property (strong, nonatomic, nullable, readwrite) NSURLResponse *response;
@property (strong, nonatomic, nullable) NSError *responseError;
@property (assign, nonatomic) double previousProgress; // previous progress percent

@property (strong, nonatomic, nullable) id<EaseWebImageDownloaderResponseModifier> responseModifier; // modify original URLResponse
@property (strong, nonatomic, nullable) id<EaseWebImageDownloaderDecryptor> decryptor; // decrypt image data

// This is weak because it is injected by whoever manages this session. If this gets nil-ed out, we won't be able to run
// the task associated with this operation
@property (weak, nonatomic, nullable) NSURLSession *unownedSession;
// This is set if we're using not using an injected NSURLSession. We're responsible of invalidating this one
@property (strong, nonatomic, nullable) NSURLSession *ownedSession;

@property (strong, nonatomic, readwrite, nullable) NSURLSessionTask *dataTask;

@property (strong, nonatomic, readwrite, nullable) NSURLSessionTaskMetrics *metrics API_AVAILABLE(macosx(10.12), ios(10.0), watchos(3.0), tvos(10.0));

@property (strong, nonatomic, nonnull) NSOperationQueue *coderQueue; // the serial operation queue to do image decoding
#if Ease_UIKIT
@property (assign, nonatomic) UIBackgroundTaskIdentifier backgroundTaskId;
#endif

@end

@implementation EaseWebImageDownloaderOperation

@synthesize executing = _executing;
@synthesize finished = _finished;

- (nonnull instancetype)init {
    return [self initWithRequest:nil inSession:nil options:0];
}

- (instancetype)initWithRequest:(NSURLRequest *)request inSession:(NSURLSession *)session options:(EaseWebImageDownloaderOptions)options {
    return [self initWithRequest:request inSession:session options:options context:nil];
}

- (nonnull instancetype)initWithRequest:(nullable NSURLRequest *)request
                              inSession:(nullable NSURLSession *)session
                                options:(EaseWebImageDownloaderOptions)options
                                context:(nullable EaseWebImageContext *)context {
    if ((self = [super init])) {
        _request = [request copy];
        _options = options;
        _context = [context copy];
        _callbackBlocks = [NSMutableArray new];
        _responseModifier = context[EaseWebImageContextDownloadResponseModifier];
        _decryptor = context[EaseWebImageContextDownloadDecryptor];
        _executing = NO;
        _finished = NO;
        _expectedSize = 0;
        _unownedSession = session;
        _coderQueue = [NSOperationQueue new];
        _coderQueue.maxConcurrentOperationCount = 1;
#if Ease_UIKIT
        _backgroundTaskId = UIBackgroundTaskInvalid;
#endif
    }
    return self;
}

- (nullable id)addHandlersForProgress:(nullable EaseWebImageDownloaderProgressBlock)progressBlock
                            completed:(nullable EaseWebImageDownloaderCompletedBlock)completedBlock {
    EaseCallbacksDictionary *callbacks = [NSMutableDictionary new];
    if (progressBlock) callbacks[kProgressCallbackKey] = [progressBlock copy];
    if (completedBlock) callbacks[kCompletedCallbackKey] = [completedBlock copy];
    @synchronized (self) {
        [self.callbackBlocks addObject:callbacks];
    }
    return callbacks;
}

- (nullable NSArray<id> *)callbacksForKey:(NSString *)key {
    NSMutableArray<id> *callbacks;
    @synchronized (self) {
        callbacks = [[self.callbackBlocks valueForKey:key] mutableCopy];
    }
    // We need to remove [NSNull null] because there might not always be a progress block for each callback
    [callbacks removeObjectIdenticalTo:[NSNull null]];
    return [callbacks copy]; // strip mutability here
}

- (BOOL)cancel:(nullable id)token {
    if (!token) return NO;
    
    BOOL shouldCancel = NO;
    @synchronized (self) {
        NSMutableArray *tempCallbackBlocks = [self.callbackBlocks mutableCopy];
        [tempCallbackBlocks removeObjectIdenticalTo:token];
        if (tempCallbackBlocks.count == 0) {
            shouldCancel = YES;
        }
    }
    if (shouldCancel) {
        // Cancel operation running and callback last token's completion block
        [self cancel];
    } else {
        // Only callback this token's completion block
        @synchronized (self) {
            [self.callbackBlocks removeObjectIdenticalTo:token];
        }
        EaseWebImageDownloaderCompletedBlock completedBlock = [token valueForKey:kCompletedCallbackKey];
        dispatch_main_async_safe(^{
            if (completedBlock) {
                completedBlock(nil, nil, [NSError errorWithDomain:EaseWebImageErrorDomain code:EaseWebImageErrorCancelled userInfo:@{NSLocalizedDescriptionKey : @"Operation cancelled by user during sending the request"}], YES);
            }
        });
    }
    return shouldCancel;
}

- (void)start {
    @synchronized (self) {
        if (self.isCancelled) {
            self.finished = YES;
            // Operation cancelled by user before sending the request
            [self callCompletionBlocksWithError:[NSError errorWithDomain:EaseWebImageErrorDomain code:EaseWebImageErrorCancelled userInfo:@{NSLocalizedDescriptionKey : @"Operation cancelled by user before sending the request"}]];
            [self reset];
            return;
        }

#if Ease_UIKIT
        Class UIApplicationClass = NSClassFromString(@"UIApplication");
        BOOL hasApplication = UIApplicationClass && [UIApplicationClass respondsToSelector:@selector(sharedApplication)];
        if (hasApplication && [self shouldContinueWhenAppEntersBackground]) {
            __weak typeof(self) wself = self;
            UIApplication * app = [UIApplicationClass performSelector:@selector(sharedApplication)];
            self.backgroundTaskId = [app beginBackgroundTaskWithExpirationHandler:^{
                [wself cancel];
            }];
        }
#endif
        NSURLSession *session = self.unownedSession;
        if (!session) {
            NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
            sessionConfig.timeoutIntervalForRequest = 15;
            
            /**
             *  Create the session for this task
             *  We send nil as delegate queue so that the session creates a serial operation queue for performing all delegate
             *  method calls and completion handler calls.
             */
            session = [NSURLSession sessionWithConfiguration:sessionConfig
                                                    delegate:self
                                               delegateQueue:nil];
            self.ownedSession = session;
        }
        
        if (self.options & EaseWebImageDownloaderIgnoreCachedResponse) {
            // Grab the cached data for later check
            NSURLCache *URLCache = session.configuration.URLCache;
            if (!URLCache) {
                URLCache = [NSURLCache sharedURLCache];
            }
            NSCachedURLResponse *cachedResponse;
            // NSURLCache's `cachedResponseForRequest:` is not thread-safe, see https://developer.apple.com/documentation/foundation/nsurlcache#2317483
            @synchronized (URLCache) {
                cachedResponse = [URLCache cachedResponseForRequest:self.request];
            }
            if (cachedResponse) {
                self.cachedData = cachedResponse.data;
            }
        }
        
        self.dataTask = [session dataTaskWithRequest:self.request];
        self.executing = YES;
    }

    if (self.dataTask) {
        if (self.options & EaseWebImageDownloaderHighPriority) {
            self.dataTask.priority = NSURLSessionTaskPriorityHigh;
            self.coderQueue.qualityOfService = NSQualityOfServiceUserInteractive;
        } else if (self.options & EaseWebImageDownloaderLowPriority) {
            self.dataTask.priority = NSURLSessionTaskPriorityLow;
            self.coderQueue.qualityOfService = NSQualityOfServiceBackground;
        } else {
            self.dataTask.priority = NSURLSessionTaskPriorityDefault;
            self.coderQueue.qualityOfService = NSQualityOfServiceDefault;
        }
        [self.dataTask resume];
        for (EaseWebImageDownloaderProgressBlock progressBlock in [self callbacksForKey:kProgressCallbackKey]) {
            progressBlock(0, NSURLResponseUnknownLength, self.request.URL);
        }
        __block typeof(self) strongSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:EaseWebImageDownloadStartNotification object:strongSelf];
        });
    } else {
        [self callCompletionBlocksWithError:[NSError errorWithDomain:EaseWebImageErrorDomain code:EaseWebImageErrorInvalidDownloadOperation userInfo:@{NSLocalizedDescriptionKey : @"Task can't be initialized"}]];
        [self done];
    }
}

- (void)cancel {
    @synchronized (self) {
        [self cancelInternal];
    }
}

- (void)cancelInternal {
    if (self.isFinished) return;
    [super cancel];

    if (self.dataTask) {
        [self.dataTask cancel];
        __block typeof(self) strongSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:EaseWebImageDownloadStopNotification object:strongSelf];
        });

        // As we cancelled the task, its callback won't be called and thus won't
        // maintain the isFinished and isExecuting flags.
        if (self.isExecuting) self.executing = NO;
        if (!self.isFinished) self.finished = YES;
    } else {
        // Operation cancelled by user during sending the request
        [self callCompletionBlocksWithError:[NSError errorWithDomain:EaseWebImageErrorDomain code:EaseWebImageErrorCancelled userInfo:@{NSLocalizedDescriptionKey : @"Operation cancelled by user during sending the request"}]];
    }

    [self reset];
}

- (void)done {
    self.finished = YES;
    self.executing = NO;
    [self reset];
}

- (void)reset {
    @synchronized (self) {
        [self.callbackBlocks removeAllObjects];
        self.dataTask = nil;
        
        if (self.ownedSession) {
            [self.ownedSession invalidateAndCancel];
            self.ownedSession = nil;
        }
        
#if Ease_UIKIT
        if (self.backgroundTaskId != UIBackgroundTaskInvalid) {
            // If backgroundTaskId != UIBackgroundTaskInvalid, sharedApplication is always exist
            UIApplication * app = [UIApplication performSelector:@selector(sharedApplication)];
            [app endBackgroundTask:self.backgroundTaskId];
            self.backgroundTaskId = UIBackgroundTaskInvalid;
        }
#endif
    }
}

- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (BOOL)isConcurrent {
    return YES;
}

#pragma mark NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    NSURLSessionResponseDisposition disposition = NSURLSessionResponseAllow;
    
    // Check response modifier, if return nil, will marked as cancelled.
    BOOL valid = YES;
    if (self.responseModifier && response) {
        response = [self.responseModifier modifiedResponseWithResponse:response];
        if (!response) {
            valid = NO;
            self.responseError = [NSError errorWithDomain:EaseWebImageErrorDomain code:EaseWebImageErrorInvalidDownloadResponse userInfo:@{NSLocalizedDescriptionKey : @"Download marked as failed because response is nil"}];
        }
    }
    
    NSInteger expected = (NSInteger)response.expectedContentLength;
    expected = expected > 0 ? expected : 0;
    self.expectedSize = expected;
    self.response = response;
    
    NSInteger statusCode = [response respondsToSelector:@selector(statusCode)] ? ((NSHTTPURLResponse *)response).statusCode : 200;
    // Status code should between [200,400)
    BOOL statusCodeValid = statusCode >= 200 && statusCode < 400;
    if (!statusCodeValid) {
        valid = NO;
        self.responseError = [NSError errorWithDomain:EaseWebImageErrorDomain code:EaseWebImageErrorInvalidDownloadStatusCode userInfo:@{NSLocalizedDescriptionKey : @"Download marked as failed because response status code is not in 200-400", EaseWebImageErrorDownloadStatusCodeKey : @(statusCode)}];
    }
    //'304 Not Modified' is an exceptional one
    //URLSession current behavior will return 200 status code when the server respond 304 and URLCache hit. But this is not a standard behavior and we just add a check
    if (statusCode == 304 && !self.cachedData) {
        valid = NO;
        self.responseError = [NSError errorWithDomain:EaseWebImageErrorDomain code:EaseWebImageErrorCacheNotModified userInfo:@{NSLocalizedDescriptionKey : @"Download response status code is 304 not modified and ignored"}];
    }
    
    if (valid) {
        for (EaseWebImageDownloaderProgressBlock progressBlock in [self callbacksForKey:kProgressCallbackKey]) {
            progressBlock(0, expected, self.request.URL);
        }
    } else {
        // Status code invalid and marked as cancelled. Do not call `[self.dataTask cancel]` which may Eases up URLSession life cycle
        disposition = NSURLSessionResponseCancel;
    }
    __block typeof(self) strongSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:EaseWebImageDownloadReceiveResponseNotification object:strongSelf];
    });
    
    if (completionHandler) {
        completionHandler(disposition);
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    if (!self.imageData) {
        self.imageData = [[NSMutableData alloc] initWithCapacity:self.expectedSize];
    }
    [self.imageData appendData:data];
    
    self.receivedSize = self.imageData.length;
    if (self.expectedSize == 0) {
        // Unknown expectedSize, immediately call progressBlock and return
        for (EaseWebImageDownloaderProgressBlock progressBlock in [self callbacksForKey:kProgressCallbackKey]) {
            progressBlock(self.receivedSize, self.expectedSize, self.request.URL);
        }
        return;
    }
    
    // Get the finish status
    BOOL finished = (self.receivedSize >= self.expectedSize);
    // Get the current progress
    double currentProgress = (double)self.receivedSize / (double)self.expectedSize;
    double previousProgress = self.previousProgress;
    double progressInterval = currentProgress - previousProgress;
    // Check if we need callback progress
    if (!finished && (progressInterval < self.minimumProgressInterval)) {
        return;
    }
    self.previousProgress = currentProgress;
    
    // Using data decryptor will disable the progressive decoding, since there are no support for progressive decrypt
    BOOL supportProgressive = (self.options & EaseWebImageDownloaderProgressiveLoad) && !self.decryptor;
    if (supportProgressive) {
        // Get the image data
        NSData *imageData = [self.imageData copy];
        
        // keep maximum one progressive decode process during download
        if (self.coderQueue.operationCount == 0) {
            // NSOperation have autoreleasepool, don't need to create extra one
            [self.coderQueue addOperationWithBlock:^{
                UIImage *image = EaseImageLoaderDecodeProgressiveImageData(imageData, self.request.URL, finished, self, [[self class] imageOptionsFromDownloaderOptions:self.options], self.context);
                if (image) {
                    // We do not keep the progressive decoding image even when `finished`=YES. Because they are for view rendering but not take full function from downloader options. And some coders implementation may not keep consistent between progressive decoding and normal decoding.
                    
                    [self callCompletionBlocksWithImage:image imageData:nil error:nil finished:NO];
                }
            }];
        }
    }
    
    for (EaseWebImageDownloaderProgressBlock progressBlock in [self callbacksForKey:kProgressCallbackKey]) {
        progressBlock(self.receivedSize, self.expectedSize, self.request.URL);
    }
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler {
    
    NSCachedURLResponse *cachedResponse = proposedResponse;

    if (!(self.options & EaseWebImageDownloaderUseNSURLCache)) {
        // Prevents caching of responses
        cachedResponse = nil;
    }
    if (completionHandler) {
        completionHandler(cachedResponse);
    }
}

#pragma mark NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    // If we already cancel the operation or anything mark the operation finished, don't callback twice
    if (self.isFinished) return;
    
    @synchronized(self) {
        self.dataTask = nil;
        __block typeof(self) strongSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:EaseWebImageDownloadStopNotification object:strongSelf];
            if (!error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:EaseWebImageDownloadFinishNotification object:strongSelf];
            }
        });
    }
    
    // make sure to call `[self done]` to mark operation as finished
    if (error) {
        // custom error instead of URLSession error
        if (self.responseError) {
            error = self.responseError;
        }
        [self callCompletionBlocksWithError:error];
        [self done];
    } else {
        if ([self callbacksForKey:kCompletedCallbackKey].count > 0) {
            NSData *imageData = [self.imageData copy];
            self.imageData = nil;
            // data decryptor
            if (imageData && self.decryptor) {
                imageData = [self.decryptor decryptedDataWithData:imageData response:self.response];
            }
            if (imageData) {
                /**  if you specified to only use cached data via `EaseWebImageDownloaderIgnoreCachedResponse`,
                 *  then we should check if the cached data is equal to image data
                 */
                if (self.options & EaseWebImageDownloaderIgnoreCachedResponse && [self.cachedData isEqualToData:imageData]) {
                    self.responseError = [NSError errorWithDomain:EaseWebImageErrorDomain code:EaseWebImageErrorCacheNotModified userInfo:@{NSLocalizedDescriptionKey : @"Downloaded image is not modified and ignored"}];
                    // call completion block with not modified error
                    [self callCompletionBlocksWithError:self.responseError];
                    [self done];
                } else {
                    // decode the image in coder queue, cancel all previous decoding process
                    [self.coderQueue cancelAllOperations];
                    [self.coderQueue addOperationWithBlock:^{
                        UIImage *image = EaseImageLoaderDecodeImageData(imageData, self.request.URL, [[self class] imageOptionsFromDownloaderOptions:self.options], self.context);
                        CGSize imageSize = image.size;
                        if (imageSize.width == 0 || imageSize.height == 0) {
                            NSString *description = image == nil ? @"Downloaded image decode failed" : @"Downloaded image has 0 pixels";
                            [self callCompletionBlocksWithError:[NSError errorWithDomain:EaseWebImageErrorDomain code:EaseWebImageErrorBadImageData userInfo:@{NSLocalizedDescriptionKey : description}]];
                        } else {
                            [self callCompletionBlocksWithImage:image imageData:imageData error:nil finished:YES];
                        }
                        [self done];
                    }];
                }
            } else {
                [self callCompletionBlocksWithError:[NSError errorWithDomain:EaseWebImageErrorDomain code:EaseWebImageErrorBadImageData userInfo:@{NSLocalizedDescriptionKey : @"Image data is nil"}]];
                [self done];
            }
        } else {
            [self done];
        }
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
    
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    __block NSURLCredential *credential = nil;
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if (!(self.options & EaseWebImageDownloaderAllowInvalidSSLCertificates)) {
            disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        } else {
            credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            disposition = NSURLSessionAuthChallengeUseCredential;
        }
    } else {
        if (challenge.previousFailureCount == 0) {
            if (self.credential) {
                credential = self.credential;
                disposition = NSURLSessionAuthChallengeUseCredential;
            } else {
                disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
            }
        } else {
            disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
        }
    }
    
    if (completionHandler) {
        completionHandler(disposition, credential);
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didFinishCollectingMetrics:(NSURLSessionTaskMetrics *)metrics API_AVAILABLE(macosx(10.12), ios(10.0), watchos(3.0), tvos(10.0)) {
    self.metrics = metrics;
}

#pragma mark Helper methods
+ (EaseWebImageOptions)imageOptionsFromDownloaderOptions:(EaseWebImageDownloaderOptions)downloadOptions {
    EaseWebImageOptions options = 0;
    if (downloadOptions & EaseWebImageDownloaderScaleDownLargeImages) options |= EaseWebImageScaleDownLargeImages;
    if (downloadOptions & EaseWebImageDownloaderDecodeFirstFrameOnly) options |= EaseWebImageDecodeFirstFrameOnly;
    if (downloadOptions & EaseWebImageDownloaderPreloadAllFrames) options |= EaseWebImagePreloadAllFrames;
    if (downloadOptions & EaseWebImageDownloaderAvoidDecodeImage) options |= EaseWebImageAvoidDecodeImage;
    if (downloadOptions & EaseWebImageDownloaderMatchAnimatedImageClass) options |= EaseWebImageMatchAnimatedImageClass;
    
    return options;
}

- (BOOL)shouldContinueWhenAppEntersBackground {
    return Ease_OPTIONS_CONTAINS(self.options, EaseWebImageDownloaderContinueInBackground);
}

- (void)callCompletionBlocksWithError:(nullable NSError *)error {
    [self callCompletionBlocksWithImage:nil imageData:nil error:error finished:YES];
}

- (void)callCompletionBlocksWithImage:(nullable UIImage *)image
                            imageData:(nullable NSData *)imageData
                                error:(nullable NSError *)error
                             finished:(BOOL)finished {
    NSArray<id> *completionBlocks = [self callbacksForKey:kCompletedCallbackKey];
    dispatch_main_async_safe(^{
        for (EaseWebImageDownloaderCompletedBlock completedBlock in completionBlocks) {
            completedBlock(image, imageData, error, finished);
        }
    });
}

@end
