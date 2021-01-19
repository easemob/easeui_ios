//
//  EaseChatViewController+ChatToolBarIncident.h
//  EaseIM
//
//  Created by 娜塔莎 on 2020/7/13.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import "EaseChatViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, EMChatToolBarComponentType) {
    EMChatToolBarPhotoAlbum = 0,
    EMChatToolBarCamera,
    EMChatToolBarLocation,
    EMChatToolBarFileOpen,
};

@interface EaseChatViewController (ChatToolBarMeida) <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UIImagePickerController *imagePicker;

- (NSString *)getAudioOrVideoPath;

- (void)chatToolBarComponentIncidentAction:(EMChatToolBarComponentType)componentType;
@end

@interface EaseChatViewController (ChatToolBarLocation)

- (void)chatToolBarLocationAction;
@end

@interface EaseChatViewController (ChatToolBarFileOpen) <UIDocumentPickerDelegate>

- (void)chatToolBarFileOpenAction;
@end

NS_ASSUME_NONNULL_END
