//
//  EMChatMessage+EaseUIExt.m
//  EaseIMKit
//
//  Created by 冯钊 on 2023/4/26.
//

#import "EMChatMessage+EaseUIExt.h"
#import "EaseDefines.h"

@implementation EMChatMessage (EaseUIExt)

- (NSString *)easeUI_quoteShowText
{
    switch (self.body.type) {
        case EMMessageBodyTypeText: {
            NSString *msgStr = ((EMTextMessageBody *)self.body).text;
            if ([msgStr isEqualToString:EMCOMMUNICATE_CALLER_MISSEDCALL]) {
                msgStr = EaseLocalizableString(@"noRespond", nil);
                if ([self.from isEqualToString:EMClient.sharedClient.currentUsername])
                    msgStr = EaseLocalizableString(@"canceled", nil);
            }
            if ([msgStr isEqualToString:EMCOMMUNICATE_CALLED_MISSEDCALL]) {
                msgStr = EaseLocalizableString(@"remoteCancel", nil);
                if ([self.from isEqualToString:EMClient.sharedClient.currentUsername])
                    msgStr = EaseLocalizableString(@"remoteRefuse", nil);
            }
            if (self.ext && [self.ext objectForKey:EMCOMMUNICATE_TYPE]) {
                NSString *communicateStr = @"";
                if ([[self.ext objectForKey:EMCOMMUNICATE_TYPE] isEqualToString:EMCOMMUNICATE_TYPE_VIDEO])
                    communicateStr = EaseLocalizableString(@"[videoCall]", nil);
                if ([[self.ext objectForKey:EMCOMMUNICATE_TYPE] isEqualToString:EMCOMMUNICATE_TYPE_VOICE])
                    communicateStr = EaseLocalizableString(@"[audioCall]", nil);
                msgStr = [NSString stringWithFormat:@"%@ %@", communicateStr, msgStr];
            }
            return msgStr;
        }
        case EMMessageBodyTypeLocation:
            return EaseLocalizableString(@"[location]", nil);
        case EMMessageBodyTypeImage:
            return EaseLocalizableString(@"[image]", nil);
        case EMMessageBodyTypeFile:
            return [NSString stringWithFormat:@"%@", EaseLocalizableString(@"[file]", nil)];
        case EMMessageBodyTypeVoice:
            return EaseLocalizableString(@"[audio]", nil);
        case EMMessageBodyTypeVideo:
            return EaseLocalizableString(@"[video]", nil);
        case EMMessageBodyTypeCombine:
            return ((EMCombineMessageBody *)self.body).compatibleText;
        case EMMessageBodyTypeCustom:
            return EaseLocalizableString(@"[custommsg]", nil);
        default:
            return @"unknow message";
    }
}

@end
