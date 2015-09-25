//
//  EMCallViewController.h
//  ChatDemo-UI3.0
//
//  Created by zilong.li on 15/8/19.
//  Copyright (c) 2015年 easemob.com. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <CoreTelephony/CTCallCenter.h>
#import <UIKit/UIKit.h>
#import "EaseMob.h"

static CTCallCenter *g_callCenter;

@interface EMCallViewController : UIViewController<UIAlertViewDelegate, EMCallManagerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>
{
    NSTimer *_timeTimer;
    AVAudioPlayer *_ringPlayer;
    
    UIView *_topView;
    UILabel *_statusLabel;
    UILabel *_timeLabel;
    UILabel *_nameLabel;
    UIImageView *_headerImageView;
    
    UIView *_smallView;
    OpenGLView20 *_openGLView;
    AVCaptureVideoPreviewLayer *_smallCaptureLayer;
    AVCaptureSession *_session;
    AVCaptureVideoDataOutput *_captureOutput;
    AVCaptureDeviceInput *_captureInput;
    
    UIView *_actionView;
    UIButton *_silenceButton;
    UILabel *_silenceLabel;
    UIButton *_speakerOutButton;
    UILabel *_speakerOutLabel;
    
    UIButton *_rejectButton;
    UIButton *_answerButton;
    
    UIButton *_hangupButton;
    
    BOOL _isIncoming;
    int _timeLength;
    EMCallSession *_callSession;
    UITapGestureRecognizer *_tapRecognizer;
    
    UInt8 *_imageDataBuffer;
}

@property (strong, nonatomic) NSString *chatter;
@property (strong, nonatomic) UILabel *statusLabel;
@property (strong, nonatomic) UITapGestureRecognizer *tapRecognizer;

- (instancetype)initWithSession:(EMCallSession *)session
                     isIncoming:(BOOL)isIncoming;

+ (BOOL)canVideo;

@end
