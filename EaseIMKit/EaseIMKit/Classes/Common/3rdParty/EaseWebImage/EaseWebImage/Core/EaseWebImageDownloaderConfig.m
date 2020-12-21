/*
 * This file is part of the EaseWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "EaseWebImageDownloaderConfig.h"

static EaseWebImageDownloaderConfig * _defaultDownloaderConfig;

@implementation EaseWebImageDownloaderConfig

+ (EaseWebImageDownloaderConfig *)defaultDownloaderConfig {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultDownloaderConfig = [EaseWebImageDownloaderConfig new];
    });
    return _defaultDownloaderConfig;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _maxConcurrentDownloads = 6;
        _downloadTimeout = 15.0;
        _executionOrder = EaseWebImageDownloaderFIFOExecutionOrder;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    EaseWebImageDownloaderConfig *config = [[[self class] allocWithZone:zone] init];
    config.maxConcurrentDownloads = self.maxConcurrentDownloads;
    config.downloadTimeout = self.downloadTimeout;
    config.minimumProgressInterval = self.minimumProgressInterval;
    config.sessionConfiguration = [self.sessionConfiguration copyWithZone:zone];
    config.operationClass = self.operationClass;
    config.executionOrder = self.executionOrder;
    config.urlCredential = self.urlCredential;
    config.username = self.username;
    config.password = self.password;
    
    return config;
}


@end
