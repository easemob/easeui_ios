//
//  EMsgCellLayoutAdapter.h
//  EaseIMKit
//
//  Created by yangjian on 2022/5/17.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <HyphenateChat/HyphenateChat.h>

#define ESCREEN_W UIScreen.mainScreen.bounds.size.width
#define ESCREEN_H UIScreen.mainScreen.bounds.size.height


NS_ASSUME_NONNULL_BEGIN

//=============================
@interface EMsgCellUserInfoLayoutAdapter : NSObject

@property (nonatomic)float headTop;
@property (nonatomic)float headFromSide;
@property (nonatomic)float headWidth;
@property (nonatomic)float headHeight;
@property (nonatomic)float nameTop;
@property (nonatomic)float nameFromSide;
@property (nonatomic)float nameHeight;  //建议 : 字号值 + 2

//展示头像时所占用宽度 headFromSide + headWidth
@property (nonatomic,readonly)float headTakeWidth;

//展示名字时所占用高度 nameTop + nameHeight
@property (nonatomic,readonly)float nameTakeHeight;

@end

//=============================
@interface EMsgCellMsgBackgroundLayoutAdapter : NSObject
//以下数值,将会按照距离最近的控件(无控件则按照边缘)来计算
@property (nonatomic)float top;
@property (nonatomic)float fromSide;
@property (nonatomic)float toSide;
@property (nonatomic)float bottom;

//计算message背景宽度 (这个不是最大宽度,这里不做自动撑宽,而是实际宽度)
//这里不再做气泡,因为涉及到有些内容将不会在气泡内,所以气泡的范围并不能确定.
- (float)msgBackgroundWidth_userInfoAdapter:(EMsgCellUserInfoLayoutAdapter *)userInfoAdapter;

//计算 cell的除去背景的高度  cell_H - msgbackground_H
- (float)cellHeight_apartFrom_msgBackgroundHeight_userInfoAdapter:(EMsgCellUserInfoLayoutAdapter *)userInfoAdapter
                                         showName:(BOOL)showName;

//计算给出最小高度(如果做好限定,这个高度其实可以放弃)
- (float)cellMinHeight_userInfoAdapter:(EMsgCellUserInfoLayoutAdapter *)userInfoAdapter;

@end

//=============================
@interface EMsgCellMsgContentLayoutAdapter : NSObject

@property (nonatomic)float top;
@property (nonatomic)float fromSide;
@property (nonatomic)float toSide;
@property (nonatomic)float bottom;

- (float)cellHeight_apartFrom_msgContentHeight_userInfoAdapter:(EMsgCellUserInfoLayoutAdapter *)userInfoAdapter
                             backgroundAdapter:(EMsgCellMsgBackgroundLayoutAdapter *)backgroundAdapter
                                      showName:(BOOL)showName;

- (float)msgContentMaxWidth_userInfoAdapter:(EMsgCellUserInfoLayoutAdapter *)userInfoAdapter
          backgroundAdapter:(EMsgCellMsgBackgroundLayoutAdapter *)backgroundAdapter;

@end

//=============================
@interface EMsgCellBubbleLayoutAdapter : NSObject

@property (nonatomic)float top;
@property (nonatomic)float fromSide;
@property (nonatomic)float toSide;
@property (nonatomic)float bottom;

@property (nonatomic)float resizableTop;
@property (nonatomic)float resizableBottom;
@property (nonatomic)float resizableFromSide;
@property (nonatomic)float resizableToSide;

@property (nonatomic,copy)NSString *sendImageName;
@property (nonatomic,copy)NSString *receiveImageName;


- (UIImage *)bubbleImage:(EMMessageDirection)direction;


@end



















NS_ASSUME_NONNULL_END
