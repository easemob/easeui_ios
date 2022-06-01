//
//  EMVoiceConvertTextHelper.h
//  EaseCallKit
//
//  Created by yangjian on 2022/5/30.
//
#import <AVFoundation/AVFoundation.h>
#import <EaseIMKit/EaseIMKit.h>

#import<Speech/Speech.h>


#import "EMsgBaseCellModel.h"
#import "EMsgUserVoiceCell.h"

NS_ASSUME_NONNULL_BEGIN

//=====================
//=====================
//=====================
@interface EMVoiceConvertTextActionReloadModel : NSObject
@property (nonatomic)EMVoiceConvertTextState state;
@property (nonatomic,strong)NSString *text;
@property (nonatomic,strong)NSError *error;
@end




//=====================
//=====================
//=====================
@interface EMVoiceConvertTextAction : NSObject

@property (nonatomic,weak)UITableView *messageTableView;
@property (nonatomic,weak)EMsgBaseCellModel *model;

@end


//=====================
//=====================
//=====================
@interface EMVoiceConvertTextHelper : NSObject

+ (instancetype)shared;

- (void)addAction:(EMVoiceConvertTextAction *)action;

- (void)stopAll;

@end







//=====================
//=====================
//=====================
@interface JJVoiceConvertTextActuator : NSObject
<
SFSpeechRecognitionTaskDelegate
>

typedef void(^EMVoiceConvertDoingHandler)(EMVoiceConvertTextState state,SFTranscription*_Nullable transcription);

typedef void(^EMVoiceConvertCompletionHandler)(EMVoiceConvertTextState state,SFSpeechRecognitionResult*_Nullable result,NSError*_Nullable error);

@property (nonatomic,copy)EMVoiceConvertDoingHandler doingHandler;
@property (nonatomic,copy)EMVoiceConvertCompletionHandler completionHandler;

+ (instancetype)recognizeLocalAudio_wavFilePath:(NSString *)wavFilePath
                                   doingHandler:(EMVoiceConvertDoingHandler)doingHandler
                              completionHandler:(EMVoiceConvertCompletionHandler)completionHandler;

- (void)cancelTask;

@end




NS_ASSUME_NONNULL_END
