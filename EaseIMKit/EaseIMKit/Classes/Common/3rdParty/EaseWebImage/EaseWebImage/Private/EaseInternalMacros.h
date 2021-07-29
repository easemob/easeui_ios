/*
 * This file is part of the EaseWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <Foundation/Foundation.h>
#import <os/lock.h>
#import <libkern/OSAtomic.h>
#import "Easemetamacros.h"

#ifndef Ease_LOCK_DECLARE
#if TARGET_OS_MACCATALYST
#define Ease_LOCK_DECLARE(lock) os_unfair_lock lock;
#else
#define Ease_LOCK_DECLARE(lock) os_unfair_lock lock API_AVAILABLE(ios(10.0), tvos(10), watchos(3), macos(10.12)); \
OSSpinLock lock##_deprecated;
#endif
#endif

#ifndef Ease_LOCK_INIT
#if TARGET_OS_MACCATALYST
#define Ease_LOCK_INIT(lock) lock = OS_UNFAIR_LOCK_INIT;
#else
#define Ease_LOCK_INIT(lock) if (@available(iOS 10, tvOS 10, watchOS 3, macOS 10.12, *)) lock = OS_UNFAIR_LOCK_INIT; \
else lock##_deprecated = OS_SPINLOCK_INIT;
#endif
#endif

#ifndef Ease_LOCK
#if TARGET_OS_MACCATALYST
#define Ease_LOCK(lock) os_unfair_lock_lock(&lock);
#else
#define Ease_LOCK(lock) if (@available(iOS 10, tvOS 10, watchOS 3, macOS 10.12, *)) os_unfair_lock_lock(&lock); \
else OSSpinLockLock(&lock##_deprecated);
#endif
#endif

#ifndef Ease_UNLOCK
#if TARGET_OS_MACCATALYST
#define Ease_UNLOCK(lock) os_unfair_lock_unlock(&lock);
#else
#define Ease_UNLOCK(lock) if (@available(iOS 10, tvOS 10, watchOS 3, macOS 10.12, *)) os_unfair_lock_unlock(&lock); \
else OSSpinLockUnlock(&lock##_deprecated);
#endif
#endif

#ifndef Ease_OPTIONS_CONTAINS
#define Ease_OPTIONS_CONTAINS(options, value) (((options) & (value)) == (value))
#endif

#ifndef Ease_CSTRING
#define Ease_CSTRING(str) #str
#endif

#ifndef Ease_NSSTRING
#define Ease_NSSTRING(str) @(Ease_CSTRING(str))
#endif

#ifndef Ease_SEL_SPI
#define Ease_SEL_SPI(name) NSSelectorFromString([NSString stringWithFormat:@"_%@", Ease_NSSTRING(name)])
#endif

#ifndef weakify
#define weakify(...) \
Ease_keywordify \
metamacro_foreach_cxt(Ease_weakify_,, __weak, __VA_ARGS__)
#endif

#ifndef strongify
#define strongify(...) \
Ease_keywordify \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
metamacro_foreach(Ease_strongify_,, __VA_ARGS__) \
_Pragma("clang diagnostic pop")
#endif

#define Ease_weakify_(INDEX, CONTEXT, VAR) \
CONTEXT __typeof__(VAR) metamacro_concat(VAR, _weak_) = (VAR);

#define Ease_strongify_(INDEX, VAR) \
__strong __typeof__(VAR) VAR = metamacro_concat(VAR, _weak_);

#if DEBUG
#define Ease_keywordify autoreleasepool {}
#else
#define Ease_keywordify try {} @catch (...) {}
#endif

#ifndef onExit
#define onExit \
Ease_keywordify \
__strong Ease_cleanupBlock_t metamacro_concat(Ease_exitBlock_, __LINE__) __attribute__((cleanup(Ease_executeCleanupBlock), unused)) = ^
#endif

typedef void (^Ease_cleanupBlock_t)(void);

#if defined(__cplusplus)
extern "C" {
#endif
    void Ease_executeCleanupBlock (__strong Ease_cleanupBlock_t *block);
#if defined(__cplusplus)
}
#endif
