//
//  EaseContactDelegate.h
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/11/5.
//

#import <Foundation/Foundation.h>
#import "EaseItemDelegate.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    Contact,
    Custom,
} EaseContactItemType;


@protocol EaseContactDelegate <EaseItemDelegate>

@property (nonatomic, copy, readonly) NSString *firstLetter; // 首字母
@property (nonatomic, assign) EaseContactItemType type;

@end

NS_ASSUME_NONNULL_END
