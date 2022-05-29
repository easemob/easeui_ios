//
//  EMMsgTouchIncident.m
//  EaseIM
//
//  Created by 娜塔莎 on 2020/7/7.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import <AVKit/AVKit.h>
#import "EMMsgTouchIncident.h"

#import "EMMessageTimeCell.h"
#import "EMLocationViewController.h"
#import "EMImageBrowser.h"
#import "EaseDateHelper.h"
#import "EMAudioPlayerUtil.h"
#import "EMMsgRecordCell.h"
#import "EaseHeaders.h"
#import "EMMsgTextBubbleView.h"

@implementation EMMessageEventStrategy

- (void)messageCellEventOperation:(EaseMessageCell *)aCell{}
- (void)messageCell:(EMsgUserBaseCell *)cell selectedEventOperation:(EMsgBaseCellModel *)model{}

@end

/**
   消息事件工厂
*/
@implementation EMMessageEventStrategyFactory

+ (EMMessageEventStrategy * _Nonnull)getStratrgyImplWithMsgCell:(EaseMessageCell *)aCell
{
    if (aCell.model.type == EMMessageTypeText)
        return [[TextMsgEvent alloc]init];
    if (aCell.model.type == EMMessageTypeImage)
        return [[ImageMsgEvent alloc] init];
    if (aCell.model.type == EMMessageTypeLocation)
        return [[LocationMsgEvent alloc] init];
    if (aCell.model.type == EMMessageTypeVoice)
        return [[VoiceMsgEvent alloc]init];
    if (aCell.model.type == EMMessageTypeVideo)
        return [[VideoMsgEvent alloc]init];
    if (aCell.model.type == EMMessageTypeFile)
        return [[FileMsgEvent alloc]init];
    if (aCell.model.type == EMMessageTypeExtCall)
        return [[ConferenceMsgEvent alloc]init];
    
    return [[EMMessageEventStrategy alloc]init];
}

+ (EMMessageEventStrategy * _Nonnull)fetchStratrgyImplWithCellModel:(EaseMessageModel *)model
{
    if (model.type == EMMessageTypeText)
        return [[TextMsgEvent alloc]init];
    if (model.type == EMMessageTypeImage)
        return [[ImageMsgEvent alloc] init];
    if (model.type == EMMessageTypeLocation)
        return [[LocationMsgEvent alloc] init];
    if (model.type == EMMessageTypeVoice)
        return [[VoiceMsgEvent alloc]init];
    if (model.type == EMMessageTypeVideo)
        return [[VideoMsgEvent alloc]init];
    if (model.type == EMMessageTypeFile)
        return [[FileMsgEvent alloc]init];
    if (model.type == EMMessageTypeExtCall)
        return [[ConferenceMsgEvent alloc]init];
    
    return [[EMMessageEventStrategy alloc]init];
}


@end

/**
    文本事件
 */
@implementation TextMsgEvent

- (void)messageCellEventOperation:(EaseMessageCell *)aCell
{
    EMMsgTextBubbleView *textBubbleView = (EMMsgTextBubbleView *)aCell.bubbleView;
    NSString *chatStr = textBubbleView.textLabel.text;

    NSDataDetector *detector= [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink error:nil];
    NSArray *checkArr = [detector matchesInString:chatStr options:0 range:NSMakeRange(0, chatStr.length)];
    //判断有没有链接
    if(checkArr.count > 0) {
        if (checkArr.count > 1) { //网址多于1个时让用户选择跳哪个链接
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:EaseLocalizableString(@"selectLinkUrl", nil) message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            [alertController addAction:[UIAlertAction actionWithTitle:EaseLocalizableString(@"cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
            
            for (NSTextCheckingResult *result in checkArr) {
                NSString *urlStr = result.URL.absoluteString;
                [alertController addAction:[UIAlertAction actionWithTitle:urlStr style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr] options:[NSDictionary new] completionHandler:nil];
                }]];
            }
            [self.chatController presentViewController:alertController animated:YES completion:nil];
        }else {//一个链接直接打开
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[checkArr[0] URL].absoluteString] options:[NSDictionary new] completionHandler:nil];
        }
    }
}
- (void)messageCell:(EMsgUserBaseCell *)cell selectedEventOperation:(EMsgBaseCellModel *)model{
    EMTextMessageBody *body = (EMTextMessageBody *)model.message.body;
    NSString *chatStr = body.text;
    NSDataDetector *detector= [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink error:nil];
    NSArray *checkArr = [detector matchesInString:chatStr options:0 range:NSMakeRange(0, chatStr.length)];
    //判断有没有链接
    if(checkArr.count > 0) {
        if (checkArr.count > 1) { //网址多于1个时让用户选择跳哪个链接
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:EaseLocalizableString(@"selectLinkUrl", nil) message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            [alertController addAction:[UIAlertAction actionWithTitle:EaseLocalizableString(@"cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
            
            for (NSTextCheckingResult *result in checkArr) {
                NSString *urlStr = result.URL.absoluteString;
                [alertController addAction:[UIAlertAction actionWithTitle:urlStr style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr] options:[NSDictionary new] completionHandler:nil];
                }]];
            }
            [self.chatController presentViewController:alertController animated:YES completion:nil];
        }else {//一个链接直接打开
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[checkArr[0] URL].absoluteString] options:[NSDictionary new] completionHandler:nil];
        }
    }
}

@end

/**
    图片事件
 */
@implementation ImageMsgEvent

- (void)messageCellEventOperation:(EaseMessageCell *)aCell
{
    __weak typeof(self.chatController) weakself = self.chatController;
    void (^downloadThumbBlock)(EaseMessageModel *aModel) = ^(EaseMessageModel *aModel) {
        [weakself showHint:EaseLocalizableString(@"getThumnail...", nil)];
        [[EMClient sharedClient].chatManager downloadMessageThumbnail:aModel.message progress:nil completion:^(EMChatMessage *message, EMError *error) {
            if (!error) {
                [weakself.tableView reloadData];
            }
        }];
    };
    
    EMImageMessageBody *body = (EMImageMessageBody*)aCell.model.message.body;
    BOOL isCustomDownload = !([EMClient sharedClient].options.isAutoTransferMessageAttachments);
    if (body.thumbnailDownloadStatus == EMDownloadStatusFailed) {
        if (!isCustomDownload) {
            downloadThumbBlock(aCell.model);
        }
        
        return;
    }
    
    BOOL isAutoDownloadThumbnail = [EMClient sharedClient].options.isAutoDownloadThumbnail;
    if (body.thumbnailDownloadStatus == EMDownloadStatusPending && !isAutoDownloadThumbnail) {
        downloadThumbBlock(aCell.model);
        return;
    }
    
    if (body.downloadStatus == EMDownloadStatusSucceed) {
        UIImage *image = [UIImage imageWithContentsOfFile:body.localPath];
        if (image) {
            [[EMImageBrowser sharedBrowser] showImages:@[image] fromController:self.chatController];
            return;
        }
    }
    
    if (isCustomDownload) {
        return;
    }
    
    [self.chatController showHudInView:self.chatController.view hint:EaseLocalizableString(@"downloadingImage...", nil)];
    [[EMClient sharedClient].chatManager downloadMessageAttachment:aCell.model.message progress:nil completion:^(EMChatMessage *message, EMError *error) {
        [weakself hideHud];
        if (error) {
            [EaseAlertController showErrorAlert:EaseLocalizableString(@"downloadImageFail", nil)];
        } else {
            if (message.direction == EMMessageDirectionReceive && !message.isReadAcked) {
                [[EMClient sharedClient].chatManager sendMessageReadAck:message.messageId toUser:message.conversationId completion:nil];
            }
            
            NSString *localPath = [(EMImageMessageBody *)message.body localPath];
            UIImage *image = [UIImage imageWithContentsOfFile:localPath];
            if (image) {
                [[EMImageBrowser sharedBrowser] showImages:@[image] fromController:weakself];
            } else {
                [EaseAlertController showErrorAlert:EaseLocalizableString(@"fetchImageFail", nil)];
            }
        }
    }];
}
- (void)messageCell:(EMsgUserBaseCell *)cell selectedEventOperation:(EMsgBaseCellModel *)model{
    __weak typeof(self.chatController) weakself = self.chatController;
    void (^downloadThumbBlock)(EaseMessageModel *aModel) = ^(EaseMessageModel *aModel) {
        [weakself showHint:EaseLocalizableString(@"getThumnail...", nil)];
        [[EMClient sharedClient].chatManager downloadMessageThumbnail:aModel.message progress:nil completion:^(EMChatMessage *message, EMError *error) {
            if (!error) {
                [weakself.tableView reloadData];
            }
        }];
    };
    
    EMImageMessageBody *body = (EMImageMessageBody*)model.message.body;
    BOOL isCustomDownload = !([EMClient sharedClient].options.isAutoTransferMessageAttachments);
    if (body.thumbnailDownloadStatus == EMDownloadStatusFailed) {
        if (!isCustomDownload) {
            downloadThumbBlock(model);
        }
        
        return;
    }
    
    BOOL isAutoDownloadThumbnail = [EMClient sharedClient].options.isAutoDownloadThumbnail;
    if (body.thumbnailDownloadStatus == EMDownloadStatusPending && !isAutoDownloadThumbnail) {
        downloadThumbBlock(model);
        return;
    }
    
    if (body.downloadStatus == EMDownloadStatusSucceed) {
        UIImage *image = [UIImage imageWithContentsOfFile:body.localPath];
        if (image) {
            [[EMImageBrowser sharedBrowser] showImages:@[image] fromController:self.chatController];
            return;
        }
    }
    
    if (isCustomDownload) {
        return;
    }
    
    [self.chatController showHudInView:self.chatController.view hint:EaseLocalizableString(@"downloadingImage...", nil)];
    [[EMClient sharedClient].chatManager downloadMessageAttachment:model.message progress:nil completion:^(EMChatMessage *message, EMError *error) {
        [weakself hideHud];
        if (error) {
            [EaseAlertController showErrorAlert:EaseLocalizableString(@"downloadImageFail", nil)];
        } else {
            if (message.direction == EMMessageDirectionReceive && !message.isReadAcked) {
                [[EMClient sharedClient].chatManager sendMessageReadAck:message.messageId toUser:message.conversationId completion:nil];
            }
            
            NSString *localPath = [(EMImageMessageBody *)message.body localPath];
            UIImage *image = [UIImage imageWithContentsOfFile:localPath];
            if (image) {
                [[EMImageBrowser sharedBrowser] showImages:@[image] fromController:weakself];
            } else {
                [EaseAlertController showErrorAlert:EaseLocalizableString(@"fetchImageFail", nil)];
            }
        }
    }];
}

@end


/**
    位置消息事件
 */
@implementation LocationMsgEvent

- (void)messageCellEventOperation:(EaseMessageCell *)aCell
{
    EMLocationMessageBody *body = (EMLocationMessageBody *)aCell.model.message.body;
    EMLocationViewController *controller = [[EMLocationViewController alloc] initWithLocation:CLLocationCoordinate2DMake(body.latitude, body.longitude)];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    navController.modalPresentationStyle = 0;
    [self.chatController.navigationController presentViewController:navController animated:YES completion:nil];
}
- (void)messageCell:(EMsgUserBaseCell *)cell selectedEventOperation:(EMsgBaseCellModel *)model{
    EMLocationMessageBody *body = (EMLocationMessageBody *)model.message.body;
    EMLocationViewController *controller = [[EMLocationViewController alloc] initWithLocation:CLLocationCoordinate2DMake(body.latitude, body.longitude)];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    navController.modalPresentationStyle = 0;
    [self.chatController.navigationController presentViewController:navController animated:YES completion:nil];
}

@end

/**
    语音消息事件
 */
#import "EMsgUserVoiceCell.h"
@implementation VoiceMsgEvent

- (void)messageCellEventOperation:(EaseMessageCell *)aCell
{
    EMVoiceMessageBody *body = (EMVoiceMessageBody*)aCell.model.message.body;
    if (body.downloadStatus == EMDownloadStatusDownloading) {
        [EaseAlertController showInfoAlert:EaseLocalizableString(@"downloadingVoice...", nil)];
        return;
    }
    
    void (^playBlock)(EaseMessageModel *aModel) = ^(EaseMessageModel *aModel) {
        if (!aModel.message.isListened) {
            aModel.message.isListened = YES;
        }
        
        if (!aModel.message.isReadAcked) {
            [[EMClient sharedClient].chatManager sendMessageReadAck:aModel.message.messageId toUser:aModel.message.conversationId completion:nil];
        }

        id model = [EMAudioPlayerUtil sharedHelper].model;
        if (model && [model isKindOfClass:[EaseMessageModel class]]) {
            EaseMessageModel *oldModel = (EaseMessageModel *)model;
            if (oldModel == aCell.model && oldModel.isPlaying == YES) {
                [[EMAudioPlayerUtil sharedHelper] stopPlayer];
                [EMAudioPlayerUtil sharedHelper].model = nil;
                [[NSNotificationCenter defaultCenter] postNotificationName:AUDIOMSGSTATECHANGE object:aModel];
                return;
            }
        }
    
        [EMClient.sharedClient.chatManager updateMessage:aModel.message completion:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:AUDIOMSGSTATECHANGE object:aModel];
        [[EMAudioPlayerUtil sharedHelper] startPlayerWithPath:body.localPath model:aModel completion:^(NSError * _Nonnull error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:AUDIOMSGSTATECHANGE object:aModel];
        }];
    };
    
    if (body.downloadStatus == EMDownloadStatusSucceed) {
        playBlock(aCell.model);
        return;
    }
    
    if (![EMClient sharedClient].options.isAutoTransferMessageAttachments) {
        return;
    }
    
    __weak typeof(self.chatController) weakChatControl = self.chatController;
    [self.chatController showHudInView:self.chatController.view hint:EaseLocalizableString(@"downloadingVoice", nil)];
    [[EMClient sharedClient].chatManager downloadMessageAttachment:aCell.model.message progress:nil completion:^(EMChatMessage *message, EMError *error) {
        [weakChatControl hideHud];
        if (error) {
            [EaseAlertController showErrorAlert:EaseLocalizableString(@"downloadVoiceFail", nil)];
        } else {
            playBlock(aCell.model);
        }
    }];
}
- (void)messageCell:(EMsgUserBaseCell *)cell selectedEventOperation:(EMsgBaseCellModel *)model{
    EMVoiceMessageBody *body = (EMVoiceMessageBody*)model.message.body;
    if (body.downloadStatus == EMDownloadStatusDownloading) {
        [EaseAlertController showInfoAlert:EaseLocalizableString(@"downloadingVoice...", nil)];
        return;
    }
    
    void (^playBlock)(EMsgUserBaseCell *cell,EMsgBaseCellModel *model) = ^(EMsgUserBaseCell *cell,EMsgBaseCellModel *model) {
        if (!model.message.isListened) {
            model.message.isListened = YES;
        }
        
        if (!model.message.isReadAcked) {
            [[EMClient sharedClient].chatManager sendMessageReadAck:model.message.messageId toUser:model.message.conversationId completion:nil];
        }

        id lastModel = [EMAudioPlayerUtil sharedHelper].model;
        if (lastModel && [lastModel isKindOfClass:[EaseMessageModel class]]) {
            EaseMessageModel *oldModel = (EaseMessageModel *)lastModel;
            if (oldModel == model && oldModel.isPlaying == YES) {
                [[EMAudioPlayerUtil sharedHelper] stopPlayer];
                [EMAudioPlayerUtil sharedHelper].model = nil;
//                [[NSNotificationCenter defaultCenter] postNotificationName:AUDIOMSGSTATECHANGE object:aModel];
                model.isPlaying = !model.isPlaying;
                [((EMsgUserVoiceCell *)cell) playing:model.isPlaying];
                return;
            }
        }
    
        [EMClient.sharedClient.chatManager updateMessage:model.message completion:nil];
        model.isPlaying = !model.isPlaying;
        [((EMsgUserVoiceCell *)cell) playing:model.isPlaying];
        [[EMAudioPlayerUtil sharedHelper] startPlayerWithPath:body.localPath model:model completion:^(NSError * _Nonnull error) {
            model.isPlaying = !model.isPlaying;
            [((EMsgUserVoiceCell *)cell) playing:model.isPlaying];
        }];
    };
    
    if (body.downloadStatus == EMDownloadStatusSucceed) {
        playBlock(cell,model);
        return;
    }
    
    if (![EMClient sharedClient].options.isAutoTransferMessageAttachments) {
        return;
    }
    
    __weak typeof(self.chatController) weakChatControl = self.chatController;
    [self.chatController showHudInView:self.chatController.view hint:EaseLocalizableString(@"downloadingVoice", nil)];
    [[EMClient sharedClient].chatManager downloadMessageAttachment:model.message progress:nil completion:^(EMChatMessage *message, EMError *error) {
        [weakChatControl hideHud];
        if (error) {
            [EaseAlertController showErrorAlert:EaseLocalizableString(@"downloadVoiceFail", nil)];
        } else {
            playBlock(cell,model);
        }
    }];
}


@end

/**
    视频消息事件
 */
@implementation VideoMsgEvent

- (void)messageCellEventOperation:(EaseMessageCell *)aCell
{
    __weak typeof(self.chatController) weakChatController = self.chatController;
    void (^playBlock)(NSString *aPath) = ^(NSString *aPathe) {
        NSURL *videoURL = [NSURL fileURLWithPath:aPathe];
        AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
        playerViewController.player = [AVPlayer playerWithURL:videoURL];
        playerViewController.videoGravity = AVLayerVideoGravityResizeAspect;
        playerViewController.showsPlaybackControls = YES;
        playerViewController.modalPresentationStyle = 0;
        [weakChatController presentViewController:playerViewController animated:YES completion:^{
            [playerViewController.player play];
        }];
    };

    void (^downloadBlock)(void) = ^ {
        [weakChatController showHudInView:self.chatController.view hint:EaseLocalizableString(@"downloadVideo...", nil)];
        [[EMClient sharedClient].chatManager downloadMessageAttachment:aCell.model.message progress:nil completion:^(EMChatMessage *message, EMError *error) {
            [weakChatController hideHud];
            if (error) {
                [EaseAlertController showErrorAlert:@"下载视频失败"];
            } else {
                if (!message.isReadAcked) {
                    [[EMClient sharedClient].chatManager sendMessageReadAck:message.messageId toUser:message.conversationId completion:nil];
                }
                playBlock([(EMVideoMessageBody*)message.body localPath]);
            }
        }];
    };
    
    EMVideoMessageBody *body = (EMVideoMessageBody*)aCell.model.message.body;
    if (body.downloadStatus == EMDownloadStatusDownloading) {
        [EaseAlertController showInfoAlert:EaseLocalizableString(@"downloadingVideo...", nil)];
        return;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isCustomDownload = !([EMClient sharedClient].options.isAutoTransferMessageAttachments);
    if (body.thumbnailDownloadStatus == EMDownloadStatusFailed || ![fileManager fileExistsAtPath:body.thumbnailLocalPath]) {
        [self.chatController showHint:EaseLocalizableString(@"downloadThumnail", nil)];
        if (!isCustomDownload) {
            [[EMClient sharedClient].chatManager downloadMessageThumbnail:aCell.model.message progress:nil completion:^(EMChatMessage *message, EMError *error) {
                downloadBlock();
            }];
            return;
        }
    }
    
    if (body.downloadStatus == EMDownloadStatusSuccessed && [fileManager fileExistsAtPath:body.localPath]) {
        playBlock(body.localPath);
    } else {
        if (!isCustomDownload) {
            downloadBlock();
        }
    }
    
}

- (void)messageCell:(EMsgUserBaseCell *)cell selectedEventOperation:(EMsgBaseCellModel *)model{
    __weak typeof(self.chatController) weakChatController = self.chatController;
    void (^playBlock)(NSString *aPath) = ^(NSString *aPathe) {
        NSURL *videoURL = [NSURL fileURLWithPath:aPathe];
        AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
        playerViewController.player = [AVPlayer playerWithURL:videoURL];
        playerViewController.videoGravity = AVLayerVideoGravityResizeAspect;
        playerViewController.showsPlaybackControls = YES;
        playerViewController.modalPresentationStyle = 0;
        [weakChatController presentViewController:playerViewController animated:YES completion:^{
            [playerViewController.player play];
        }];
    };

    void (^downloadBlock)(void) = ^ {
        [weakChatController showHudInView:self.chatController.view hint:EaseLocalizableString(@"downloadVideo...", nil)];
        [[EMClient sharedClient].chatManager downloadMessageAttachment:model.message progress:nil completion:^(EMChatMessage *message, EMError *error) {
            [weakChatController hideHud];
            if (error) {
                [EaseAlertController showErrorAlert:@"下载视频失败"];
            } else {
                if (!message.isReadAcked) {
                    [[EMClient sharedClient].chatManager sendMessageReadAck:message.messageId toUser:message.conversationId completion:nil];
                }
                playBlock([(EMVideoMessageBody*)message.body localPath]);
            }
        }];
    };
    
    EMVideoMessageBody *body = (EMVideoMessageBody*)model.message.body;
    if (body.downloadStatus == EMDownloadStatusDownloading) {
        [EaseAlertController showInfoAlert:EaseLocalizableString(@"downloadingVideo...", nil)];
        return;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isCustomDownload = !([EMClient sharedClient].options.isAutoTransferMessageAttachments);
    if (body.thumbnailDownloadStatus == EMDownloadStatusFailed || ![fileManager fileExistsAtPath:body.thumbnailLocalPath]) {
        [self.chatController showHint:EaseLocalizableString(@"downloadThumnail", nil)];
        if (!isCustomDownload) {
            [[EMClient sharedClient].chatManager downloadMessageThumbnail:model.message progress:nil completion:^(EMChatMessage *message, EMError *error) {
                downloadBlock();
            }];
            return;
        }
    }
    
    if (body.downloadStatus == EMDownloadStatusSuccessed && [fileManager fileExistsAtPath:body.localPath]) {
        playBlock(body.localPath);
    } else {
        if (!isCustomDownload) {
            downloadBlock();
        }
    }
    
}


@end

/**
    文件消息事件
 */
@implementation FileMsgEvent

- (void)messageCellEventOperation:(EaseMessageCell *)aCell
{
    EMFileMessageBody *body = (EMFileMessageBody *)aCell.model.message.body;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (body.downloadStatus == EMDownloadStatusDownloading) {
        [EaseAlertController showInfoAlert:EaseLocalizableString(@"downloadingFile...", nil)];
        return;
    }
    __weak typeof(self.chatController) weakself = self.chatController;
    void (^checkFileBlock)(NSString *aPath) = ^(NSString *aPathe) {
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:aPathe];
        NSLog(@"\nfile  --    :%@",[fileHandle readDataToEndOfFile]);
        [fileHandle closeFile];
        UIDocumentInteractionController *docVc = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:aPathe]];
        docVc.delegate = weakself;
        [docVc presentPreviewAnimated:YES];
    };
    
    if (body.downloadStatus == EMDownloadStatusSuccessed && [fileManager fileExistsAtPath:body.localPath]) {
        checkFileBlock(body.localPath);
        return;
    }
    
    [[EMClient sharedClient].chatManager downloadMessageAttachment:aCell.model.message progress:nil completion:^(EMChatMessage *message, EMError *error) {
        [weakself hideHud];
        if (error) {
            [EaseAlertController showErrorAlert:EaseLocalizableString(@"downFileFail", nil)];
        } else {
            if (!message.isReadAcked) {
                [[EMClient sharedClient].chatManager sendMessageReadAck:message.messageId toUser:message.conversationId completion:nil];
            }
            checkFileBlock([(EMFileMessageBody*)message.body localPath]);
        }
    }];
}
- (void)messageCell:(EMsgUserBaseCell *)cell selectedEventOperation:(EMsgBaseCellModel *)model{
    EMFileMessageBody *body = (EMFileMessageBody *)model.message.body;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (body.downloadStatus == EMDownloadStatusDownloading) {
        [EaseAlertController showInfoAlert:EaseLocalizableString(@"downloadingFile...", nil)];
        return;
    }
    __weak typeof(self.chatController) weakself = self.chatController;
    void (^checkFileBlock)(NSString *aPath) = ^(NSString *aPathe) {
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:aPathe];
        NSLog(@"\nfile  --    :%@",[fileHandle readDataToEndOfFile]);
        [fileHandle closeFile];
        UIDocumentInteractionController *docVc = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:aPathe]];
        docVc.delegate = weakself;
        [docVc presentPreviewAnimated:YES];
    };
    
    if (body.downloadStatus == EMDownloadStatusSuccessed && [fileManager fileExistsAtPath:body.localPath]) {
        checkFileBlock(body.localPath);
        return;
    }
    
    [[EMClient sharedClient].chatManager downloadMessageAttachment:model.message progress:nil completion:^(EMChatMessage *message, EMError *error) {
        [weakself hideHud];
        if (error) {
            [EaseAlertController showErrorAlert:EaseLocalizableString(@"downFileFail", nil)];
        } else {
            if (!message.isReadAcked) {
                [[EMClient sharedClient].chatManager sendMessageReadAck:message.messageId toUser:message.conversationId completion:nil];
            }
            checkFileBlock([(EMFileMessageBody*)message.body localPath]);
        }
    }];
}


@end

/**
    会议消息事件
 */
@implementation ConferenceMsgEvent

- (void)messageCellEventOperation:(EaseMessageCell *)aCell
{
    [[NSNotificationCenter defaultCenter] postNotificationName:CALL_SELECTCONFERENCECELL object:aCell.model.message];
}

- (void)messageCell:(EMsgUserBaseCell *)cell selectedEventOperation:(EMsgBaseCellModel *)model{
    [[NSNotificationCenter defaultCenter] postNotificationName:CALL_SELECTCONFERENCECELL object:model.message];
}


@end
