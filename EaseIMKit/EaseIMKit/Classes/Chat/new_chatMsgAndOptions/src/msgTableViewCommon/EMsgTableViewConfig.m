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
        self.singleSend_showName = false;
        self.singleReceive_showName = false;
        
        self.groupSend_showName = false;
        self.groupReceive_showName = true;
        
        self.chatroomSend_showName = false;
        self.chatroomReceive_showName = true;
        
        self.singleSend_showHead = true;
        self.singleReceive_showHead = true;
        
        self.groupSend_showHead = true;
        self.groupReceive_showHead = true;
        
        self.chatroomSend_showHead = true;
        self.chatroomReceive_showHead = true;
        
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
