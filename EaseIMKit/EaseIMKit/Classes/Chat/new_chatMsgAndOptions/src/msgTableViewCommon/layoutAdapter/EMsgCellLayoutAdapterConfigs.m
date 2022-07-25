//
//  EMsgCellLayoutAdapterConfigs.m
//  EaseCallKit
//
//  Created by yangjian on 2022/5/18.
//

#import "EMsgCellLayoutAdapterConfigs.h"

static EMsgCellLayoutAdapterConfigs *obj0 = nil;
@implementation EMsgCellLayoutAdapterConfigs

+ (instancetype)shared{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj0 = EMsgCellLayoutAdapterConfigs.new;
    });
    return obj0;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [self config];
    }
    return self;
}

- (void)config{
    self.userInfoLayoutAdapter = EMsgCellUserInfoLayoutAdapter.new;
    self.userInfoLayoutAdapter.headTop = 4;
    self.userInfoLayoutAdapter.headFromSide = 14;
    self.userInfoLayoutAdapter.headWidth = 40;
    self.userInfoLayoutAdapter.headHeight = 40;
    self.userInfoLayoutAdapter.nameTop = 4;
    self.userInfoLayoutAdapter.nameFromSide = 12;
    self.userInfoLayoutAdapter.nameHeight = 14;
    
    self.backgroundLayoutAdapter = EMsgCellMsgBackgroundLayoutAdapter.new;
    self.backgroundLayoutAdapter.top = 4;
    self.backgroundLayoutAdapter.fromSide = 0;
    self.backgroundLayoutAdapter.toSide = 60;
    self.backgroundLayoutAdapter.bottom = 8;

    self.contentLayoutAdapter = EMsgCellMsgContentLayoutAdapter.new;
    self.contentLayoutAdapter.top = 16;
    self.contentLayoutAdapter.fromSide = 30;
    self.contentLayoutAdapter.toSide = 30;
    self.contentLayoutAdapter.bottom = 16;
    
    self.contentUnknownLayoutAdapter = EMsgCellMsgContentLayoutAdapter.new;
    self.contentUnknownLayoutAdapter.top = 10;
    self.contentUnknownLayoutAdapter.fromSide = 10;
    self.contentUnknownLayoutAdapter.toSide = 10;
    self.contentUnknownLayoutAdapter.bottom = 10;

}

- (float)msgBackgroundWidth{
    return [self.backgroundLayoutAdapter msgBackgroundWidth_userInfoAdapter:self.userInfoLayoutAdapter];
}

- (float)cellHeight_apartFrom_msgBackgroundHeight_showName:(BOOL)showName{
    return [self.backgroundLayoutAdapter cellHeight_apartFrom_msgBackgroundHeight_userInfoAdapter:self.userInfoLayoutAdapter showName:showName];
}

- (float)cellMinHeight{
    return [self.backgroundLayoutAdapter cellMinHeight_userInfoAdapter:self.userInfoLayoutAdapter];
}

//cellHeight - contentHeight后 , 所剩高度
- (float)cellHeight_apartFrom_msgContentHeight_showName:(BOOL)showName{
    return [self.contentLayoutAdapter cellHeight_apartFrom_msgContentHeight_userInfoAdapter:self.userInfoLayoutAdapter backgroundAdapter:self.backgroundLayoutAdapter showName:showName];
}

- (float)msgContentMaxWidth{
    return [self.contentLayoutAdapter msgContentMaxWidth_userInfoAdapter:self.userInfoLayoutAdapter backgroundAdapter:self.backgroundLayoutAdapter];
}

@end

static EMsgCellBubbleLayoutAdapterConfigs *obj1 = nil;
@implementation EMsgCellBubbleLayoutAdapterConfigs
+ (instancetype)shared{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj1 = EMsgCellBubbleLayoutAdapterConfigs.new;
    });
    return obj1;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [self config];
    }
    return self;
}

- (void)config{
    self.defaultAdapter = EMsgCellBubbleLayoutAdapter.new;
    
    self.defaultAdapter.sendImageName = @"bubble_send_default";
    self.defaultAdapter.receiveImageName = @"bubble_receive_default";
    self.defaultAdapter.top = 13;
    self.defaultAdapter.fromSide = 13;
    self.defaultAdapter.toSide = 13;
    self.defaultAdapter.bottom = 13;
    
    self.defaultAdapter.resizableTop = 12;
    self.defaultAdapter.resizableFromSide = 12;
    self.defaultAdapter.resizableToSide = 12;
    self.defaultAdapter.resizableBottom = 12;

    
    self.catAdapter = EMsgCellBubbleLayoutAdapter.new;
    
    self.catAdapter.sendImageName = @"bubble_cat_send";
    self.catAdapter.receiveImageName = @"bubble_cat_receive";
    self.catAdapter.top = 16;
    
    self.catAdapter.fromSide = 20;
    self.catAdapter.toSide = 16;
    
    self.catAdapter.bottom = 13;
    
    self.catAdapter.resizableTop = 16;
    self.catAdapter.resizableFromSide = 23;
    self.catAdapter.resizableToSide = 28;
    self.catAdapter.resizableBottom = 13;

}

- (EMsgCellBubbleLayoutAdapter *)currentAdapter{
    return self.defaultAdapter;
}


@end

static EMsgCellOtherLayoutAdapterConfigs *obj2 = nil;
@implementation EMsgCellOtherLayoutAdapterConfigs
+ (instancetype)shared{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj2 = EMsgCellOtherLayoutAdapterConfigs.new;
    });
    return obj2;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [self config];
    }
    return self;
}

- (void)config{
    
    self.timeMarkerCellHeight = 36;

    self.bigEmojiContentSize = CGSizeMake(80, 80);
    
    self.systemRemindTopAndBottomEdgeSpacing = 12;
    self.systemRemindLeftAndRightMiniEdgeSpacing = 20;
    
    self.locationCellMsgContentWidth = EMsgCellLayoutAdapterConfigs.shared.msgContentMaxWidth;
    self.locationCellTextLeftAndRightSide = 6;
    self.businessCardCellContentHeight = 140;
    
    self.voiceContentViewHeight = 24;
    self.voiceContentToVoiceConvertTextContentSpacing = 8;
    self.voiceConvertTextEdgeSpacing = 8;
}


@end

