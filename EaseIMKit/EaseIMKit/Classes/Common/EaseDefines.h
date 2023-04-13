//
//  EaseDefines.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/2/11.
//  Copyright © 2019 XieYajie. All rights reserved.
//


#ifndef EaseDefines_h
#define EaseDefines_h

#define kIsBangsScreen ({\
    BOOL isBangsScreen = NO; \
    if (@available(iOS 11.0, *)) { \
    UIWindow *window = [[UIApplication sharedApplication].windows firstObject]; \
    isBangsScreen = window.safeAreaInsets.bottom > 0; \
    } \
    isBangsScreen; \
})

#define EMVIEWBOTTOMMARGIN (kIsBangsScreen ? 34.f : 0.f)

#define EMSYSTEMNOTIFICATIONID @"emsystemnotificationid"

//账号状态
#define ACCOUNT_LOGIN_CHANGED @"loginStateChange"

#define NOTIF_ID @"EMNotifId"
#define NOTIF_NAVICONTROLLER @"EMNaviController"

//会话列表
#define CONVERSATIONLIST_UPDATE @"ConversationListUpdate"

//移除会话的 @ 信息
#define CONVERSATIONLIST_REMOVE_AT @"CONVERSATIONLIST_REMOVE_AT"
//@信息（默认统计，进入聊天页面不统计当前会话）
//  不统计
#define CONVERSATIONLIST_BLOCK_AT_BEGIN @"CONVERSATIONLIST_BLOCK_AT_BEGIN"
//  统计
#define CONVERSATIONLIST_BLOCK_AT_END @"CONVERSATIONLIST_BLOCK_AT_END"

//聊天
#define CHAT_PUSHVIEWCONTROLLER @"EMPushChatViewController"
#define CHAT_CLEANMESSAGES @"EMChatCleanMessages"

//编辑状态
#define MSG_TYPING_BEGIN @"TypingBegin"
#define MSG_TYPING_END @"TypingEnd"

//通话
#define EMCOMMMUNICATE_RECORD @"EMCommunicateRecord" //本地通话记录
#define EMCOMMMUNICATE @"EMCommunicate" //远端通话记录
#define EMCOMMUNICATE_TYPE @"EMCommunicateType"
#define EMCOMMUNICATE_TYPE_VOICE @"EMCommunicateTypeVoice"
#define EMCOMMUNICATE_TYPE_VIDEO @"EMCommunicateTypeVideo"
#define EMCOMMUNICATE_DURATION_TIME @"EMCommunicateDurationTime"

//通话状态
#define EMCOMMUNICATE_MISSED_CALL @"EMCommunicateMissedCall" //（通话取消）
#define EMCOMMUNICATE_CALLER_MISSEDCALL @"EMCommunicateCallerMissedCall" //（我方取消通话）
#define EMCOMMUNICATE_CALLED_MISSEDCALL @"EMCommunicateCalledMissedCall" //（对方拒绝接通）
//发起邀请
#define EMCOMMUNICATE_CALLINVITE @"EMCommunicateCallInvite" //（发起通话邀请）
//通话发起方
#define EMCOMMUNICATE_DIRECTION @"EMCommunicateDirection"
#define EMCOMMUNICATE_DIRECTION_CALLEDPARTY @"EMCommunicateDirectionCalledParty"
#define EMCOMMUNICATE_DIRECTION_CALLINGPARTY @"EMCommunicateDirectionCallingParty"

//消息动图
#define MSG_EXT_GIF_ID @"em_expression_id"
#define MSG_EXT_GIF @"em_is_big_expression"

#define MSG_EXT_READ_RECEIPT @"em_read_receipt"

//消息撤回
#define MSG_EXT_RECALL @"em_recall"
#define MSG_EXT_RECALLBY @"em_message_recallBy"

//新通知
#define MSG_EXT_NEWNOTI @"em_noti"
#define SYSTEM_NOTI_TYPE @"system_noti_type"
#define SYSTEM_NOTI_TYPE_CONTANCTSREQUEST @"ContanctsRequest"
#define SYSTEM_NOTI_TYPE_GROUPINVITATION  @"GroupInvitation"
#define SYSTEM_NOTI_TYPE_JOINGROUPREQUEST @"JoinGroupRequest"

//加群/好友 成功
#define NOTIF_ADD_SOCIAL_CONTACT @"EMAddSocialContact"

//加群/好友 类型
#define NOTI_EXT_ADDFRIEND @"add_friend"
#define NOTI_EXT_ADDGROUP @"add_group"

//多人会议邀请
#define MSG_EXT_CALLOP @"em_conference_op"
#define MSG_EXT_CALLID @"em_conference_id"
#define MSG_EXT_CALLPSWD @"em_conference_password"

//语音状态变化
#define AUDIOMSGSTATECHANGE @"audio_msg_state_change"

//实时音视频
#define CALL_CHATTER @"chatter"
#define CALL_TYPE @"type"
#define CALL_PUSH_VIEWCONTROLLER @"EMPushCallViewController"
//实时音视频1v1呼叫
#define CALL_MAKE1V1 @"EMMake1v1Call"
//实时音视频多人
#define CALL_MODEL @"EMCallForModel"
#define CALL_MAKECONFERENCE @"EMMakeConference"
#define CALL_SELECTCONFERENCECELL @"EMSelectConferenceCell"
#define CALL_INVITECONFERENCEVIEW @"EMInviteConverfenceView"

//用户黑名单
#define CONTACT_BLACKLIST_UPDATE @"EMContactBlacklistUpdate"
#define CONTACT_BLACKLIST_RELOAD @"EMContactReloadBlacklist"

//群组
#define GROUP_LIST_PUSHVIEWCONTROLLER @"EMPushGroupsViewController"
#define GROUP_INFO_UPDATED @"EMGroupInfoUpdated"
#define GROUP_SUBJECT_UPDATED @"EMGroupSubjectUpdated"
#define GROUP_INFO_REFRESH @"EMGroupInfoRefresh"
#define GROUP_INFO_PUSHVIEWCONTROLLER @"EMPushGroupInfoViewController"
#define GROUP_INFO_CLEARRECORD @"EMGroupInfoClearRecord"

//聊天室
#define CHATROOM_LIST_PUSHVIEWCONTROLLER @"EMPushChatroomsViewController"
#define CHATROOM_INFO_UPDATED @"EMChatroomInfoUpdated"
#define CHATROOM_INFO_PUSHVIEWCONTROLLER @"EMPushChatroomInfoViewController"

#define EaseLocalizableString(key,comment) ^{\
    NSString *path = [[NSBundle mainBundle] pathForResource:@"EaseIMKit" ofType:@"bundle"];\
    NSBundle* bundle = [NSBundle bundleWithPath:path];\
    return NSLocalizedStringFromTableInBundle(key, @"EaseLocalizable", bundle, comment);\
}()
#endif /* EMDefines_h */
