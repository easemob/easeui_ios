//
//  EaseMessageModel.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/18.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EaseMessageModel.h"
#import "EaseHeaders.h"
#import "EaseMessageCell.h"

@implementation EaseMessageModel

- (instancetype)initWithEMMessage:(EMChatMessage *)aMsg
{
    self = [super init];
    if (self) {
        _message = aMsg;
        _direction = aMsg.direction;
        _type = (EMMessageType)aMsg.body.type;
        if (aMsg.body.type == EMMessageBodyTypeText) {
            if ([aMsg.ext objectForKey:MSG_EXT_GIF]) {
                _type = EMMessageTypeExtGif;
                return self;
            }
            if ([aMsg.ext objectForKey:MSG_EXT_RECALL]) {
                _type = EMMessageTypeExtRecall;
                return self;
            }
            if ([[aMsg.ext objectForKey:MSG_EXT_NEWNOTI] isEqualToString:NOTI_EXT_ADDFRIEND]) {
                _type = EMMessageTypeExtNewFriend;
                return self;
            }
            if ([[aMsg.ext objectForKey:MSG_EXT_NEWNOTI] isEqualToString:NOTI_EXT_ADDGROUP]) {
                _type = EMMessageTypeExtAddGroup;
                return self;
            }
            NSString *conferenceId = [aMsg.ext objectForKey:@"conferenceId"];
            if ([conferenceId length] == 0)
                conferenceId = [aMsg.ext objectForKey:MSG_EXT_CALLID];
            if ([conferenceId length] > 0) {
                _type = EMMessageTypeExtCall;
                return self;
            }
            _type = EMMessageTypeText;
        }
    }
    if (aMsg.body.type == EMMessageTypeVoice) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioStateChange:) name:AUDIOMSGSTATECHANGE object:nil];
    }
    return self;
}

- (void)audioStateChange:(NSNotification *)aNotif
{
    id object = aNotif.object;
    if ([object isKindOfClass:[EaseMessageModel class]]) {
        EaseMessageModel *model = (EaseMessageModel *)object;
        if (model == self && self.isPlaying == NO) {
            self.isPlaying = YES;
        } else {
            self.isPlaying = NO;
        }
        
        [self.weakMessageCell.bubbleView setModel:self];
        if (model == self && model.direction == EMMessageDirectionReceive) {
            [self.weakMessageCell setStatusHidden:model.message.isListened];
        }
    }
}

@end
