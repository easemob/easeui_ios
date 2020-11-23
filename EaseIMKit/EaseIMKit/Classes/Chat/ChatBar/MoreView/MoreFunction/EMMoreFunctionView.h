//
//  EMMoreFunctionView.h
//  EaseIM
//
//  Created by 娜塔莎 on 2019/10/23.
//  Copyright © 2019 娜塔莎. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EaseHeaders.h"
#import "EMMessageCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ExtType) {
    ExtTypeChatBar = 1, // 输入组件更多功能区
    ExtTypeLongPress, //长按更多功能扩展区
};
@interface EMExtModel : NSObject
@property (nonatomic, assign) CGFloat cellLonger;
@property (nonatomic, assign) CGFloat xOffset;
@property (nonatomic, assign) CGFloat yOffset;
@property (nonatomic, assign) NSInteger itemCount;
@property (nonatomic, assign) NSInteger rowCount;
@property (nonatomic, assign) NSInteger columCount;
@property (nonatomic, assign) CGSize collectionViewSize;
@property (nonatomic, assign) ExtType type;
- (instancetype)initWithType:(ExtType)type itemCount:(NSInteger)itemCount;
@end

@protocol EMMoreFunctionViewDelegate;
@interface EMMoreFunctionView : UIView
@property (nonatomic, weak) id<EMMoreFunctionViewDelegate> delegate;
//输入区ext
- (instancetype)initWithConversation:(EMConversation *)conversation itemDescArray:(NSMutableArray<NSString*>*)itemDescArray itemImgArray:(NSMutableArray<UIImage*>*)itemImgArray isCustom:(BOOL)isCustom;
//消息长按ext
- (instancetype)initWithData:(NSMutableArray<NSString*>*)itemDescArray itemImgArray:(NSMutableArray<UIImage*>*)itemImgArray isCustom:(BOOL)isCustom;
//视图尺寸
- (CGSize)getExtViewSize;
@end

@protocol EMMoreFunctionViewDelegate <NSObject>
@optional
- (void)chatBarMoreFunctionReadReceipt;//群组阅读回执
- (void)chatBarMoreFunctionAction:(NSInteger)componentTag itemDesc:(NSString*)itemDesc extType:(ExtType)extType;
- (NSArray<NSString*>*)hideItem:(NSArray<NSString*>*)itemList extType:(ExtType)extType;//可选隐藏某些弹出项
@end


@protocol SessionToolbarCellDelegate <NSObject>
@required
- (void)toolbarCellDidSelected:(NSInteger)tag itemDesc:(NSString*)itemDesc;
@end

@interface SessionToolbarCell : UICollectionViewCell
@property (nonatomic, weak) id<SessionToolbarCellDelegate> delegate;
- (void)personalizeToolbar:(UIImage*)itemImg funcDesc:(NSString *)funcDesc tag:(NSInteger)tag;//个性化工具栏功能描述
@end



NS_ASSUME_NONNULL_END
