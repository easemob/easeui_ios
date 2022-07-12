//
//  EMVoiceConvertTextHelper.m
//  EaseCallKit
//
//  Created by yangjian on 2022/5/30.
//

#import "EMVoiceConvertTextHelper.h"

#import "EMAudioPlayerUtil.h"
#import "amrFileCodec.h"

//#import "EaseAlertController.h"

//=====================
//=====================
//=====================
@implementation EMVoiceConvertTextActionReloadModel
@end

//=====================
//=====================
//=====================
@interface EMVoiceConvertTextAction ()
@property (nonatomic,strong) NSMutableArray <EMVoiceConvertTextActionReloadModel *>*temp_reloadModels;
@property (nonatomic)BOOL isReloading;
@end

@implementation EMVoiceConvertTextAction

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.temp_reloadModels = [[NSMutableArray alloc] init];
        self.isReloading = false;
    }
    return self;
}

- (void)addReloadData_state:(EMVoiceConvertTextState)state
                       text:(NSString *)text
                      error:(NSError *)error{
    
    EMVoiceConvertTextActionReloadModel *model = [[EMVoiceConvertTextActionReloadModel alloc] init];
    model.text = text;
    model.state = state;
    model.error = error;
    [self.temp_reloadModels addObject:model];
    if (!self.isReloading) {
        [self startNext];
    }
}

- (void)startNext{
    
    NSLog(@"--==-=-=-=-=0=-0-=0=-0=-=");
    
    if (self.temp_reloadModels.count) {
        self.isReloading = true;
        [NSRunLoop.currentRunLoop cancelPerformSelector:@selector(startReload) target:self argument:nil];
        [NSRunLoop.currentRunLoop performSelector:@selector(startReload) target:self argument:nil order:10 modes:@[NSDefaultRunLoopMode]];
    }else{
        self.isReloading = false;
    }
}

- (void)startReload{


    EMVoiceConvertTextActionReloadModel *reloadModel = self.temp_reloadModels.firstObject;
    [self.temp_reloadModels removeObjectAtIndex:0];
    self.model.voiceConvertTextState = reloadModel.state;
    self.model.voiceConvertText = reloadModel.text;
    
//    __weak typeof(self) weakSelf = self;
    
    //下面两种方法效果一致
//    [UIView animateWithDuration:0.2 animations:^{
//        [self.messageTableView reloadRowsAtIndexPaths:@[[self.messageTableView indexPathForCell:self.model.weakCell]]
//                                     withRowAnimation:UITableViewRowAnimationNone];
//    } completion:^(BOOL finished) {
//        [self startNext];
//    }];
    [self.messageTableView performBatchUpdates:^{
        [self.messageTableView reloadRowsAtIndexPaths:@[[self.messageTableView indexPathForCell:self.model.weakCell]]
                                     withRowAnimation:UITableViewRowAnimationNone];
    } completion:^(BOOL finished) {
        [self startNext];

            /*
             当遍历执行完成之后,会自动释放的.
             后果是:执行完一个方法之后,如果后面弱引用,则会被释放掉.

             详细说明:
             由于在滚动视图的时候,不进行界面处理,而界面停止之后才会进行处理,故对象会被提前释放持有.
             可查询NSDefaultRunLoopMode相关说明.
             为了保持对象不被释放掉,所以在block中强持有.

             所以必须使用self,而不是weakself.
             若担心此处理有问题,可使用completion block内的dispatch_async来印证.
             如下代码解开即可发现,会输出:
             2022-05-30 22:37:03.778786+0800 EaseIM[19350:540087] ~~~~~~~~~~~~~~(null)

             */
//        dispatch_async(dispatch_get_main_queue(), ^{
//            NSLog(@"~~~~~~~~~~~~~~%@",weakSelf);
//        });
    }];
}

@end


//=====================
//=====================
//=====================
@interface EMVoiceConvertTextHelper ()

@property (nonatomic,strong)NSMutableArray *actionQueue;
@property(nonatomic,strong)EMVoiceConvertTextAction *currentAction;
@property(nonatomic,strong)JJVoiceConvertTextActuator *actuator;

//正在做
@property (nonatomic)BOOL isDoing;

@end

static EMVoiceConvertTextHelper *obj = nil;
@implementation EMVoiceConvertTextHelper



+ (instancetype)shared{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[EMVoiceConvertTextHelper alloc] init];
    });
    return obj;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.actionQueue = [[NSMutableArray alloc] init];
        self.isDoing = false;
    }
    return self;
}

- (void)addAction:(EMVoiceConvertTextAction *)action{
    [self.actionQueue addObject:action];
    [action addReloadData_state:EMVoiceConvertTextStateDoing text:@"转换中..." error:nil];
    [self startAll];
}

- (void)startAll{
    if (self.isDoing) {
        return;
    }
    [self startNext];
}

- (void)startNext{
    if (self.actionQueue.count) {
        self.isDoing = true;
        self.currentAction = self.actionQueue.firstObject;
        [self.actionQueue removeObjectAtIndex:0];
        [self startOne];
    }else{
        self.isDoing = false;
        self.currentAction = nil;
    }
}

//处理文件路径 文件转换格式.
- (void)fetchWavFilePathFromFilePath:(NSString *)filePath
                   completionHandler:(void(^)(NSString *wavFilePath,NSError *error))completionHandler{

    if (![NSFileManager.defaultManager fileExistsAtPath:filePath]) {
        NSString *fileName = filePath.lastPathComponent;
        
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        path = [path stringByAppendingPathComponent:@"EMDemoRecord"];
        if (![NSFileManager.defaultManager fileExistsAtPath:path]) {
            [NSFileManager.defaultManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        }
        filePath = [path stringByAppendingPathComponent:fileName];
        if (![NSFileManager.defaultManager fileExistsAtPath:filePath]) {
            completionHandler(@"",[NSError errorWithDomain:EaseLocalizableString(@"fileNotExist", nil) code:-2 userInfo:nil]);
            return;
        }
    }

    //mp3 - file.pathExtension
    if ([[filePath pathExtension] isEqualToString:@"mp3"]) {
        completionHandler(filePath,nil);
        return;
    }
    
    //mp3 - file.data
    if (isMP3File([filePath cStringUsingEncoding:NSASCIIStringEncoding])) {
        completionHandler(filePath,nil);
        return;
    }

    //wav - pathExtension - exists
    NSString *wavFilePath
    = [[filePath stringByDeletingPathExtension] stringByAppendingPathExtension:@"wav"];
    if ([NSFileManager.defaultManager fileExistsAtPath:wavFilePath]) {
        completionHandler(wavFilePath,nil);
        return;
    }
    
    //amr
    if (isAMRFile([filePath cStringUsingEncoding:NSASCIIStringEncoding])) {
        if (EM_DecodeAMRFileToWAVEFile([filePath cStringUsingEncoding:NSASCIIStringEncoding],
                                       [wavFilePath cStringUsingEncoding:NSASCIIStringEncoding])){
            completionHandler(wavFilePath,nil);
            return;
        }
    }
    
    completionHandler(@"",[NSError errorWithDomain:@"fileConvertFailure" code:-3 userInfo:nil]);
    return;
}

- (void)startOne{
    EMVoiceMessageBody *body = (EMVoiceMessageBody *)self.currentAction.model.message.body;
    if (body.downloadStatus == EMDownloadStatusDownloading) {
        [self.currentAction addReloadData_state:EMVoiceConvertTextStateFailure text:MSG_VOICE_CONVERTFAILURETEXT error:[NSError errorWithDomain:@"fileConvertFailure" code:-1 userInfo:nil]];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self fetchWavFilePathFromFilePath:body.localPath completionHandler:^(NSString *wavFilePath, NSError *error) {
        if (error) {
            [weakSelf.currentAction addReloadData_state:EMVoiceConvertTextStateFailure text:MSG_VOICE_CONVERTFAILURETEXT error:error];
            return;
        }
        weakSelf.actuator = [JJVoiceConvertTextActuator recognizeLocalAudio_wavFilePath:wavFilePath doingHandler:^(EMVoiceConvertTextState state, SFTranscription * _Nullable transcription) {
            [weakSelf.currentAction addReloadData_state:state text:transcription.formattedString error:nil];
        } completionHandler:^(EMVoiceConvertTextState state, SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
            [weakSelf.currentAction addReloadData_state:state text:result.bestTranscription.formattedString error:error];
            [weakSelf startNext];
        }];
    }];
}

- (void)stopOne{
    
}

- (void)stopAll{
    [self.actionQueue removeAllObjects];
    self.isDoing = false;
    [self.actuator cancelTask];
}


@end

//=====================
//=====================
//=====================
@interface JJVoiceConvertTextActuator ()

@property (nonatomic,strong)SFSpeechRecognitionTask *recognitionTask;
@property (nonatomic,strong)SFSpeechRecognitionResult *result;
@end
@implementation JJVoiceConvertTextActuator

+ (instancetype)recognizeLocalAudio_wavFilePath:(NSString *)wavFilePath
                                   doingHandler:(EMVoiceConvertDoingHandler)doingHandler
                              completionHandler:(EMVoiceConvertCompletionHandler)completionHandler{
    
    
    NSData *data = [NSData dataWithContentsOfFile:wavFilePath];
    NSLog(@"%lld",data.length);
    NSLog(@"%@",wavFilePath);
    
    JJVoiceConvertTextActuator *actuator = [[JJVoiceConvertTextActuator alloc] init];
    SFSpeechURLRecognitionRequest *recognitionRequest
    = [[SFSpeechURLRecognitionRequest alloc] initWithURL:[NSURL fileURLWithPath:wavFilePath]];
    SFSpeechRecognizer *recongnizer
    = [[SFSpeechRecognizer alloc] initWithLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    actuator.recognitionTask
    = [recongnizer recognitionTaskWithRequest:recognitionRequest delegate:actuator];
    actuator.doingHandler = doingHandler;
    actuator.completionHandler = completionHandler;
    return actuator;
}

- (void)cancelTask{
    [self.recognitionTask cancel];
}


// Called when the task first detects speech in the source audio
- (void)speechRecognitionDidDetectSpeech:(SFSpeechRecognitionTask *)task{
    
}

// Called for all recognitions, including non-final hypothesis
- (void)speechRecognitionTask:(SFSpeechRecognitionTask *)task didHypothesizeTranscription:(SFTranscription *)transcription{
    NSLog(@"转换中...");
    if (task.isCancelled) {
        return;
    }
    NSLog(@"%@",transcription.formattedString);
    self.doingHandler(EMVoiceConvertTextStateDoing, transcription);
}

// Called only for final recognitions of utterances. No more about the utterance will be reported
- (void)speechRecognitionTask:(SFSpeechRecognitionTask *)task didFinishRecognition:(SFSpeechRecognitionResult *)recognitionResult{
    self.result = recognitionResult;
    NSLog(@"%@",self.result.bestTranscription.formattedString);
}

// Called when the task is no longer accepting new audio but may be finishing final processing
- (void)speechRecognitionTaskFinishedReadingAudio:(SFSpeechRecognitionTask *)task{
    
}

// Called when the task has been cancelled, either by client app, the user, or the system
- (void)speechRecognitionTaskWasCancelled:(SFSpeechRecognitionTask *)task{
    
}

// Called when recognition of all requested utterances is finished.
// If successfully is false, the error property of the task will contain error information
- (void)speechRecognitionTask:(SFSpeechRecognitionTask *)task didFinishSuccessfully:(BOOL)successfully{
    if (successfully) {
        self.completionHandler(EMVoiceConvertTextStateSuccess, self.result, nil);
    }else{
        self.completionHandler(EMVoiceConvertTextStateFailure, nil, task.error);
    }
}


@end

