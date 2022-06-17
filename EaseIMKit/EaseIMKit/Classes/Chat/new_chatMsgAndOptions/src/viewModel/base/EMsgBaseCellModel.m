//
//  EMsgBaseCellModel.m
//  EaseCallKit
//
//  Created by yangjian on 2022/5/18.
//

#import "EMsgBaseCellModel.h"

#define Y_TEST 0


@interface EMsgBaseCellModel ()

//系统文本高度
@property (nonatomic)float systemShow_contentHeight;

////图片/视频
//@property (nonatomic)CGSize fitSize;

//文本
@property(nonatomic)float textHeight;

//位置的address字段高度
@property(nonatomic)float addressTextHeight;

@property(nonatomic)float customDescriptionHeight;


@end

@implementation EMsgBaseCellModel

- (instancetype)initWithEMMessage:(EMChatMessage *)aMsg{
    self = [super initWithEMMessage:aMsg];
    [self configFromMessage:aMsg];
    return self;
}

- (void)configFromMessage:(EMChatMessage *)message{
    self.cellType = EMsgCellType_user;
    switch (self.type) {
        case EMMessageTypeText: {
            self.cellName = @"EMsgUserTextCell";
            EMTextMessageBody *body = (EMTextMessageBody *)self.message.body;
            self.textHeight =
            [EMsgTableViewFunctions fitHeight_string:body.text font:EMsgTableViewConfig.shared.textFont maxWidth:EMsgCellLayoutAdapterConfigs.shared.msgContentMaxWidth];
//            fitHeight_string(body.text, EMsgTableViewConfig.shared.textFont, EMsgCellLayoutAdapterConfigs.shared.msgContentMaxWidth);
            break;
        }
        case EMMessageTypeImage: {
            self.cellName = @"EMsgUserImageCell";
            EMImageMessageBody *body = (EMImageMessageBody *)self.message.body;
            self.imageFitSize = [EMsgTableViewFunctions messageCell_imageSizeToFitSize:body.size];
            break;
        }
        case EMMessageTypeVideo: {
            self.cellName = @"EMsgUserVideoCell";
            EMVideoMessageBody *body = (EMVideoMessageBody *)self.message.body;
            self.imageFitSize = [EMsgTableViewFunctions videoCoverFitSizeFromCoverSize:body.thumbnailSize];
            break;
        }
        case EMMessageTypeLocation: {
            self.cellName = @"EMsgUserLocationCell";
            EMLocationMessageBody *body = (EMLocationMessageBody *)self.message.body;
            self.addressTextHeight =
            [EMsgTableViewFunctions
             fitHeight_string:body.address
             font:EMsgTableViewConfig.shared.addressFont
             maxWidth:EMsgCellOtherLayoutAdapterConfigs.shared.locationCellMsgContentWidth
             - (2 * EMsgCellOtherLayoutAdapterConfigs.shared.locationCellTextLeftAndRightSide)];
            break;
        }
        case EMMessageTypeVoice:{
            self.voiceConvertTextState = EMVoiceConvertTextStateNone;
            self.cellName = @"EMsgUserVoiceCell";
            
#if Y_TEST
            {//这里是用来测试布局情况.无任何意义
                self.voiceConvertTextState = EMVoiceConvertTextStateFailure;
                self.voiceConvertTextState = EMVoiceConvertTextStateSuccess;
                self.voiceConvertText = @"预留语音转文字UI控件.预留语音转文字UI控件.预留语音转文字UI控件.预留语音转文字UI控件.预留语音转文字UI控件.预留语音转文字UI控件.预留语音转文字UI控件.预留语音转文字UI控件.";
            }
#endif
            
            break;
        }
        case EMMessageTypeFile:{
            self.cellName = @"EMsgUserFileCell";
            break;
        }
        case EMMessageTypeCmd:              break;
        case EMMessageTypeCustom:{
            EMCustomMessageBody* body = (EMCustomMessageBody *)self.message.body;
            if([body.event isEqualToString:@"userCard"]){
                self.cellName = @"EMsgUserBusinessCardCell";
            }else if ([body.event isEqualToString:@""]){
                self.cellName = @"EMsgUserUNKNOWCell";
                self.customText = [NSString stringWithFormat:@"CUSTOM\nevent:\n%@\ncustomExt:\n%@",body.event,body.customExt];
                self.customDescriptionHeight =
                [EMsgTableViewFunctions
                 fitHeight_string:self.customText
                 font:EMsgTableViewConfig.shared.customDescriptionFont
                 maxWidth:EMsgCellLayoutAdapterConfigs.shared.msgContentMaxWidth];
            }else{
                self.cellName = @"EMsgUserUNKNOWCell";
                self.customText = [NSString stringWithFormat:@"CUSTOM\nevent:\n%@\ncustomExt:\n%@",body.event,body.customExt];
                self.customDescriptionHeight =
                [EMsgTableViewFunctions
                 fitHeight_string:self.customText
                 font:EMsgTableViewConfig.shared.customDescriptionFont
                 maxWidth:EMsgCellLayoutAdapterConfigs.shared.msgContentMaxWidth];
            }
            break;
        }
        case EMMessageTypeExtGif:{
            self.cellName = @"EMsgUserBigEmojiCell";
            break;
        }
        case EMMessageTypeExtRecall:{
            //系统提醒
            self.cellType = EMsgCellType_system;
            self.cellName = @"EMsgSystemRemindCell";
            NSString *content = @"";
            NSString *recallBy = [self.message.ext objectForKey:MSG_EXT_RECALLBY];
            if ([recallBy isEqualToString:EMClient.sharedClient.currentUsername]) {
                content = EaseLocalizableString(@"meRecall", nil);
            } else if ([recallBy isEqualToString:self.message.from]) {
                if (self.message.chatType == EMChatTypeChat) {
                    content = EaseLocalizableString(@"remoteRecall", nil);
                } else {
                    content = [NSString stringWithFormat:@"%@ %@", recallBy, EaseLocalizableString(@"recalledMessage", nil)];
                }
            } else {
                content = [NSString stringWithFormat:@"%@ %@ %@", recallBy, EaseLocalizableString(@"admingRecall", nil), self.message.from];
            }
            self.show_content =
            [EMsgTableViewFunctions attributedString:content font:EMsgTableViewConfig.shared.systemTextFont color:UIColor.grayColor];
            self.systemShow_contentHeight
            = [EMsgTableViewFunctions
               fitHeight_attributedString:self.show_content
               maxWidth:ESCREEN_W
               - EMsgCellOtherLayoutAdapterConfigs.shared.systemRemindLeftAndRightMiniEdgeSpacing
               - EMsgCellOtherLayoutAdapterConfigs.shared.systemRemindLeftAndRightMiniEdgeSpacing];
            break;
        }
        case EMMessageTypeExtCall:          break;
        case EMMessageTypeExtNewFriend:{
            //系统提醒
            self.cellType = EMsgCellType_system;
            self.cellName = @"EMsgSystemRemindCell";
            self.show_content =
            [EMsgTableViewFunctions attributedString:((EMTextMessageBody *)(self.message.body)).text font:EMsgTableViewConfig.shared.systemTextFont color:UIColor.grayColor];
            self.systemShow_contentHeight
            = [EMsgTableViewFunctions
               fitHeight_attributedString:self.show_content
               maxWidth:ESCREEN_W
               - EMsgCellOtherLayoutAdapterConfigs.shared.systemRemindLeftAndRightMiniEdgeSpacing
               - EMsgCellOtherLayoutAdapterConfigs.shared.systemRemindLeftAndRightMiniEdgeSpacing];
            break;
        }
        case EMMessageTypePictMixText:      break;
        case EMMessageTypeExtAddGroup:{
            
            //系统提醒
            self.cellType = EMsgCellType_system;
            self.cellName = @"EMsgSystemRemindCell";
            self.show_content =
            [EMsgTableViewFunctions attributedString:((EMTextMessageBody *)(self.message.body)).text font:EMsgTableViewConfig.shared.systemTextFont color:UIColor.grayColor];
            self.systemShow_contentHeight
            = [EMsgTableViewFunctions
               fitHeight_attributedString:self.show_content
               maxWidth:ESCREEN_W
               - EMsgCellOtherLayoutAdapterConfigs.shared.systemRemindLeftAndRightMiniEdgeSpacing
               - EMsgCellOtherLayoutAdapterConfigs.shared.systemRemindLeftAndRightMiniEdgeSpacing];
            break;
        }
        default:
            break;
    }
}


- (instancetype)initWithTimeMarker:(NSString *)timeString{
    self = [super init];
    if (self) {
        self.cellType = EMsgCellType_time;
        self.show_content =
        [EMsgTableViewFunctions attributedString:timeString font:EMsgTableViewConfig.shared.timeFont color:UIColor.grayColor];
        self.cellName = @"EMsgTimeMarkerCell";
    }
    return self;
}

- (float)cellHeight{
    switch (self.cellType) {
        case EMsgCellType_user:{
            switch (self.type) {
                case EMMessageTypeText:
                    return
                    self.textHeight
                    + [EMsgCellLayoutAdapterConfigs.shared
                       cellHeight_apartFrom_msgContentHeight_showName:
                           [EMsgTableViewConfig.shared
                            showName_chatType:self.message.chatType
                            direction:self.message.direction]];
                case EMMessageTypeExtGif:
                    return
                    EMsgCellOtherLayoutAdapterConfigs.shared.bigEmojiContentSize.height
                    + [EMsgCellLayoutAdapterConfigs.shared
                       cellHeight_apartFrom_msgContentHeight_showName:
                           [EMsgTableViewConfig.shared
                            showName_chatType:self.message.chatType
                            direction:self.message.direction]];
                case EMMessageTypeImage:
                    return
                    self.imageFitSize.height
                    + [EMsgCellLayoutAdapterConfigs.shared
                       cellHeight_apartFrom_msgContentHeight_showName:
                           [EMsgTableViewConfig.shared
                            showName_chatType:self.message.chatType
                            direction:self.message.direction]];
                case EMMessageTypeVideo:
                    return
                    self.imageFitSize.height
                    + [EMsgCellLayoutAdapterConfigs.shared
                       cellHeight_apartFrom_msgContentHeight_showName:
                           [EMsgTableViewConfig.shared
                            showName_chatType:self.message.chatType
                            direction:self.message.direction]];
                case EMMessageTypeVoice:{
                    switch (self.voiceConvertTextState) {
                        case EMVoiceConvertTextStateNone:{
                            return
                            EMsgCellOtherLayoutAdapterConfigs.shared.voiceContentViewHeight
                            + [EMsgCellLayoutAdapterConfigs.shared
                               cellHeight_apartFrom_msgContentHeight_showName:
                                   [EMsgTableViewConfig.shared
                                    showName_chatType:self.message.chatType
                                    direction:self.message.direction]];
                        }
                        default:{
                            return
                            EMsgCellOtherLayoutAdapterConfigs.shared.voiceContentViewHeight
                            + [EMsgCellLayoutAdapterConfigs.shared
                               cellHeight_apartFrom_msgContentHeight_showName:
                                   [EMsgTableViewConfig.shared
                                    showName_chatType:self.message.chatType
                                    direction:self.message.direction]]
                            + EMsgCellOtherLayoutAdapterConfigs.shared.voiceContentToVoiceConvertTextContentSpacing
                            + [EMsgTableViewFunctions fitHeight_string:self.voiceConvertText font:EMsgTableViewConfig.shared.voiceConvertTextFont maxWidth:EMsgCellLayoutAdapterConfigs.shared.msgBackgroundWidth - EMsgCellOtherLayoutAdapterConfigs.shared.voiceConvertTextEdgeSpacing - EMsgCellOtherLayoutAdapterConfigs.shared.voiceConvertTextEdgeSpacing]
                            + EMsgCellOtherLayoutAdapterConfigs.shared.voiceConvertTextEdgeSpacing
                            + EMsgCellOtherLayoutAdapterConfigs.shared.voiceConvertTextEdgeSpacing;
                        }
                    }
                    return 100;
                }
                case EMMessageTypeFile:{
                    return 50
                    + [EMsgCellLayoutAdapterConfigs.shared
                       cellHeight_apartFrom_msgContentHeight_showName:
                           [EMsgTableViewConfig.shared
                            showName_chatType:self.message.chatType
                            direction:self.message.direction]];
                }
                case EMMessageTypeLocation:
                    return
                    126 + self.addressTextHeight
                    + [EMsgCellLayoutAdapterConfigs.shared
                       cellHeight_apartFrom_msgContentHeight_showName:
                           [EMsgTableViewConfig.shared
                            showName_chatType:self.message.chatType
                            direction:self.message.direction]];
                case EMMessageTypeCustom:{
                    EMCustomMessageBody* body = (EMCustomMessageBody *)self.message.body;
                    if([body.event isEqualToString:@"userCard"]){
                        return EMsgCellOtherLayoutAdapterConfigs.shared.businessCardCellContentHeight
                        + [EMsgCellLayoutAdapterConfigs.shared
                           cellHeight_apartFrom_msgContentHeight_showName:
                               [EMsgTableViewConfig.shared
                                showName_chatType:self.message.chatType
                                direction:self.message.direction]];
                    }else if ([body.event isEqualToString:@""]){
                        return
                        self.customDescriptionHeight
                        + [EMsgCellLayoutAdapterConfigs.shared
                           cellHeight_apartFrom_msgContentHeight_showName:
                               [EMsgTableViewConfig.shared
                                showName_chatType:self.message.chatType
                                direction:self.message.direction]];
                    }else{
                        return
                        self.customDescriptionHeight
                        + [EMsgCellLayoutAdapterConfigs.shared
                           cellHeight_apartFrom_msgContentHeight_showName:
                               [EMsgTableViewConfig.shared
                                showName_chatType:self.message.chatType
                                direction:self.message.direction]];
                    }
                }
                default:
                    break;
            }
            return 0;
        }
        case EMsgCellType_time:{
            return EMsgCellOtherLayoutAdapterConfigs.shared.timeMarkerCellHeight;
        }
        case EMsgCellType_system:{
            return self.systemShow_contentHeight
            + EMsgCellOtherLayoutAdapterConfigs.shared.systemRemindTopAndBottomEdgeSpacing
            + EMsgCellOtherLayoutAdapterConfigs.shared.systemRemindTopAndBottomEdgeSpacing
            ;
        }
        default:{
            return 0;
        }
    }
    return 0;
}


- (void)audioStateChange:(NSNotification *)aNotif
{
    id object = aNotif.object;
    if ([object isKindOfClass:[EaseMessageModel class]]) {
        EaseMessageModel *model = (EaseMessageModel *)object;
        if (model == self && self.isPlaying == NO) {
            self.isPlaying = YES;
        } else {
            self.isPlaying = NO;
        }
//        [self.weakCell bindViewModel:self];
//        [self.weakMessageCell.bubbleView setModel:self];
//        if (model == self && model.direction == EMMessageDirectionReceive) {
//            [self.weakCell setStatusHidden:model.message.isListened];
//        }
    }
}


@end
