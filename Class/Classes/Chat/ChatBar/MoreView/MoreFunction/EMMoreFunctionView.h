//
//  EMMoreFunctionView.h
//  EaseIM
//
//  Created by 娜塔莎 on 2019/10/23.
//  Copyright © 2019 娜塔莎. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EaseHeaders.h"
#import "EaseMessageCell.h"
#import "EaseExtMenuModel.h"
#import "EaseExtFuncModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ExtType) {
    ExtTypeChatBar = 1, // 输入组件更多功能区
    ExtTypeLongPress, //长按更多功能扩展区
    ExtTypeCustomCellLongPress, //自定义cell长按功能区
};
@interface EaseExtMenuViewModel : NSObject
@property (nonatomic, assign) CGFloat cellLonger;
@property (nonatomic, assign) CGFloat xOffset;
@property (nonatomic, assign) CGFloat yOffset;
@property (nonatomic, assign) NSInteger itemCount;
@property (nonatomic, assign) NSInteger rowCount;
@property (nonatomic, assign) NSInteger columCount;
@property (nonatomic, assign) CGSize collectionViewSize;
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, strong) UIColor *fontColor;
@property (nonatomic, strong) UIColor *iconBgColor;//图标背景色
@property (nonatomic, assign) ExtType type;
- (instancetype)initWithType:(ExtType)type itemCount:(NSInteger)itemCount extFuncModel:(EaseExtFuncModel*)extFuncModel;
@end


@protocol EMMoreFunctionViewDelegate <NSObject>
@optional
- (void)menuExtItemDidSelected:(EaseExtMenuModel*)menuItemModel extType:(ExtType)extType;
@end

@interface EMMoreFunctionView : UIView
@property (nonatomic, weak) id<EMMoreFunctionViewDelegate> delegate;
- (instancetype)initWithextMenuModelArray:(NSMutableArray<EaseExtMenuModel*>*)extMenuModelArray menuViewModel:(EaseExtMenuViewModel*)menuViewModel ;
//视图尺寸
- (CGSize)getExtViewSize;
@end


@protocol SessionToolbarCellDelegate <NSObject>
@required
- (void)toolbarCellDidSelected:(EaseExtMenuModel*)menuItemModel;
@end

@interface SessionToolbarCell : UICollectionViewCell
@property (nonatomic) CGFloat cellLonger;
@property (nonatomic, strong) UIButton *toolBtn;
@property (nonatomic, strong) UILabel *toolLabel;

@property (nonatomic, weak) id<SessionToolbarCellDelegate> delegate;

- (void)setupToolbar;
- (void)personalizeToolbar:(EaseExtMenuModel*)menuItemModel menuViewMode:(EaseExtMenuViewModel*)menuViewModel;//个性化工具栏功能描述
@end

NS_ASSUME_NONNULL_END
