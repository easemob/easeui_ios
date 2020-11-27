//
//  EaseMessageModel.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/18.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EaseHeaders.h"
#import "EaseUserDataDelegate.h"

typedef NS_ENUM(NSInteger, EMMessageType) {
    EMMessageTypeText = 1,
    EMMessageTypeImage,
    EMMessageTypeVideo,
    EMMessageTypeLocation,
    EMMessageTypeVoice,
    EMMessageTypeFile,
    EMMessageTypeCmd,
    EMMessageTypeExtGif,
    EMMessageTypeExtRecall,
    EMMessageTypeExtCall,
    EMMessageTypeExtNewFriend,
    EMMessageTypeExtAddGroup,
    EMMessageTypeCustom,
};

NS_ASSUME_NONNULL_BEGIN

@interface EaseMessageModel : NSObject

@property (nonatomic) id<EaseUserData> userDataDelegate;

@property (nonatomic, strong) EMMessage *message;

@property (nonatomic) EMMessageDirection direction;

@property (nonatomic) EMMessageType type;

@property (nonatomic) BOOL isPlaying;//去掉

- (instancetype)initWithEMMessage:(EMMessage *)aMsg;

@end

NS_ASSUME_NONNULL_END
