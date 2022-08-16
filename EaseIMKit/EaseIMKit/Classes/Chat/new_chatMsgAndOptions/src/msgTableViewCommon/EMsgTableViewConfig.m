//
//  EMsgViewManager.m
//  EaseIMKit
//
//  Created by yangjian on 2022/5/17.
//

#import "EMsgTableViewConfig.h"

static EMsgTableViewConfig *obj = nil;

@implementation EMsgTableViewConfig

+ (instancetype)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = EMsgTableViewConfig.new;
    });
    return obj;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.singleSend_showName = false;       //单聊 发送消息时,是否显示昵称   (当前不显示)
        self.singleReceive_showName = false;    //单聊 接收消息时,是否显示昵称   (当前不显示)
        
        self.groupSend_showName = false;    //群聊 发送消息时,是否显示昵称   (当前不显示)
        self.groupReceive_showName = true;  //群聊 接收消息时,是否显示昵称   (当前显示)
        
        self.chatroomSend_showName = false;     //聊天室 发送消息时,是否显示昵称   (当前不显示)
        self.chatroomReceive_showName = true;   //聊天室 接收消息时,是否显示昵称   (当前显示)
        
        self.singleSend_showHead = true;    //单聊 发送消息时,是否显示头像   (当前显示)
        self.singleReceive_showHead = true; //单聊 接收消息时,是否显示头像   (当前显示)
        
        self.groupSend_showHead = true;     //群聊 发送消息时,是否显示头像   (当前显示)
        self.groupReceive_showHead = true;  //群聊 接收消息时,是否显示头像   (当前显示)
        
        self.chatroomSend_showHead = true;      //聊天室 发送消息时,是否显示头像   (当前显示)
        self.chatroomReceive_showHead = true;   //聊天室 接收消息时,是否显示头像   (当前显示)
        
        self.nameFont =         [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        self.timeFont =         [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        self.systemTextFont =   [UIFont systemFontOfSize:13 weight:UIFontWeightRegular];
        self.textFont =         [UIFont systemFontOfSize:17 weight:UIFontWeightRegular];
        self.voiceConvertTextFont = [UIFont systemFontOfSize:17 weight:UIFontWeightRegular];
        self.customDescriptionFont = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];

        self.addressFont = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    }
    return self;
}

- (BOOL)showName_chatType:(EMChatType)chatType
                direction:(EMMessageDirection)direction{
    switch (chatType) {
        case EMChatTypeChat:
            switch (direction) {
                case EMMessageDirectionSend:
                    return self.singleSend_showName;
                case EMMessageDirectionReceive:
                    return self.singleReceive_showName;
            }
        case EMChatTypeGroupChat:
            switch (direction) {
                case EMMessageDirectionSend:
                    return self.groupSend_showName;
                case EMMessageDirectionReceive:
                    return self.groupReceive_showName;
            }
        case EMChatTypeChatRoom:
            switch (direction) {
                case EMMessageDirectionSend:
                    return self.chatroomSend_showName;
                case EMMessageDirectionReceive:
                    return self.chatroomReceive_showName;
            }
        default:
            return false;
    }
}

- (BOOL)showHead_chatType:(EMChatType)chatType
                direction:(EMMessageDirection)direction{
    switch (chatType) {
        case EMChatTypeChat:
            switch (direction) {
                case EMMessageDirectionSend:
                    return self.singleSend_showHead;
                case EMMessageDirectionReceive:
                    return self.singleReceive_showHead;
            }
        case EMChatTypeGroupChat:
            switch (direction) {
                case EMMessageDirectionSend:
                    return self.groupSend_showHead;
                case EMMessageDirectionReceive:
                    return self.groupReceive_showHead;
            }
        case EMChatTypeChatRoom:
            switch (direction) {
                case EMMessageDirectionSend:
                    return self.chatroomSend_showHead;
                case EMMessageDirectionReceive:
                    return self.chatroomReceive_showHead;
            }
        default:
            return true;
    }
}








@end
