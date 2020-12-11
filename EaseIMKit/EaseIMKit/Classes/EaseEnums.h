//
//  EaseEnums.h
//  Pods
//
//  Created by 杜洁鹏 on 2020/11/19.
//

#ifndef EaseEnums_h
#define EaseEnums_h


#endif /* EaseEnums_h */

/*!
 *  头像风格
 */
typedef NS_ENUM(NSInteger, EaseAvatarStyle) {
    RoundedCorner = 0,      //圆角
    Rectangular,            //矩形
    Circular,               //圆形
};

/*!
 *  未读数view位置
 */
typedef NS_ENUM(NSInteger, EMUnReadCountViewPosition) {
    EMCellRight = 0,    //cell右方
    EMAvatarTopRight,   //头像右上角
};


/*!
 *  系统通知类型
 */
typedef NS_ENUM(NSInteger, EaseIMKitCallBackReason) {
    ContanctsRequestDidReceive = 0,     //收到加为联系人请求
    ContanctsRequestDidAgree = 1,       //联系人请求被同意
    
    GroupInvitationDidReceive = 10,     //收到加群邀请
    JoinGroupRequestDidReceive = 11,    //收到加群申请
};


/*!
 *  弱提醒消息
 */
typedef NS_ENUM(NSInteger, EaseWeakRemind) {
    EaseWeakRemindSystemHint = 0,   //系统提示
    EaseWeakRemindMsgTime = 10,             //消息时间
};
