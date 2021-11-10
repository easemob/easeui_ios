/*
 * This file is part of the EaseWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "EaseInternalMacros.h"

void Ease_executeCleanupBlock (__strong Ease_cleanupBlock_t *block) {
    (*block)();
}
