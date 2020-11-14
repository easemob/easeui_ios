//
//  EMNotificationHelper.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/10.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <Hyphenate/Hyphenate.h>
#import "EaseIMKitCallBackReason.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, EMNotificationModelStatus) {
    EMNotificationModelStatusDefault = 0,
    EMNotificationModelStatusAgreed,
    EMNotificationModelStatusDeclined,
    EMNotificationModelStatusExpired,
};

@interface EMNotificationModel : NSObject <NSCoding>

@property (nonatomic, strong) NSString *sender;

@property (nonatomic, strong) NSString *receiver;

@property (nonatomic, strong) NSString *groupId;

@property (nonatomic, strong) NSString *message;

@property (nonatomic, strong) NSString *time;

@property (nonatomic) EMNotificationModelStatus status;

@property (nonatomic) EaseIMKitCallBackReason type;

@property (nonatomic) BOOL isRead;

@end

@protocol EMNotificationsDelegate;
@class EMMulticastDelegate;
@interface EMNotificationHelper : NSObject <EMMultiDevicesDelegate, EMContactManagerDelegate, EMGroupManagerDelegate>

@property (nonatomic, strong, readonly) NSString *fileName;

@property (nonatomic, strong) NSMutableArray *notificationList;

@property (nonatomic) BOOL isCheckUnreadCount;

@property (nonatomic) int unreadCount;

+ (instancetype)shared;

+ (void)destoryShared;

- (void)addDelegate:(id<EMNotificationsDelegate>)aDelegate;

- (void)removeDelegate:(id<EMNotificationsDelegate>)aDelegate;

- (void)markAllAsRead;

- (void)archive;

@end

@protocol EMNotificationsDelegate <NSObject>

@optional

- (void)didNotificationsUpdate;

- (void)didNotificationsUnreadCountUpdate:(int)aUnreadCount;

@end

NS_ASSUME_NONNULL_END
