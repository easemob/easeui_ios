/*
* This file is part of the EaseWebImage package.
* (c) Olivier Poitrey <rs@dailymotion.com>
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/

#import <Foundation/Foundation.h>
#import "EaseWebImageCompat.h"

typedef NSData * _Nullable (^EaseWebImageDownloaderDecryptorBlock)(NSData * _Nonnull data, NSURLResponse * _Nullable response);

/**
This is the protocol for downloader decryptor. Which decrypt the original encrypted data before decoding. Note progressive decoding is not compatible for decryptor.
We can use a block to specify the downloader decryptor. But Using protocol can make this extensible, and allow Swift user to use it easily instead of using `@convention(block)` to store a block into context options.
*/
@protocol EaseWebImageDownloaderDecryptor <NSObject>

/// Decrypt the original download data and return a new data. You can use this to decrypt the data using your preferred algorithm.
/// @param data The original download data
/// @param response The URL response for data. If you modify the original URL response via response modifier, the modified version will be here. This arg is nullable.
/// @note If nil is returned, the image download will be marked as failed with error `EaseWebImageErrorBadImageData`
- (nullable NSData *)decryptedDataWithData:(nonnull NSData *)data response:(nullable NSURLResponse *)response;

@end

/**
A downloader response modifier class with block.
*/
@interface EaseWebImageDownloaderDecryptor : NSObject <EaseWebImageDownloaderDecryptor>

/// Create the data decryptor with block
/// @param block A block to control decrypt logic
- (nonnull instancetype)initWithBlock:(nonnull EaseWebImageDownloaderDecryptorBlock)block;

/// Create the data decryptor with block
/// @param block A block to control decrypt logic
+ (nonnull instancetype)decryptorWithBlock:(nonnull EaseWebImageDownloaderDecryptorBlock)block;

@end

/// Convenience way to create decryptor for common data encryption.
@interface EaseWebImageDownloaderDecryptor (Conveniences)

/// Base64 Encoded image data decryptor
@property (class, readonly, nonnull) EaseWebImageDownloaderDecryptor *base64Decryptor;

@end
