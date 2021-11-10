/*
* This file is part of the EaseWebImage package.
* (c) Olivier Poitrey <rs@dailymotion.com>
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/

#import "EaseWebImageDownloaderDecryptor.h"

@interface EaseWebImageDownloaderDecryptor ()

@property (nonatomic, copy, nonnull) EaseWebImageDownloaderDecryptorBlock block;

@end

@implementation EaseWebImageDownloaderDecryptor

- (instancetype)initWithBlock:(EaseWebImageDownloaderDecryptorBlock)block {
    self = [super init];
    if (self) {
        self.block = block;
    }
    return self;
}

+ (instancetype)decryptorWithBlock:(EaseWebImageDownloaderDecryptorBlock)block {
    EaseWebImageDownloaderDecryptor *decryptor = [[EaseWebImageDownloaderDecryptor alloc] initWithBlock:block];
    return decryptor;
}

- (nullable NSData *)decryptedDataWithData:(nonnull NSData *)data response:(nullable NSURLResponse *)response {
    if (!self.block) {
        return nil;
    }
    return self.block(data, response);
}

@end

@implementation EaseWebImageDownloaderDecryptor (Conveniences)

+ (EaseWebImageDownloaderDecryptor *)base64Decryptor {
    static EaseWebImageDownloaderDecryptor *decryptor;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        decryptor = [EaseWebImageDownloaderDecryptor decryptorWithBlock:^NSData * _Nullable(NSData * _Nonnull data, NSURLResponse * _Nullable response) {
            NSData *modifiedData = [[NSData alloc] initWithBase64EncodedData:data options:NSDataBase64DecodingIgnoreUnknownCharacters];
            return modifiedData;
        }];
    });
    return decryptor;
}

@end
