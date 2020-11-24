//
//  EaseContactDelegate.h
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/11/5.
//

#import <Foundation/Foundation.h>
#import "EaseUserDelegate.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    EaseContactItemType_Contact,
    EaseContactItemType_Custom,
} EaseContactItemType;


@protocol EaseContactDelegate <EaseUserDelegate>

@property (nonatomic, copy, readonly) NSString *firstLetter; // 首字母
@property (nonatomic, assign) EaseContactItemType type;

@end

NS_ASSUME_NONNULL_END
