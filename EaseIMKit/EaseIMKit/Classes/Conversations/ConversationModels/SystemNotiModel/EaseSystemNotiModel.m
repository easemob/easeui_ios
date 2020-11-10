//
//  EaseSystemNotiModel.m
//  EaseIMKit
//
//  Created by 娜塔莎 on 2020/11/10.
//

#import "EaseSystemNotiModel.h"

@implementation EaseSystemNotiModel

- (instancetype)initNotificationModel
{
    self = [super init];
    if (self) {
        _conversationTheme = @"系统通知";
        _conversationModelType = EaseSystemNotification;
        EMNotificationModel* notifcationModel = [EMNotificationHelper.shared.notificationList objectAtIndex:0];
        _latestNotificTime = notifcationModel.time;
        _stickTime = [self getNotificationStickTime];
        _timestamp = [self getLatestNotificTimestamp:notifcationModel.time];
        _isStick = [self isNotificationStick];
        _notificationSender = notifcationModel.sender;
        _notificationType = notifcationModel.type;
    }
    
    return self;
}

//更新系统通知model
- (id<EaseConversationModelDelegate>)renewalModelWithModel:(id<EaseConversationModelDelegate>)model
{
    if (model.conversationModelType != EaseSystemNotification)
        return nil;
    EaseSystemNotiModel* notificModel = (EaseSystemNotiModel*)model;
    [self renewalNotificationModel:notificModel];
    return notificModel;
}

//更新
- (void)renewalNotificationModel:(EaseSystemNotiModel*)notificModel{
    EMNotificationModel* notifcationModel = [EMNotificationHelper.shared.notificationList objectAtIndex:0];
    notificModel.latestNotificTime = notifcationModel.time;
    notificModel.stickTime = [self getNotificationStickTime];
    notificModel.timestamp = [self getLatestNotificTimestamp:notifcationModel.time];
    notificModel.isStick = [self isNotificationStick];
    notificModel.notificationSender = notifcationModel.sender;
    notificModel.notificationType = notifcationModel.type;
}

- (long long)getLatestNotificTimestamp:(NSString*)timestamp
{
    //最后一个系统通知信息时间
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *notiTime = [dateFormatter dateFromString:timestamp];
    NSTimeInterval notiTimeInterval = [notiTime timeIntervalSince1970];
    return [[NSNumber numberWithDouble:notiTimeInterval] longLongValue];
}

//是否置顶
- (BOOL)isNotificationStick
{
    EMNotificationModel* notifcationModel = [EMNotificationHelper.shared.notificationList objectAtIndex:0];
    if (notifcationModel.stickTime && ![notifcationModel.stickTime isEqualToNumber:[NSNumber numberWithLong:0]])
        return YES;
    return NO;
}

//置顶时间
- (long)getNotificationStickTime
{
    EMNotificationModel* notifcationModel = [EMNotificationHelper.shared.notificationList objectAtIndex:0];
    long stickTime = [notifcationModel.stickTime longValue];
    return stickTime;
}

@end
