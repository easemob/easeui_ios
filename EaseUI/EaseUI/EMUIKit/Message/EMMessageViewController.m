//
//  EMMessageViewController.m
//  ChatDemo-UI3.0
//
//  Created by dhc on 15/6/26.
//  Copyright (c) 2015年 easemob.com. All rights reserved.
//

#import "EMMessageViewController.h"

#import "NSObject+EaseMob.h"
#import "NSDate+Category.h"

@interface EMMessageViewController ()<EMMessageCellDelegate>
{
    UILongPressGestureRecognizer *_lpgr;
}

@property (strong, nonatomic) id<IMessageModel> playingVoiceModel;
@property (strong, nonatomic) NSIndexPath *menuIndexPath;

@end

@implementation EMMessageViewController

@synthesize conversation = _conversation;
@synthesize deleteConversationIfNull = _deleteConversationIfNull;
@synthesize messageCountOfPage = _messageCountOfPage;
@synthesize timeCellHeight = _timeCellHeight;
@synthesize messageTimeIntervalTag = _messageTimeIntervalTag;

- (instancetype)initWithConversationChatter:(NSString *)conversationChatter
                           conversationType:(EMConversationType)conversationType
{
    if ([conversationChatter length] == 0) {
        return nil;
    }
    
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:conversationChatter conversationType:conversationType];
        
        _messageCountOfPage = 5;
        _timeCellHeight = 30;
        _deleteConversationIfNull = YES;
        _scrollToBottomWhenAppear = YES;
        _messsagesSource = [NSMutableArray array];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:248 / 255.0 green:248 / 255.0 blue:248 / 255.0 alpha:1.0];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //将所有消息置为已读
    [_conversation markAllMessagesAsRead:YES];
    
    //初始化页面
    CGFloat chatbarHeight = [EMChatToolbar defaultHeight];
    EMChatToolbarType barType = self.conversation.conversationType == eConversationTypeChat ? EMChatToolbarTypeChat : EMChatToolbarTypeGroup;
    self.chatToolbar = [[EMChatToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - chatbarHeight, self.view.frame.size.width, chatbarHeight) type:barType];
    [(EMChatToolbar *)self.chatToolbar setDelegate:self];
    self.chatBarMoreView = (EMChatBarMoreView*)[(EMChatToolbar *)self.chatToolbar moreView];
    self.faceView = (EMFaceView*)[(EMChatToolbar *)self.chatToolbar faceView];
    self.recordView = (EMRecordView*)[(EMChatToolbar *)self.chatToolbar recordView];
    self.chatToolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;    
    
    //初始化手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyBoardHidden:)];
    [self.view addGestureRecognizer:tap];
    
    _lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    _lpgr.minimumPressDuration = 0.5;
    [self.tableView addGestureRecognizer:_lpgr];
    
    //注册代理
    [EMCDDeviceManager sharedInstance].delegate = self;
    [self registerEaseMobNotification];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[EMCDDeviceManager sharedInstance] stopPlaying];
    [EMCDDeviceManager sharedInstance].delegate = nil;
    [self unregisterEaseMobNotification];
    
    if (_imagePicker){
        [_imagePicker dismissViewControllerAnimated:NO completion:nil];
        _imagePicker = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.isViewDidAppear = YES;
    [[EMSDKHelper shareHelper] setIsShowingimagePicker:NO];
    
    if (self.scrollToBottomWhenAppear) {
        [self _scrollViewToBottom:NO];
    }
    self.scrollToBottomWhenAppear = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.isViewDidAppear = NO;
}

#pragma mark - getter

- (UIMenuController *)menuController
{
    if(_menuController == nil)
    {
        _menuController = [UIMenuController sharedMenuController];
        
        UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"delete", @"Delete") action:@selector(deleteMenuAction:)];
        [_menuController setMenuItems:@[deleteItem]];
    }
    
    return _menuController;
}

- (UIImagePickerController *)imagePicker
{
    if (_imagePicker == nil) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.modalPresentationStyle= UIModalPresentationOverFullScreen;
        _imagePicker.delegate = self;
    }
    
    return _imagePicker;
}

#pragma mark - setter

- (void)setChatToolbar:(EMChatToolbar *)chatToolbar
{
    [_chatToolbar removeFromSuperview];
    
    _chatToolbar = chatToolbar;
    if (_chatToolbar) {
        [self.view addSubview:_chatToolbar];
    }
    
    CGRect tableFrame = self.tableView.frame;
    tableFrame.size.height = self.view.frame.size.height - _chatToolbar.frame.size.height;
    self.tableView.frame = tableFrame;
}

#pragma mark - private helper

- (void)_scrollViewToBottom:(BOOL)animated
{
    if (self.tableView.contentSize.height > self.tableView.frame.size.height)
    {
        CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
        [self.tableView setContentOffset:offset animated:animated];
    }
}

- (BOOL)_canRecord
{
    __block BOOL bCanRecord = YES;
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)
    {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                bCanRecord = granted;
            }];
        }
    }
    
    return bCanRecord;
}

- (void)_showMenuViewController:(UIView *)showInView
                   andIndexPath:(NSIndexPath *)indexPath
                    messageType:(MessageBodyType)messageType
{
    _menuController = [UIMenuController sharedMenuController];
    
    UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"delete", @"Delete") action:@selector(deleteMenuAction:)];
    [_menuController setMenuItems:@[deleteItem]];
    
    [_menuController setTargetRect:showInView.frame inView:showInView.superview];
    [_menuController setMenuVisible:YES animated:YES];
}

- (void)_stopAudioPlayingWithChangeCategory:(BOOL)isChange
{
    //停止音频播放及播放动画
    [[EMCDDeviceManager sharedInstance] stopPlaying];
    [[EMCDDeviceManager sharedInstance] disableProximitySensor];
    [EMCDDeviceManager sharedInstance].delegate = nil;
    
    //    MessageModel *playingModel = [self.messageReadManager stopMessageAudioModel];
    //    NSIndexPath *indexPath = nil;
    //    if (playingModel) {
    //        indexPath = [NSIndexPath indexPathForRow:[self.dataSource indexOfObject:playingModel] inSection:0];
    //    }
    //
    //    if (indexPath) {
    //        dispatch_async(dispatch_get_main_queue(), ^{
    //            [self.tableView beginUpdates];
    //            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    //            [self.tableView endUpdates];
    //        });
    //    }
}

- (NSURL *)_convert2Mp4:(NSURL *)movUrl
{
    NSURL *mp4Url = nil;
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:movUrl options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset
                                                                              presetName:AVAssetExportPresetHighestQuality];
        mp4Url = [movUrl copy];
        mp4Url = [mp4Url URLByDeletingPathExtension];
        mp4Url = [mp4Url URLByAppendingPathExtension:@"mp4"];
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

- (EMMessageType)_messageTypeFromConversationType
{
    EMMessageType type = eMessageTypeChat;
    switch (self.conversation.conversationType) {
        case eConversationTypeChat:
            type = eMessageTypeChat;
            break;
        case eConversationTypeGroupChat:
            type = eMessageTypeGroupChat;
            break;
        case eConversationTypeChatRoom:
            type = eMessageTypeChatRoom;
            break;
        default:
            break;
    }
    return type;
}

- (void)_downloadMessageAttachments:(EMMessage *)message
{
    __weak typeof(self) weakSelf = self;
    void (^completion)(EMMessage *aMessage, EMError *error) = ^(EMMessage *aMessage, EMError *error) {
        if (!error)
        {
            //            [weakSelf reloadTableViewDataWithMessage:message];
        }
        else
        {
            [weakSelf showHint:NSLocalizedString(@"message.thumImageFail", @"thumbnail for failure!")];
        }
    };
    
    id<IEMMessageBody> messageBody = [message.messageBodies firstObject];
    if ([messageBody messageBodyType] == eMessageBodyType_Image) {
        EMImageMessageBody *imageBody = (EMImageMessageBody *)messageBody;
        if (imageBody.thumbnailDownloadStatus > EMAttachmentDownloadSuccessed)
        {
            //下载缩略图
            [[[EaseMob sharedInstance] chatManager] asyncFetchMessageThumbnail:message progress:nil completion:completion onQueue:nil];
        }
    }
    else if ([messageBody messageBodyType] == eMessageBodyType_Video)
    {
        EMVideoMessageBody *videoBody = (EMVideoMessageBody *)messageBody;
        if (videoBody.thumbnailDownloadStatus > EMAttachmentDownloadSuccessed)
        {
            //下载缩略图
            [[[EaseMob sharedInstance] chatManager] asyncFetchMessageThumbnail:message progress:nil completion:completion onQueue:nil];
        }
    }
    else if ([messageBody messageBodyType] == eMessageBodyType_Voice)
    {
        EMVoiceMessageBody *voiceBody = (EMVoiceMessageBody*)messageBody;
        if (voiceBody.attachmentDownloadStatus > EMAttachmentDownloadSuccessed)
        {
            //下载语言
            [[EaseMob sharedInstance].chatManager asyncFetchMessage:message progress:nil];
        }
    }
}

- (BOOL)_shouldSendHasReadAckForMessage:(EMMessage *)message
                                   read:(BOOL)read
{
    NSString *account = [[EaseMob sharedInstance].chatManager loginInfo][kSDKUsername];
    if (message.messageType != eMessageTypeChat || message.isReadAcked || [account isEqualToString:message.from] || ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) || !self.isViewDidAppear)
    {
        return NO;
    }
    
    id<IEMMessageBody> body = [message.messageBodies firstObject];
    if (((body.messageBodyType == eMessageBodyType_Video) ||
         (body.messageBodyType == eMessageBodyType_Voice) ||
         (body.messageBodyType == eMessageBodyType_Image)) &&
        !read)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}


- (void)_sendHasReadResponseForMessages:(NSArray*)messages
                                 isRead:(BOOL)isRead
{
    NSMutableArray *unreadMessages = [NSMutableArray array];
    for (NSInteger i = 0; i < [messages count]; i++)
    {
        EMMessage *message = messages[i];
        BOOL isSend = YES;
        if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:shouldSendHasReadAckForMessage:read:)]) {
            isSend = [_dataSource messageViewController:self
                         shouldSendHasReadAckForMessage:message read:NO];
        }
        else{
            isSend = [self _shouldSendHasReadAckForMessage:message
                                                      read:isRead];
        }
        
        if (isSend)
        {
            [unreadMessages addObject:message];
        }
    }
    
    if ([unreadMessages count])
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (EMMessage *message in messages)
            {
                [[EaseMob sharedInstance].chatManager sendReadAckForMessage:message];
            }
        });
    }
}

- (BOOL)_shouldMarkMessageAsRead
{
    BOOL isMark = YES;
    if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewControllerShouldMarkMessagesAsRead:)]) {
        isMark = [_dataSource messageViewControllerShouldMarkMessagesAsRead:self];
    }
    else{
        if (([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) || !self.isViewDidAppear)
        {
            isMark = NO;
        }
    }
    
    return isMark;
}

#pragma mark - pivate data

- (void)_loadMessagesBefore:(long long)timestamp
                      count:(NSInteger)count
                     append:(BOOL)isAppend
{
    NSArray *moreMessages = nil;
    if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:loadMessageFromTimestamp:count:)]) {
        moreMessages = [_dataSource messageViewController:self loadMessageFromTimestamp:timestamp count:count];
    }
    else{
        moreMessages = [self.conversation loadNumbersOfMessages:count before:timestamp];;
    }
    
    if ([moreMessages count] == 0) {
        return;
    }
    
    //格式化消息
    NSArray *formattedMessages = [self formatMessages:moreMessages];
    
    NSInteger scrollToIndex = 0;
    if (isAppend) {
        [self.messsagesSource insertObjects:moreMessages atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [moreMessages count])]];
        
        //合并消息
        id object = [self.dataArray firstObject];
        if ([object isKindOfClass:[NSString class]])
        {
            NSString *timestamp = object;
            [formattedMessages enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id model, NSUInteger idx, BOOL *stop) {
                if ([model isKindOfClass:[NSString class]] && [timestamp isEqualToString:model])
                {
                    [self.dataArray removeObjectAtIndex:0];
                    *stop = YES;
                }
            }];
        }
        scrollToIndex = [self.dataArray count];
        [self.dataArray insertObjects:formattedMessages atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [formattedMessages count])]];
    }
    else{
        [self.messsagesSource removeAllObjects];
        [self.messsagesSource addObjectsFromArray:moreMessages];
        
        [self.dataArray removeAllObjects];
        [self.dataArray addObjectsFromArray:formattedMessages];
    }
    
    EMMessage *latest = [self.messsagesSource lastObject];
    self.messageTimeIntervalTag = latest.timestamp;
    
    //刷新页面
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.dataArray count] - scrollToIndex - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    });
    
    //从数据库导入时重新下载没有下载成功的附件
    for (EMMessage *message in moreMessages)
    {
        [self _downloadMessageAttachments:message];
    }
    
    //发送已读回执
    [self _sendHasReadResponseForMessages:moreMessages
                                   isRead:NO];
}

#pragma mark - GestureRecognizer

// 点击背景隐藏
-(void)keyBoardHidden:(UITapGestureRecognizer *)tapRecognizer
{
    if (tapRecognizer.state == UIGestureRecognizerStateEnded) {
        [self.chatToolbar endEditing:YES];
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan && [self.dataArray count] > 0)
    {
        CGPoint location = [recognizer locationInView:self.tableView];
        NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:location];
        BOOL canLongPress = NO;
        if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:canLongPressRowAtIndexPath:)]) {
            canLongPress = [_dataSource messageViewController:self
                                   canLongPressRowAtIndexPath:indexPath];
        }
        
        if (!canLongPress) {
            return;
        }
        
        if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:didLongPressRowAtIndexPath:)]) {
            [_dataSource messageViewController:self
                    didLongPressRowAtIndexPath:indexPath];
        }
        else{
            id object = [self.dataArray objectAtIndex:indexPath.row];
            if (![object isKindOfClass:[NSString class]]) {
                EMMessageCell *cell = (EMMessageCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                
                _menuIndexPath = indexPath;
                [self _showMenuViewController:cell andIndexPath:indexPath messageType:cell.model.bodyType];
            }
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [self.dataArray objectAtIndex:indexPath.row];
    
    //时间cell
    if ([object isKindOfClass:[NSString class]]) {
        NSString *TimeCellIdentifier = [EMMessageTimeCell cellIdentifier];
        EMMessageTimeCell *timeCell = (EMMessageTimeCell *)[tableView dequeueReusableCellWithIdentifier:TimeCellIdentifier];
        
        if (timeCell == nil) {
            timeCell = [[EMMessageTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TimeCellIdentifier];
            timeCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        timeCell.title = object;
        return timeCell;
    }
    else{
        id<IMessageModel> model = object;
        if (_delegate && [_delegate respondsToSelector:@selector(messageViewController:cellForMessageModel:)]) {
            UITableViewCell *cell = [_delegate messageViewController:tableView cellForMessageModel:model];
            if (cell) {
                if ([cell isKindOfClass:[EMMessageCell class]]) {
                    EMMessageCell *emcell= (EMMessageCell*)cell;
                    if (emcell.delegate == nil) {
                        emcell.delegate = self;
                    }
                }
                return cell;
            }
        }
        
        NSString *CellIdentifier = [EMMessageCell cellIdentifierWithModel:model];
        
        EMSendMessageCell *sendCell = (EMSendMessageCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        // Configure the cell...
        if (sendCell == nil) {
            sendCell = [[EMSendMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier model:model];
            sendCell.selectionStyle = UITableViewCellSelectionStyleNone;
            sendCell.delegate = self;
        }
        
        sendCell.model = model;
        return sendCell;
        /*
        //发送cell
        if (model.isSender) {
            EMSendMessageCell *sendCell = (EMSendMessageCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            // Configure the cell...
            if (sendCell == nil) {
                sendCell = [[EMSendMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier model:model];
                sendCell.selectionStyle = UITableViewCellSelectionStyleNone;
                sendCell.delegate = self;
            }
            
            sendCell.model = model;
            return sendCell;
        }
        else{//接收cell
            EMRecvMessageCell *recvCell = (EMRecvMessageCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            // Configure the cell...
            if (recvCell == nil) {
                recvCell = [[EMRecvMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier model:model];
                recvCell.selectionStyle = UITableViewCellSelectionStyleNone;
                recvCell.delegate = self;
            }
            
            recvCell.model = model;
            return recvCell;
        }*/
    }
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [self.dataArray objectAtIndex:indexPath.row];
    if ([object isKindOfClass:[NSString class]]) {
        return self.timeCellHeight;
    }
    else{
        id<IMessageModel> model = object;
        if (_delegate && [_delegate respondsToSelector:@selector(messageViewController:heightForMessageModel:withCellWidth:)]) {
            CGFloat height = [_delegate messageViewController:self heightForMessageModel:model withCellWidth:tableView.frame.size.width];
            if (height) {
                return height;
            }
        }
        
        if (model.isSender) {
            return [EMSendMessageCell cellHeightWithModel:model];
        }
        else{
            return [EMRecvMessageCell cellHeightWithModel:model];
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        NSURL *videoURL = info[UIImagePickerControllerMediaURL];
        // video url:
        // file:///private/var/mobile/Applications/B3CDD0B2-2F19-432B-9CFA-158700F4DE8F/tmp/capture-T0x16e39100.tmp.9R8weF/capturedvideo.mp4
        // we will convert it to mp4 format
        NSURL *mp4 = [self _convert2Mp4:videoURL];
        NSFileManager *fileman = [NSFileManager defaultManager];
        if ([fileman fileExistsAtPath:videoURL.path]) {
            NSError *error = nil;
            [fileman removeItemAtURL:videoURL error:&error];
            if (error) {
                NSLog(@"failed to remove file, error:%@.", error);
            }
        }
        [self sendVideoMessageWithURL:mp4];
        
    }else{
        UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
        [self sendImageMessage:orgImage];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    self.isViewDidAppear = YES;
    [[EMSDKHelper shareHelper] setIsShowingimagePicker:NO];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
    
    self.isViewDidAppear = YES;
    [[EMSDKHelper shareHelper] setIsShowingimagePicker:NO];
}

#pragma mark - EMMessageCellDelegate

- (void)messageCellSelected:(id<IMessageModel>)model withEventName:(NSString *)eventName
{
    if (_delegate && [_delegate respondsToSelector:@selector(messageViewController:didSelectMessageModel:withEventName:)]) {
        [_delegate messageViewController:self didSelectMessageModel:model withEventName:eventName];
        return;
    }
    
    if ([eventName isEqualToString:kRouterEventImageBubbleTapEventName]) {
        _scrollToBottomWhenAppear = NO;
        [self showHint:@"Custom implementation!"];
    } else if ([eventName isEqualToString:kRouterEventLocationBubbleTapEventName]) {
        [self _locationMessageCellSelected:model];
    } else if ([eventName isEqualToString:kRouterEventAudioBubbleTapEventName]) {
        [self _audioMessageCellSelected:model];
    } else if ([eventName isEqualToString:kRouterEventChatCellVideoTapEventName]) {
        [self _videoMessageCellSelected:model];
    } else if ([eventName isEqualToString:kRouterEventFileBubbleTapEventName]) {
        _scrollToBottomWhenAppear = NO;
        [self showHint:@"Custom implementation!"];
    }
}

- (void)_locationMessageCellSelected:(id<IMessageModel>)model
{
    _scrollToBottomWhenAppear = NO;
    
    EMLocationViewController *locationController = [[EMLocationViewController alloc] initWithLocation:CLLocationCoordinate2DMake(model.latitude, model.longitude)];
    [self.navigationController pushViewController:locationController animated:YES];
}

- (void)_videoMessageCellSelected:(id<IMessageModel>)model
{
    _scrollToBottomWhenAppear = NO;
    
    EMVideoMessageBody *videoBody = (EMVideoMessageBody*)[model.message.messageBodies firstObject];
    
    //判断本地路劲是否存在
    NSString *localPath = [model.fileLocalPath length] > 0 ? model.fileLocalPath : videoBody.localPath;
    if ([localPath length] == 0) {
        [self showHint:NSLocalizedString(@"message.videoFail", @"video for failure!")];
        return;
    }
    
    dispatch_block_t block = ^{
        //发送已读回执
        [self _sendHasReadResponseForMessages:@[model.message]
                                       isRead:YES];
        
        NSURL *videoURL = [NSURL fileURLWithPath:localPath];
        MPMoviePlayerViewController *moviePlayerController = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
        [moviePlayerController.moviePlayer prepareToPlay];
        moviePlayerController.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
        [self presentMoviePlayerViewControllerAnimated:moviePlayerController];
    };
    
    if (videoBody.attachmentDownloadStatus == EMAttachmentDownloadSuccessed)
    {
        block();
        return;
    }
    
    [self showHudInView:self.view hint:NSLocalizedString(@"message.downloadingVideo", @"downloading video...")];
    __weak EMMessageViewController *weakSelf = self;
    id<IChatManager> chatManager = [[EaseMob sharedInstance] chatManager];
    [chatManager asyncFetchMessage:model.message progress:nil completion:^(EMMessage *aMessage, EMError *error) {
        [weakSelf hideHud];
        if (!error) {
            block();
        }else{
            [weakSelf showHint:NSLocalizedString(@"message.videoFail", @"video for failure!")];
        }
    } onQueue:nil];
}

- (void)_audioMessageCellSelected:(id<IMessageModel>)model
{
    _scrollToBottomWhenAppear = NO;
    
    //如果存在正在播放的语音，停止播放
    if (self.playingVoiceModel){
        [[EMCDDeviceManager sharedInstance] stopPlaying];
    }
    self.playingVoiceModel = nil;
    
    //如果是要停止播放
    if (!model.isMediaPlaying) {
        [[EMCDDeviceManager sharedInstance] disableProximitySensor];
        
        return;
    }
    
    //判断语音是否已经下载下来了
    EMVoiceMessageBody *voiceBody = [model.message.messageBodies firstObject];
    EMAttachmentDownloadStatus downloadStatus = [voiceBody attachmentDownloadStatus];
    //正在下载，不进行任何处理
    if (downloadStatus == EMAttachmentDownloading) {
        [self showHint:NSLocalizedString(@"message.downloadingAudio", @"downloading voice, click later")];
        return;
    }//下载失败，进行异步下载操作，直接返回
    else if (downloadStatus == EMAttachmentDownloadFailure)
    {
        [self showHint:NSLocalizedString(@"message.downloadingAudio", @"downloading voice, click later")];
        [[EaseMob sharedInstance].chatManager asyncFetchMessage:model.message progress:nil];
        
        return;
    }
    
    //判断本地路劲是否存在
    NSString *localPath = [model.fileLocalPath length] > 0 ? model.fileLocalPath : voiceBody.localPath;
    if ([localPath length] == 0) {
        [self showHint:NSLocalizedString(@"message.audioFail", @"audio failed!")];
        return;
    }
    
    // 播放音频
    if (model.bodyType == eMessageBodyType_Voice)
    {
        self.playingVoiceModel = model;
        __weak EMMessageViewController *weakSelf = self;
        [[EMCDDeviceManager sharedInstance] enableProximitySensor];
        [[EMCDDeviceManager sharedInstance] asyncPlayingWithPath:localPath completion:^(NSError *error) {
            weakSelf.playingVoiceModel.isMediaPlaying = NO;
            weakSelf.playingVoiceModel = nil;
            [weakSelf.tableView reloadData];
            [[EMCDDeviceManager sharedInstance] disableProximitySensor];
        }];
        
        //发送已读回执
        [self _sendHasReadResponseForMessages:@[model.message]
                                       isRead:YES];
        
        //更新message.ext中是否已播放字段
        model.isMediaPlayed = YES;
        if (![[model.message.ext objectForKey:@"isPlayed"] boolValue]) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:model.message.ext];
            [dic setObject:@YES forKey:@"isPlayed"];
            model.message.ext = dic;
            [model.message updateMessageExtToDB];
        }
    }
}

/*
- (void)imageMessageCellSelcted:(id<IMessageModel>)model
{
    if (_delegate && [_delegate respondsToSelector:@selector(messageViewController:didSelectImageMessageModel:)]) {
        [_delegate messageViewController:self didSelectImageMessageModel:model];
        return;
    }
    
    _scrollToBottomWhenAppear = NO;

}

- (void)locationMessageCellSelcted:(id<IMessageModel>)model
{
    if (_delegate && [_delegate respondsToSelector:@selector(messageViewController:didSelectLocationMessageModel:)]) {
        [_delegate messageViewController:self didSelectLocationMessageModel:model];
        
        return;
    }
    
    _scrollToBottomWhenAppear = NO;
    
    EMLocationViewController *locationController = [[EMLocationViewController alloc] initWithLocation:CLLocationCoordinate2DMake(model.latitude, model.longitude)];
    [self.navigationController pushViewController:locationController animated:YES];
}

- (void)voiceMessageCellSelcted:(id<IMessageModel>)model
{
    if (_delegate && [_delegate respondsToSelector:@selector(messageViewController:didSelectVoiceMessageModel:)]) {
        [_delegate messageViewController:self didSelectVoiceMessageModel:model];
        
        return;
    }
}

- (void)videoMessageCellSelcted:(id<IMessageModel>)model
{
    if (_delegate && [_delegate respondsToSelector:@selector(messageViewController:didSelectVideoMessageModel:)]) {
        [_delegate messageViewController:self didSelectVideoMessageModel:model];
        
        return;
    }
}

- (void)fileMessageCellSelcted:(id<IMessageModel>)model
{
    if (_delegate && [_delegate respondsToSelector:@selector(messageViewController:didSelectFileMessageModel:)]) {
        [_delegate messageViewController:self didSelectFileMessageModel:model];
        
        return;
    }
    
    _scrollToBottomWhenAppear = NO;
    
    [self showHint:@"Custom implementation!"];
}
*/

- (void)statusButtonSelcted:(id<IMessageModel>)model withMessageCell:(EMMessageCell*)messageCell
{
    if ((model.messageStatus != eMessageDeliveryState_Failure) && (model.messageStatus != eMessageDeliveryState_Pending))
    {
        return;
    }
    id <IChatManager> chatManager = [[EaseMob sharedInstance] chatManager];
    [chatManager asyncResendMessage:model.message progress:nil];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:messageCell];
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

- (void)avatarViewSelcted:(id<IMessageModel>)model
{
    if (_delegate && [_delegate respondsToSelector:@selector(messageViewController:didSelectAvatarMessageModel:)]) {
        [_delegate messageViewController:self didSelectAvatarMessageModel:model];
        
        return;
    }
    
    _scrollToBottomWhenAppear = NO;
}

#pragma mark - EMChatToolbarDelegate

- (void)chatToolbarDidChangeFrameToHeight:(CGFloat)toHeight
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = self.tableView.frame;
        rect.origin.y = 0;
        rect.size.height = self.view.frame.size.height - toHeight;
        self.tableView.frame = rect;
    }];
    
    [self _scrollViewToBottom:NO];
}

- (void)inputTextViewWillBeginEditing:(DXTextView *)inputTextView
{
//    [self.menuController setMenuItems:nil];
}

- (void)didSendText:(NSString *)text
{
    if (text && text.length > 0) {
        [self sendTextMessage:text withExt:nil];
    }
}

- (void)didSendText:(NSString *)text withExt:(NSDictionary*)ext
{
    if (text && text.length > 0) {
        [self sendTextMessage:text withExt:ext];
    }
}

/**
 *  按下录音按钮开始录音
 */
- (void)didStartRecordingVoiceAction:(UIView *)recordView
{
    if ([self _canRecord]) {
        EMRecordView *tmpView = (EMRecordView *)recordView;
        tmpView.center = self.view.center;
        [self.view addSubview:tmpView];
        [self.view bringSubviewToFront:recordView];
        int x = arc4random() % 100000;
        NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
        NSString *fileName = [NSString stringWithFormat:@"%d%d",(int)time,x];
        
        [[EMCDDeviceManager sharedInstance] asyncStartRecordingWithFileName:fileName completion:^(NSError *error)
         {
             if (error) {
                 NSLog(NSLocalizedString(@"message.startRecordFail", @"failure to start recording"));
             }
         }];
    }
}

/**
 *  手指向上滑动取消录音
 */
- (void)didCancelRecordingVoiceAction:(UIView *)recordView
{
    [[EMCDDeviceManager sharedInstance] cancelCurrentRecording];
}

/**
 *  松开手指完成录音
 */
- (void)didFinishRecoingVoiceAction:(UIView *)recordView
{
    __weak typeof(self) weakSelf = self;
    [[EMCDDeviceManager sharedInstance] asyncStopRecordingWithCompletion:^(NSString *recordPath, NSInteger aDuration, NSError *error) {
        if (!error) {
            [weakSelf sendVoiceMessageWithLocalPath:recordPath duration:aDuration];
        }
        else {
            [weakSelf showHudInView:self.view hint:NSLocalizedString(@"media.timeShort", @"The recording time is too short")];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf hideHud];
            });
        }
    }];
}

#pragma mark - EMChatBarMoreViewDelegate

- (void)moreView:(EMChatBarMoreView *)moreView didItemInMoreViewAtIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(messageViewController:didSelectMoreView:AtIndex:)]) {
        [self.delegate messageViewController:self didSelectMoreView:moreView AtIndex:index];
        return;
    }
}

- (void)moreViewPhotoAction:(EMChatBarMoreView *)moreView
{
    // 隐藏键盘
    [self.chatToolbar endEditing:YES];
    
    // 弹出照片选择
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    [self presentViewController:self.imagePicker animated:YES completion:NULL];
    
    self.isViewDidAppear = NO;
    [[EMSDKHelper shareHelper] setIsShowingimagePicker:YES];
}

- (void)moreViewTakePicAction:(EMChatBarMoreView *)moreView
{
    // 隐藏键盘
    [self.chatToolbar endEditing:YES];
    
#if TARGET_IPHONE_SIMULATOR
    [self showHint:NSLocalizedString(@"message.simulatorNotSupportCamera", @"simulator does not support taking picture")];
#elif TARGET_OS_IPHONE
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage,(NSString *)kUTTypeMovie];
    [self presentViewController:self.imagePicker animated:YES completion:NULL];
    
    self.isViewDidAppear = NO;
    [[EMSDKHelper shareHelper] setIsShowingimagePicker:YES];
#endif
}

- (void)moreViewLocationAction:(EMChatBarMoreView *)moreView
{
    // 隐藏键盘
    [self.chatToolbar endEditing:YES];
    
    EMLocationViewController *locationController = [[EMLocationViewController alloc] init];
    locationController.delegate = self;
    [self.navigationController pushViewController:locationController animated:YES];
}

- (void)moreViewAudioCallAction:(EMChatBarMoreView *)moreView
{
    // 隐藏键盘
    [self.chatToolbar endEditing:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_CALL object:@{@"chatter":self.conversation.chatter, @"type":[NSNumber numberWithInt:eCallSessionTypeAudio]}];
}

- (void)moreViewVideoCallAction:(EMChatBarMoreView *)moreView
{
    // 隐藏键盘
    [self.chatToolbar endEditing:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_CALL object:@{@"chatter":self.conversation.chatter, @"type":[NSNumber numberWithInt:eCallSessionTypeVideo]}];
}

#pragma mark - EMLocationViewDelegate

-(void)sendLocationLatitude:(double)latitude
                  longitude:(double)longitude
                 andAddress:(NSString *)address
{
    [self sendLocationMessageLatitude:latitude longitude:longitude andAddress:address];
}

#pragma mark - EaseMob

#pragma mark - EMChatManagerChatDelegate

- (void)didReceiveOfflineMessages:(NSArray *)offlineMessages
{
    if (![offlineMessages count])
    {
        return;
    }
    
    if ([self _shouldMarkMessageAsRead])
    {
        [self.conversation markAllMessagesAsRead:YES];
    }
    
    long long timestamp = 0;
    if(self.conversation.latestMessage){
        timestamp = self.conversation.latestMessage.timestamp + 1;
    }
    else{
        timestamp = [[NSDate date] timeIntervalSince1970] * 1000 + 1;
    }
    [self _loadMessagesBefore:timestamp
                        count:[self.messsagesSource count] + [offlineMessages count]
                       append:NO];
}

-(void)didReceiveMessage:(EMMessage *)message
{
    if ([self.conversation.chatter isEqualToString:message.conversationChatter]) {
        [self addMessageToDataSource:message progress:nil];
        
        [self _sendHasReadResponseForMessages:@[message]
                                       isRead:NO];
        
        if ([self _shouldMarkMessageAsRead])
        {
            [self.conversation markMessageWithId:message.messageId asRead:YES];
        }
    }
}

-(void)didReceiveCmdMessage:(EMMessage *)message
{
    if ([self.conversation.chatter isEqualToString:message.conversationChatter]) {
        [self showHint:NSLocalizedString(@"receiveCmd", @"receive cmd message")];
    }
}

- (void)didReceiveMessageId:(NSString *)messageId
                    chatter:(NSString *)conversationChatter
                      error:(EMError *)error
{
    if (error && [self.conversation.chatter isEqualToString:conversationChatter])
    {
        __weak typeof(self) weakSelf = self;
        id<IMessageModel> model = nil;
        for (int i = 0; i < self.dataArray.count; i ++) {
            id object = [self.dataArray objectAtIndex:i];
            if ([object conformsToProtocol:@protocol(IMessageModel)]) {
                model = (id<IMessageModel>)object;
                if ([messageId isEqualToString:model.message.messageId]) {
                    model.message.deliveryState = eMessageDeliveryState_Failure;
                    
                    if (_delegate && [_delegate respondsToSelector:@selector(messageViewController:didFailSendingMessageModel:error:)]) {
                        [_delegate messageViewController:self didFailSendingMessageModel:model error:error];
                    }
                    else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf.tableView beginUpdates];
                            [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                            [weakSelf.tableView endUpdates];
                            
                        });
                        
                        if (error && error.errorCode == EMErrorMessageContainSensitiveWords)
                        {
                            CGRect frame = self.chatToolbar.frame;
                            [self showHint:NSLocalizedString(@"message.forbiddenWords", @"Your message contains forbidden words") yOffset:-frame.size.height + 50];
                        }
                    }
                    
                    break;
                }
            }
        }
    }
}

- (void)didReceiveHasReadResponse:(EMReceipt *)receipt
{
    if (![self.conversation.chatter isEqualToString:receipt.conversationChatter]){
        return;
    }
    
    __block id<IMessageModel> model = nil;
    __block BOOL isHave = NO;
    [self.dataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         if ([obj conformsToProtocol:@protocol(IMessageModel)])
         {
             model = (id<IMessageModel>)obj;
             if ([model.messageId isEqualToString:receipt.chatId])
             {
                 model.message.isReadAcked = YES;
                 isHave = YES;
                 *stop = YES;
             }
         }
     }];
    
    if(!isHave){
        return;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(messageViewController:didReceiveHasReadAckForModel:)]) {
        [_delegate messageViewController:self didReceiveHasReadAckForModel:model];
    }
    else{
        [self.tableView reloadData];
    }
}

- (void)didSendMessage:(EMMessage *)message
                 error:(EMError *)error
{
    if (![self.conversation.chatter isEqualToString:message.conversationChatter]){
        return;
    }
    
    __block id<IMessageModel> model = nil;
    __block BOOL isHave = NO;
    [self.dataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         if ([obj conformsToProtocol:@protocol(IMessageModel)])
         {
             model = (id<IMessageModel>)obj;
             if ([model.messageId isEqualToString:message.messageId])
             {
                 model.message.deliveryState = message.deliveryState;
                 isHave = YES;
                 *stop = YES;
             }
         }
     }];
    
    if(!isHave){
        return;
    }
    
    if (error) {
        if (_delegate && [_delegate respondsToSelector:@selector(messageViewController:didFailSendingMessageModel:error:)]) {
            [_delegate messageViewController:self didFailSendingMessageModel:model error:error];
        }
        else{
            [self.tableView reloadData];
        }
    }
    else{
        if (_delegate && [_delegate respondsToSelector:@selector(messageViewController:didSendMessageModel:)]) {
            [_delegate messageViewController:self didSendMessageModel:model];
        }
        else{
            [self.tableView reloadData];
        }
    }
}

#pragma mark - IEMChatProgressDelegate

- (void)setProgress:(float)progress
         forMessage:(EMMessage *)message
     forMessageBody:(id<IEMMessageBody>)messageBody
{
    if (![self.conversation.chatter isEqualToString:message.conversationChatter]){
        return;
    }
    
    __block id<IMessageModel> model = nil;
    __block BOOL isHave = NO;
    [self.dataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         if ([obj conformsToProtocol:@protocol(IMessageModel)])
         {
             model = (id<IMessageModel>)obj;
             if ([model.messageId isEqualToString:message.messageId])
             {
                 model.progress = progress;
                 isHave = YES;
                 *stop = YES;
             }
         }
     }];
    
    if(!isHave){
        return;
    }
    
    if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:updateProgress:messageModel:messageBody:)]) {
        [_dataSource messageViewController:self
                            updateProgress:progress
                              messageModel:model
                               messageBody:messageBody];
    }
}

#pragma mark - EMCDDeviceManagerProximitySensorDelegate

- (void)proximitySensorChanged:(BOOL)isCloseToUser
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if (isCloseToUser)
    {
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    } else {
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        if (self.playingVoiceModel == nil) {
            [[EMCDDeviceManager sharedInstance] disableProximitySensor];
        }
    }
    [audioSession setActive:YES error:nil];
}

#pragma mark - action

- (void)deleteMenuAction:(id)sender
{
    if (self.menuIndexPath && self.menuIndexPath.row > 0) {
        id<IMessageModel> model = [self.dataArray objectAtIndex:self.menuIndexPath.row];
        NSMutableIndexSet *indexs = [NSMutableIndexSet indexSetWithIndex:self.menuIndexPath.row];
        NSMutableArray *indexPaths = [NSMutableArray arrayWithObjects:self.menuIndexPath, nil];
        
        [self.conversation removeMessage:model.message];
        [self.messsagesSource removeObject:model.message];
        
        if (self.menuIndexPath.row - 1 >= 0) {
            id nextMessage = nil;
            id prevMessage = [self.dataArray objectAtIndex:(self.menuIndexPath.row - 1)];
            if (self.menuIndexPath.row + 1 < [self.dataArray count]) {
                nextMessage = [self.dataArray objectAtIndex:(self.menuIndexPath.row + 1)];
            }
            if ((!nextMessage || [nextMessage isKindOfClass:[NSString class]]) && [prevMessage isKindOfClass:[NSString class]]) {
                [indexs addIndex:self.menuIndexPath.row - 1];
                [indexPaths addObject:[NSIndexPath indexPathForRow:(self.menuIndexPath.row - 1) inSection:0]];
            }
        }
        
        [self.dataArray removeObjectsAtIndexes:indexs];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
    
    self.menuIndexPath = nil;
}

#pragma mark - public 

- (NSArray *)formatMessages:(NSArray *)messages
{
    NSMutableArray *formattedArray = [[NSMutableArray alloc] init];
    if ([messages count] == 0) {
        return formattedArray;
    }
    
    for (EMMessage *message in messages) {
        //计算時間间隔
        CGFloat interval = (self.messageTimeIntervalTag - message.timestamp) / 1000;
        if (self.messageTimeIntervalTag < 0 || interval > 60 || interval < -60) {
            NSDate *messageDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:(NSTimeInterval)message.timestamp];
            NSString *timeStr = @"";
            
            if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:stringForDate:)]) {
                timeStr = [_dataSource messageViewController:self stringForDate:messageDate];
            }
            else{
                timeStr = [messageDate formattedTime];
            }
            [formattedArray addObject:timeStr];
            self.messageTimeIntervalTag = message.timestamp;
        }
        
        //构建数据模型
        id<IMessageModel> model = nil;
        if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:modelForMessage:)]) {
            model = [_dataSource messageViewController:self modelForMessage:message];
        }
        else{
            model = [[EMMessageModel alloc] initWithMessage:message];
            model.avatarImage = [UIImage imageNamed:@"EaseUIResource.bundle/user"];
            model.failImageName = @"imageDownloadFail";
        }

        if (model) {
            [formattedArray addObject:model];
        }
    }
    
    return formattedArray;
}

-(void)addMessageToDataSource:(EMMessage *)message
                     progress:(id<IEMChatProgressDelegate>)progress
{
    [self.messsagesSource addObject:message];
    
    NSArray *messages = [self formatMessages:@[message]];
    
    __weak EMMessageViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.dataArray addObjectsFromArray:messages];
        [weakSelf.tableView reloadData];
        [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[weakSelf.dataArray count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    });
}

#pragma mark - public

- (void)tableViewDidTriggerHeaderRefresh
{
    self.messageTimeIntervalTag = -1;
    long long timestamp = 0;
    if ([self.messsagesSource count] > 0) {
        timestamp = [(EMMessage *)self.messsagesSource.firstObject timestamp];
    }
    else if(self.conversation.latestMessage){
        timestamp = self.conversation.latestMessage.timestamp + 1;
    }
    else{
        timestamp = [[NSDate date] timeIntervalSince1970] * 1000 + 1;
    }
    [self _loadMessagesBefore:timestamp count:self.messageCountOfPage append:YES];
    
    [self tableViewDidFinishTriggerHeader:YES reload:YES];
}

- (void)reloadConversationList
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATIONNAME_RELOADCONLIST object:nil];
}

#pragma mark - send message

- (void)sendTextMessage:(NSString *)text
{
    [self sendTextMessage:text withExt:nil];
}

- (void)sendTextMessage:(NSString *)text withExt:(NSDictionary*)ext
{
    EMMessage *message = [EMSDKHelper sendTextMessage:text
                                                   to:self.conversation.chatter
                                          messageType:[self _messageTypeFromConversationType]
                                    requireEncryption:NO
                                           messageExt:ext];
    [self addMessageToDataSource:message
                        progress:nil];
}

- (void)sendLocationMessageLatitude:(double)latitude
                          longitude:(double)longitude
                         andAddress:(NSString *)address
{
    EMMessage *message = [EMSDKHelper sendLocationMessageWithLatitude:latitude
                                                            longitude:longitude
                                                              address:address
                                                                   to:self.conversation.chatter
                                                          messageType:[self _messageTypeFromConversationType]
                                                    requireEncryption:NO
                                                           messageExt:nil];
    [self addMessageToDataSource:message
                        progress:nil];
}

- (void)sendImageMessage:(UIImage *)image
{
    id<IEMChatProgressDelegate> progress = nil;
    if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:progressDelegateForMessageBodyType:)]) {
        progress = [_dataSource messageViewController:self progressDelegateForMessageBodyType:eMessageBodyType_Image];
    }
    else{
        progress = self;
    }
    
    EMMessage *message = [EMSDKHelper sendImageMessageWithImage:image
                                                             to:self.conversation.chatter
                                                    messageType:[self _messageTypeFromConversationType]
                                              requireEncryption:NO
                                                     messageExt:nil
                                                       progress:progress];
    [self addMessageToDataSource:message
                        progress:progress];
}

- (void)sendVoiceMessageWithLocalPath:(NSString *)localPath
                             duration:(NSInteger)duration
{
    id<IEMChatProgressDelegate> progress = nil;
    if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:progressDelegateForMessageBodyType:)]) {
        progress = [_dataSource messageViewController:self progressDelegateForMessageBodyType:eMessageBodyType_Voice];
    }
    else{
        progress = self;
    }
    
    EMMessage *message = [EMSDKHelper sendVoiceMessageWithLocalPath:localPath
                                                           duration:duration
                                                                 to:self.conversation.chatter
                                                        messageType:[self _messageTypeFromConversationType]
                                                  requireEncryption:NO
                                                         messageExt:nil
                                                           progress:progress];
    [self addMessageToDataSource:message
                        progress:progress];
}

- (void)sendVideoMessageWithURL:(NSURL *)url
{
    id<IEMChatProgressDelegate> progress = nil;
    if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:progressDelegateForMessageBodyType:)]) {
        progress = [_dataSource messageViewController:self progressDelegateForMessageBodyType:eMessageBodyType_Video];
    }
    else{
        progress = self;
    }
    
    EMMessage *message = [EMSDKHelper sendVideoMessageWithURL:url
                                                           to:self.conversation.chatter
                                                  messageType:[self _messageTypeFromConversationType]
                                            requireEncryption:NO
                                                   messageExt:nil
                                                     progress:progress];
    [self addMessageToDataSource:message
                        progress:progress];
}

@end
