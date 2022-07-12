//
//  EMsgViewManager.h
//  EaseIMKit
//
//  Created by yangjian on 2022/5/17.
//
#import <HyphenateChat/HyphenateChat.h>
#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface EMsgTableViewConfig : NSObject

+ (instancetype)shared;

@property (nonatomic)BOOL singleSend_showName;
@property (nonatomic)BOOL singleReceive_showName;

@property (nonatomic)BOOL groupSend_showName;
@property (nonatomic)BOOL groupReceive_showName;

@property (nonatomic)BOOL chatroomSend_showName;
@property (nonatomic)BOOL chatroomReceive_showName;

@property (nonatomic)BOOL singleSend_showHead;
@property (nonatomic)BOOL singleReceive_showHead;

@property (nonatomic)BOOL groupSend_showHead;
@property (nonatomic)BOOL groupReceive_showHead;

@property (nonatomic)BOOL chatroomSend_showHead;
@property (nonatomic)BOOL chatroomReceive_showHead;

- (BOOL)showName_chatType:(EMChatType)chatType
                direction:(EMMessageDirection)direction;
- (BOOL)showHead_chatType:(EMChatType)chatType
                direction:(EMMessageDirection)direction;

@property (nonatomic,strong)UIFont *nameFont;
@property (nonatomic,strong)UIFont *timeFont;
@property (nonatomic,strong)UIFont *systemTextFont;

@property (nonatomic,strong)UIFont *textFont;
@property (nonatomic,strong)UIFont *voiceConvertTextFont;//语音转文字
@property (nonatomic,strong)UIFont *customDescriptionFont;
@property (nonatomic,strong)UIFont *addressFont;

@end

NS_ASSUME_NONNULL_END
