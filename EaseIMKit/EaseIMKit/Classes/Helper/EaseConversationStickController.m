//
//  EaseConversationStickController.m
//  EaseIMKit
//
//  Created by 娜塔莎 on 2020/11/4.
//

#import "EaseConversationStickController.h"

static NSDateFormatter *_dateFormatter = nil;
@implementation EaseConversationStickController

//置顶会话
+ (void)stickConversation:(id<EaseConversationModelDelegate>)model
{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [EaseConversationStickController getDataFormatter];
    NSDate *time = [formatter dateFromString:[formatter stringFromDate:date]];
    NSTimeInterval stickTimeInterval = [time timeIntervalSince1970];
    NSNumber *stickTime = [NSNumber numberWithLong:stickTimeInterval];
    
    if (model.conversationModelType == EaseConversation) {
        EMConversationModel* conversationModel = (EMConversationModel*)model;
        NSMutableDictionary *ext = [[NSMutableDictionary alloc]initWithDictionary:conversationModel.ext];
        [ext setObject:stickTime forKey:CONVERSATION_STICK];
        //重置会话model
        [conversationModel setExt:ext];
        [conversationModel setIsStick:YES];
        [conversationModel setStickTime:[EaseConversationStickController getConversationStickTime:conversationModel]];
        
        EMConversation *conversation = [EMConversationHelper getConversationWithConversationModel:conversationModel];
        [conversation setExt:ext];
    } else if(model.conversationModelType == EaseSystemNotification) {
        EMNotificationModel* notifcationModel = [EMNotificationHelper.shared.notificationList objectAtIndex:0];
        notifcationModel.stickTime = stickTime;
        [[EMNotificationHelper shared] archive];
        
        EMSystemNotificationModel *systemNotificModel = (EMSystemNotificationModel *)model;
        //重置系统通知model
        [systemNotificModel setIsStick:YES];
        [systemNotificModel setStickTime:[EaseConversationStickController getConversationStickTime:systemNotificModel]];
    }
}

//取消置顶会话
+ (void)cancelStickConversation:(id<EaseConversationModelDelegate>)model
{
    if (model.conversationModelType == EaseConversation) {
        EMConversationModel* conversationModel = (EMConversationModel*)model;
        NSMutableDictionary *ext = [[NSMutableDictionary alloc]initWithDictionary:conversationModel.ext];
        [ext setObject:[NSNumber numberWithLong:0] forKey:CONVERSATION_STICK];
        //重置会话model
        [conversationModel setExt:ext];
        [conversationModel setIsStick:NO];
        [conversationModel setStickTime:[EaseConversationStickController getConversationStickTime:conversationModel]];
    } else if (model.conversationModelType == EaseSystemNotification) {
        EMNotificationModel* notifcationModel = [EMNotificationHelper.shared.notificationList objectAtIndex:0];
        notifcationModel.stickTime = [NSNumber numberWithLong:0];
        [[EMNotificationHelper shared] archive];
        
        EMSystemNotificationModel *systemNotificModel = (EMSystemNotificationModel *)model;
        //重置系统通知model
        [systemNotificModel setIsStick:NO];
        [systemNotificModel setStickTime:[EaseConversationStickController getConversationStickTime:systemNotificModel]];
    }
}

//会话是否已置顶
+ (BOOL)isConversationStick:(id<EaseConversationModelDelegate>)model
{
    if (model.conversationModelType == EaseConversation) {
        EMConversationModel* conversationModel = (EMConversationModel*)model;
        if ([conversationModel.ext objectForKey:CONVERSATION_STICK] && ![(NSNumber *)[conversationModel.ext objectForKey:CONVERSATION_STICK] isEqualToNumber:[NSNumber numberWithLong:0]]) {
            return YES;
        }
    } else if (model.conversationModelType == EaseSystemNotification) {
        EMNotificationModel* notifcationModel = [EMNotificationHelper.shared.notificationList objectAtIndex:0];
        if (notifcationModel.stickTime && ![notifcationModel.stickTime isEqualToNumber:[NSNumber numberWithLong:0]]) {
            return YES;
        }
    }
    return NO;
}

//会话置顶时间
+ (long)getConversationStickTime:(id<EaseConversationModelDelegate>)model
{
    long stickTime = 0;
    if (model.conversationModelType == EaseConversation) {
        EMConversationModel* conversationModel = (EMConversationModel*)model;
        stickTime = [(NSNumber *)[conversationModel.ext objectForKey:CONVERSATION_STICK] longValue];
    } else if (model.conversationModelType == EaseSystemNotification) {
        EMNotificationModel* notifcationModel = [EMNotificationHelper.shared.notificationList objectAtIndex:0];
        stickTime = [notifcationModel.stickTime longValue];
    }
    return stickTime;
}

+ (NSDateFormatter *)getDataFormatter
{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc]init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    return _dateFormatter;
}

@end
