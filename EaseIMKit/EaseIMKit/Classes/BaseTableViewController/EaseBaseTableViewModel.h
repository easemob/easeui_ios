//
//  EaseBaseTableViewModel.h
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/11/11.
//

#import <Foundation/Foundation.h>
#import "EaseCommonEnum.h"

NS_ASSUME_NONNULL_BEGIN

@interface EaseBaseTableViewModel : NSObject

@property (nonatomic) BOOL canRefresh;
@property (nonatomic) CGFloat cellHeight;
@property (nonatomic, copy) UIColor *cellBgColor; //cell皮肤
@property (nonatomic, copy) UIColor *viewBgColor; //页面皮肤

@property (nonatomic) EaseAvatarStyle avatarType;
@property (nonatomic) CGSize avatarSize;
@property (nonatomic) UIEdgeInsets avatarEdgeInsets;
@end

NS_ASSUME_NONNULL_END
