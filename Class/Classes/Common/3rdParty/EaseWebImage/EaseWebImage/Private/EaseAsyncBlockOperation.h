/*
 * This file is part of the EaseWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "EaseWebImageCompat.h"

@class EaseAsyncBlockOperation;
typedef void (^EaseAsyncBlock)(EaseAsyncBlockOperation * __nonnull asyncOperation);

/// A async block operation, success after you call `completer` (not like `NSBlockOperation` which is for sync block, success on return)
@interface EaseAsyncBlockOperation : NSOperation

- (nonnull instancetype)initWithBlock:(nonnull EaseAsyncBlock)block;
+ (nonnull instancetype)blockOperationWithBlock:(nonnull EaseAsyncBlock)block;
- (void)complete;

@end
