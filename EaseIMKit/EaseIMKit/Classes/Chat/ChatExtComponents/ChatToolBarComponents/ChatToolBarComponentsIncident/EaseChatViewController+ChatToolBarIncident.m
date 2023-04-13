//
//  EaseChatViewController+ChatToolBarIncident.m
//  EaseIM
//
//  Created by 娜塔莎 on 2020/7/13.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import "EaseChatViewController+ChatToolBarIncident.h"
#import <objc/runtime.h>
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "EMLocationViewController.h"
#import "EaseAlertController.h"
#import "EaseAlertView.h"
#import "UIViewController+HUD.h"

/**
    媒体库
 */
static const void *imagePickerKey = &imagePickerKey;
@implementation EaseChatViewController (ChatToolBarMeida)

@dynamic imagePicker;

- (void)chatToolBarComponentIncidentAction:(EMChatToolBarComponentType)componentType
{
    [self.view endEditing:YES];
    [self setterImagePicker];

    if (componentType == EMChatToolBarCamera) {
        #if TARGET_IPHONE_SIMULATOR
            [EaseAlertController showErrorAlert:EaseLocalizableString(@"simUnsupportCamera", nil)];
        #elif TARGET_OS_IPHONE
            AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied) {
                [EaseAlertController showErrorAlert:EaseLocalizableString(@"cameraPermissionDisabled", nil)];
                return;
            }
            __weak typeof(self) weakself = self;
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakself.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                        weakself.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
                        [weakself presentViewController:self.imagePicker animated:YES completion:nil];
                    });
                }
            }];
        #endif
        
        return;
    }
    PHAuthorizationStatus permissions = -1;
    if (@available(iOS 14, *)) {
        permissions = PHAuthorizationStatusLimited;
    }
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (status == permissions) {
                //limit权限
                self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
                [self presentViewController:self.imagePicker animated:YES completion:nil];
            }
            if (status == PHAuthorizationStatusAuthorized) {
                //已获取权限
                self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
                [self presentViewController:self.imagePicker animated:YES completion:nil];
            }
            if (status == PHAuthorizationStatusDenied) {
                //用户已经明确否认了这一照片数据的应用程序访问
                [EaseAlertController showErrorAlert:EaseLocalizableString(@"photoPermissionDisabled", nil)];
            }
            if (status == PHAuthorizationStatusRestricted) {
                //此应用程序没有被授权访问的照片数据。可能是家长控制权限
                [EaseAlertController showErrorAlert:EaseLocalizableString(@"fetchPhotoPermissionFail", nil)];
            }
        });
    }];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        NSURL *videoURL = info[UIImagePickerControllerMediaURL];
        // we will convert it to mp4 format
        NSURL *mp4 = [self _videoConvert2Mp4:videoURL];
        NSFileManager *fileman = [NSFileManager defaultManager];
        if ([fileman fileExistsAtPath:videoURL.path]) {
            NSError *error = nil;
            [fileman removeItemAtURL:videoURL error:&error];
            if (error) {
                NSLog(@"failed to remove file, error:%@.", error);
            }
        }
        [self _sendVideoAction:mp4];
    } else {
        PHFetchResult *fetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
        PHAssetCollection *collection = fetchResult.firstObject;
        PHFetchResult *assetResult = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
        PHAsset *asset = assetResult.firstObject;
        NSString *localIdentifier = asset.localIdentifier;
        PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil];
        if(result.count == 0){
            [EaseAlertController showErrorAlert:@"无权访问该相册"];
        } else {
            UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
            NSData *data = UIImageJPEGRepresentation(orgImage, 1);
            [self _sendImageDataAction:data];
        }
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
    
    //    self.isViewDidAppear = YES;
    //    [[EaseSDKHelper shareHelper] setIsShowingimagePicker:NO];
}

- (NSURL *)_videoConvert2Mp4:(NSURL *)movUrl
{
    NSURL *mp4Url = nil;
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:movUrl options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset presetName:AVAssetExportPresetHighestQuality];
        NSString *mp4Path = [NSString stringWithFormat:@"%@/%d%d.mp4", [self getAudioOrVideoPath], (int)[[NSDate date] timeIntervalSince1970], arc4random() % 100000];
        mp4Url = [NSURL fileURLWithPath:mp4Path];
        exportSession.outputURL = mp4Url;
        exportSession.shouldOptimizeForNetworkUse = YES;
        exportSession.outputFileType = AVFileTypeMPEG4;
        dispatch_semaphore_t wait = dispatch_semaphore_create(0l);
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed: {
                    NSLog(@"failed, error:%@.", exportSession.error);
                } break;
                case AVAssetExportSessionStatusCancelled: {
                    NSLog(@"cancelled.");
                } break;
                case AVAssetExportSessionStatusCompleted: {
                    NSLog(@"completed.");
                } break;
                default: {
                    NSLog(@"others.");
                } break;
            }
            dispatch_semaphore_signal(wait);
        }];
        long timeout = dispatch_semaphore_wait(wait, DISPATCH_TIME_FOREVER);
        if (timeout) {
            NSLog(@"timeout.");
        }
        
        if (wait) {
            //dispatch_release(wait);
            wait = nil;
        }
    }
    
    return mp4Url;
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

#pragma mark - Action

- (void)_sendImageDataAction:(NSData *)aImageData
{
    EMImageMessageBody *body = [[EMImageMessageBody alloc] initWithData:aImageData displayName:@"image"];
//    body.compressionRatio = 1;
    [self sendMessageWithBody:body ext:nil];
}
- (void)_sendVideoAction:(NSURL *)aUrl
{
    /*
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:aUrl options:nil];
    int second = urlAsset.duration.value / urlAsset.duration.timescale;*/
    EMVideoMessageBody *body = [[EMVideoMessageBody alloc] initWithLocalPath:[aUrl path] displayName:@"video.mp4"];
    //body.duration = second;
    [self sendMessageWithBody:body ext:nil];
}

#pragma mark - Getter

- (void)setterImagePicker
{
    if (self.imagePicker == nil) {
        self.imagePicker = [[UIImagePickerController alloc] init];
        self.imagePicker.modalPresentationStyle = UIModalPresentationOverFullScreen;
        self.imagePicker.delegate = self;
    }
}

- (UIImagePickerController *)imagePicker
{
    return objc_getAssociatedObject(self, imagePickerKey);
}

- (void)setImagePicker:(UIImagePickerController *)imagePicker
{
    objc_setAssociatedObject(self, imagePickerKey, imagePicker, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

/**
    位置消息
 */

@implementation EaseChatViewController (ChatToolBarLocation)

- (void)chatToolBarLocationAction
{
    if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
        EMLocationViewController *controller = [[EMLocationViewController alloc] init];
        __weak typeof(self) weakself = self;
        [controller setSendCompletion:^(CLLocationCoordinate2D aCoordinate, NSString * _Nonnull aAddress, NSString * _Nonnull aBuildingName) {
            [weakself _sendLocationAction:aCoordinate address:aAddress buildingName:aBuildingName];
        }];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
        navController.modalPresentationStyle = 0;
        [self.navigationController presentViewController:navController animated:YES completion:nil];
    } else {
        [EaseAlertController showErrorAlert:EaseLocalizableString(@"LocationPermissionDisabled", nil)];
    }
}

- (void)_sendLocationAction:(CLLocationCoordinate2D)aCoord
                    address:(NSString *)aAddress
               buildingName:(NSString *)aBuildingName
{
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
        EMLocationMessageBody *body = [[EMLocationMessageBody alloc] initWithLatitude:aCoord.latitude longitude:aCoord.longitude address:aAddress buildingName:aBuildingName];
        
        [self sendMessageWithBody:body ext:nil];
    } else {
        [EaseAlertController showErrorAlert:EaseLocalizableString(@"getLocaionPermissionFail", nil)];
    }
}

@end


/**
    选择文件
 */

@implementation EaseChatViewController (ChatToolBarFileOpen)

- (void)chatToolBarFileOpenAction
{
    NSArray *documentTypes = @[@"public.content", @"public.text", @"public.source-code", @"public.image", @"public.jpeg", @"public.png", @"com.adobe.pdf", @"com.apple.keynote.key", @"com.microsoft.word.doc", @"com.microsoft.excel.xls", @"com.microsoft.powerpoint.ppt"];
    UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:documentTypes inMode:UIDocumentPickerModeOpen];
    picker.delegate = self;
    picker.modalPresentationStyle = 0;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UIDocumentPickerDelegate
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray <NSURL *>*)urls
{
    BOOL fileAuthorized = [urls.firstObject startAccessingSecurityScopedResource];
    if (fileAuthorized) {
        [self selectedDocumentAtURLs:urls reName:nil];
        [urls.firstObject stopAccessingSecurityScopedResource];
        return;
    }
    [self showHint:EaseLocalizableString(@"getPermissionfail", nil)];
}
- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url
{
    BOOL fileAuthorized = [url startAccessingSecurityScopedResource];
    if (fileAuthorized) {
        [self selectedDocumentAtURLs:@[url] reName:nil];
        [url stopAccessingSecurityScopedResource];
        return;
    }
    [self showHint:EaseLocalizableString(@"getPermissionfail", nil)];
}

//icloud
- (void)selectedDocumentAtURLs:(NSArray <NSURL *>*)urls reName:(NSString *)rename
{
    NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc]init];
    for (NSURL *url in urls) {
        NSError *error;
        [fileCoordinator coordinateReadingItemAtURL:url options:0 error:&error byAccessor:^(NSURL * _Nonnull newURL) {
            //读取文件
            NSString *fileName = [newURL lastPathComponent];
            NSError *error = nil;
            NSData *fileData = [NSData dataWithContentsOfURL:newURL options:NSDataReadingMappedIfSafe error:&error];
            if (error) {
                [self showHint:EaseLocalizableString(@"fileOpenFail", nil)];
                return;
            }
            NSLog(@"fileName: %@\nfileUrl: %@", fileName, newURL);
            EMFileMessageBody *body = [[EMFileMessageBody alloc]initWithData:fileData displayName:fileName];
            [self sendMessageWithBody:body ext:nil];
        }];
    }
}

@end
