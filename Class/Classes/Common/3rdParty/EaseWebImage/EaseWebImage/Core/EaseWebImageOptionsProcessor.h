/*
 * This file is part of the EaseWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <Foundation/Foundation.h>
#import "EaseWebImageCompat.h"
#import "EaseWebImageDefine.h"

@class EaseWebImageOptionsResult;

typedef EaseWebImageOptionsResult * _Nullable(^EaseWebImageOptionsProcessorBlock)(NSURL * _Nullable url, EaseWebImageOptions options, EaseWebImageContext * _Nullable context);

/**
 The options result contains both options and context.
 */
@interface EaseWebImageOptionsResult : NSObject

/**
 WebCache options.
 */
@property (nonatomic, assign, readonly) EaseWebImageOptions options;

/**
 Context options.
 */
@property (nonatomic, copy, readonly, nullable) EaseWebImageContext *context;

/**
 Create a new options result.

 @param options options
 @param context context
 @return The options result contains both options and context.
 */
- (nonnull instancetype)initWithOptions:(EaseWebImageOptions)options context:(nullable EaseWebImageContext *)context;

@end

/**
 This is the protocol for options processor.
 Options processor can be used, to control the final result for individual image request's `EaseWebImageOptions` and `EaseWebImageContext`
 Implements the protocol to have a global control for each indivadual image request's option.
 */
@protocol EaseWebImageOptionsProcessor <NSObject>

/**
 Return the processed options result for specify image URL, with its options and context

 @param url The URL to the image
 @param options A Easek to specify options to use for this request
 @param context A context contains different options to perform specify changes or processes, see `EaseWebImageContextOption`. This hold the extra objects which `options` enum can not hold.
 @return The processed result, contains both options and context
 */
- (nullable EaseWebImageOptionsResult *)processedResultForURL:(nullable NSURL *)url
                                                    options:(EaseWebImageOptions)options
                                                    context:(nullable EaseWebImageContext *)context;

@end

/**
 A options processor class with block.
 */
@interface EaseWebImageOptionsProcessor : NSObject<EaseWebImageOptionsProcessor>

- (nonnull instancetype)initWithBlock:(nonnull EaseWebImageOptionsProcessorBlock)block;
+ (nonnull instancetype)optionsProcessorWithBlock:(nonnull EaseWebImageOptionsProcessorBlock)block;

@end
