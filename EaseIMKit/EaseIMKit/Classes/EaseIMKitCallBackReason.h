//
//  EaseIMKitCallBackReason.h
//  EaseIMKit
//
//  Created by 娜塔莎 on 2020/11/13.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, EaseIMKitCallBackReason) {
    ContanctsRequestDidReceive = 0,     //收到加为联系人请求
    ContanctsRequestDidAgree = 1,       //联系人请求被同意
    
    GroupInvitationDidReceive = 10,     //收到加群邀请
    JoinGroupRequestDidReceive = 11,    //收到加群申请
};
