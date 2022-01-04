//
//  EMAudioPlayerUtil.m
//  EaseIMKit
//
//  Created by 娜塔莎 on 2020/11/17.
//

#import <AVFoundation/AVAudioPlayer.h>
#import "EMAudioPlayerUtil.h"
#import "amrFileCodec.h"
#import "EaseDefines.h"

static EMAudioPlayerUtil *playerUtil = nil;
@interface EMAudioPlayerUtil ()<AVAudioPlayerDelegate>

@property (nonatomic, strong) NSString *playingPath;

@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, copy) void (^playerFinished)(NSError *error);

@end

@implementation EMAudioPlayerUtil

+ (instancetype)sharedHelper
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        playerUtil = [[EMAudioPlayerUtil alloc] init];
    });
    
    return playerUtil;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    
    return self;
}

- (void)dealloc
{
    [self stopPlayer];
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player
                       successfully:(BOOL)flag
{
    if (self.playerFinished) {
        self.playerFinished(nil);
    }
    
    self.playerFinished = nil;
    if (_player) {
        _player.delegate = nil;
        _player = nil;
    }
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player
                                 error:(NSError *)error
{
    if (self.playerFinished) {
        NSError *error = [NSError errorWithDomain:EaseLocalizableString(@"playFail", nil) code:-1 userInfo:nil];
        self.playerFinished(error);
    }
    
    self.playerFinished = nil;
    if (_player) {
        _player.delegate = nil;
        _player = nil;
    }
}

#pragma mark - Private

+ (int)isMP3File:(NSString *)aFilePath
{
    const char *filePath = [aFilePath cStringUsingEncoding:NSASCIIStringEncoding];
    return isMP3File(filePath);
}

+ (int)amrToWav:(NSString*)aAmrPath wavSavePath:(NSString*)aWavPath
{
    
    if (EM_DecodeAMRFileToWAVEFile([aAmrPath cStringUsingEncoding:NSASCIIStringEncoding], [aWavPath cStringUsingEncoding:NSASCIIStringEncoding]))
        return 0; // success
    
    return 1;   // failed
}

- (NSString *)_convertAudioFile:(NSString *)aPath
{
    if ([[aPath pathExtension] isEqualToString:@"mp3"]) {
        return aPath;
    }
    
    NSString *retPath = [[aPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"wav"];
    do {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:retPath]) {
            break;
        }
        
        if ([EMAudioPlayerUtil isMP3File:retPath]) {
            retPath = aPath;
            break;
        }
        
        [EMAudioPlayerUtil amrToWav:aPath wavSavePath:retPath];
        if (![fileManager fileExistsAtPath:retPath]) {
            retPath = nil;
        }
        
    } while (0);
    
    return retPath;
}

#pragma mark - Public

- (void)startPlayerWithPath:(NSString *)aPath
                      model:(id)aModel
                 completion:(void(^)(NSError *error))aCompleton
{
    NSError *error = nil;
    do {
        NSFileManager *fm = [NSFileManager defaultManager];
        if (![fm fileExistsAtPath:aPath]) {
            NSString *fileName = aPath.lastPathComponent;
            aPath = [[self getAudioOrVideoPath] stringByAppendingPathComponent:fileName];
            if (![fm fileExistsAtPath:aPath]) {
                error = [NSError errorWithDomain:EaseLocalizableString(@"fileNotExist", nil) code:-1 userInfo:nil];
                break;
            }
        }
        
        if (self.player && self.player.isPlaying && [self.playingPath isEqualToString:aPath]) {
            break;
        } else {
            [self stopPlayer];
        }
        
        aPath = [self _convertAudioFile:aPath];
        if ([aPath length] == 0) {
            error = [NSError errorWithDomain:EaseLocalizableString(@"transferVoiceFail", nil) code:-1 userInfo:nil];
            break;
        }
        
        self.model = aModel;
        
        NSURL *wavUrl = [[NSURL alloc] initFileURLWithPath:aPath];
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:wavUrl error:&error];
        if (error || !self.player) {
            self.player = nil;
            error = [NSError errorWithDomain:EaseLocalizableString(@"initAVFail", nil) code:-1 userInfo:nil];
            break;
        }
        
        self.playingPath = aPath;
        [self setPlayerFinished:aCompleton];
        
        self.player.delegate = self;
        BOOL ret = [self.player prepareToPlay];
        if (ret) {
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            [audioSession setCategory:AVAudioSessionCategoryPlayback error:&error];
            if (error) {
                break;
            }
        }
        
        ret = [self.player play];
        if (!ret) {
            [self stopPlayer];
            error = [NSError errorWithDomain:EaseLocalizableString(@"AVplayFail", nil) code:-1 userInfo:nil];
        }
        
    } while (0);
    
    if (error) {
        if (aCompleton) {
            aCompleton(error);
        }
    }
}

- (NSString *)getAudioOrVideoPath
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    path = [path stringByAppendingPathComponent:@"EMDemoRecord"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return path;
}

- (void)stopPlayer
{
    if(_player) {
        _player.delegate = nil;
        [_player stop];
        _player = nil;
    }
    
    self.playingPath = nil;
    self.playerFinished = nil;
}

@end
