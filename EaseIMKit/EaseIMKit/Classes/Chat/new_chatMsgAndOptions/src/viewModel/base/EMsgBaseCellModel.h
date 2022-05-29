//
//  EMsgBaseCellModel.h
//  EaseCallKit
//
//  Created by yangjian on 2022/5/18.
//

#import <HyphenateChat/HyphenateChat.h>

#import <Foundation/Foundation.h>

#import "EaseMessageModel.h"

#import "EMsgTableViewFunctions.h"
#import "EMsgTableViewConfig.h"
#import "EMsgCellLayoutAdapterConfigs.h"

//#import "EMsgUserBaseCell.h"

#define MSG_VOICE_CONVERTFAILURETEXT @"转换失败"

//用户消息/时间/系统消息
typedef enum : NSUInteger {
    EMsgCellType_user,
    EMsgCellType_time,
    EMsgCellType_system,
} EMsgCellType;

//自定义消息,并没有用上,这里如此写这么一段,是希望能够采用这种方式来做自定义消息方面工作
typedef enum : NSUInteger {
    ECustomMsgBodySubTypeBusinessCard = 1 << 0,
    ECustomMsgBodySubTypeRedPackage = 1 << 1,
    ECustomMsgBodySubTypeGift = 1 << 2,
} ECustomMsgBodySubType;

//语音转文字,预留
typedef enum : NSUInteger {
    EMVoiceConvertTextStateNone = 1 << 0,
    EMVoiceConvertTextStateDoing = 1 << 1,
    EMVoiceConvertTextStateSuccess = 1 << 2,
    EMVoiceConvertTextStateFailure = 1 << 3,
} EMVoiceConvertTextState;



NS_ASSUME_NONNULL_BEGIN


@interface EMsgBaseCellModel : EaseMessageModel

//@property (nonatomic,weak)EMsgUserBaseCell *weakCell;

@property (nonatomic,copy)NSString *cellName;

@property (nonatomic)EMsgCellType cellType;
//@property (nonatomic,copy)NSString *content;
@property (nonatomic,strong)NSAttributedString *show_content;
@property (nonatomic)float cellHeight;

//图片/视频
@property (nonatomic)CGSize imageFitSize;

//音频,语音消息
@property (nonatomic)EMVoiceConvertTextState voiceConvertTextState;
@property (nonatomic,copy)NSString *voiceConvertText;

//自定义
@property (nonatomic,copy)NSString *customText;


- (instancetype)initWithEMMessage:(EMChatMessage *)aMsg;

- (instancetype)initWithTimeMarker:(NSString *)timeString;

@end

NS_ASSUME_NONNULL_END
