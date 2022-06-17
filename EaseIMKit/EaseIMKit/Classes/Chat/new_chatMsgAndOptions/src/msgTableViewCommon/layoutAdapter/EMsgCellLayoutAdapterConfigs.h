//
//  EMsgCellLayoutAdapterConfigs.h
//  EaseCallKit
//
//  Created by yangjian on 2022/5/18.
//

#import <Foundation/Foundation.h>
#import "EMsgCellLayoutAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMsgCellLayoutAdapterConfigs : NSObject

@property (nonatomic,strong)EMsgCellUserInfoLayoutAdapter *userInfoLayoutAdapter;

@property (nonatomic,strong)EMsgCellMsgBackgroundLayoutAdapter *backgroundLayoutAdapter;

@property (nonatomic,strong)EMsgCellMsgContentLayoutAdapter *contentLayoutAdapter;

@property (nonatomic,strong)EMsgCellMsgContentLayoutAdapter *contentUnknownLayoutAdapter;

+ (instancetype)shared;


- (float)msgBackgroundWidth;

- (float)cellHeight_apartFrom_msgBackgroundHeight_showName:(BOOL)showName;

- (float)cellMinHeight;

- (float)cellHeight_apartFrom_msgContentHeight_showName:(BOOL)showName;

- (float)msgContentMaxWidth;


@end

@interface EMsgCellBubbleLayoutAdapterConfigs : NSObject

@property (nonatomic,strong)EMsgCellBubbleLayoutAdapter *defaultAdapter;

@property (nonatomic,strong)EMsgCellBubbleLayoutAdapter *catAdapter;

+ (instancetype)shared;

@end

@interface EMsgCellOtherLayoutAdapterConfigs : NSObject

@property (nonatomic)float timeMarkerCellHeight;

//系统提示样式的高度(抛去文字高度,文字可能涉及到换行,故去除)
@property (nonatomic)float systemRemindTopAndBottomEdgeSpacing;
@property (nonatomic)float systemRemindLeftAndRightMiniEdgeSpacing;


@property (nonatomic)CGSize bigEmojiContentSize;

@property (nonatomic)float locationCellMsgContentWidth;
@property (nonatomic)float locationCellTextLeftAndRightSide;
@property (nonatomic)float businessCardCellContentHeight;

@property (nonatomic)float voiceContentViewHeight;
@property (nonatomic)float voiceContentToVoiceConvertTextContentSpacing;
@property (nonatomic)float voiceConvertTextEdgeSpacing;

+ (instancetype)shared;


@end


NS_ASSUME_NONNULL_END
