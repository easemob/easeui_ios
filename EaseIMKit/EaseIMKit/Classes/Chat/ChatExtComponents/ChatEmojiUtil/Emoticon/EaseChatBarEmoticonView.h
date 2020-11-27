//
//  EaseChatBarEmoticonView.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/30.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EaseEmoticonGroup.h"

NS_ASSUME_NONNULL_BEGIN

@protocol EaseChatBarEmoticonViewDelegate;
@interface EaseChatBarEmoticonView : UIView

@property (nonatomic, weak) id<EaseChatBarEmoticonViewDelegate> delegate;

@property (nonatomic, readonly) CGFloat viewHeight;

@end


@protocol EaseChatBarEmoticonViewDelegate <NSObject>

@optional

- (void)didSelectedEmoticonModel:(EaseEmoticonModel *)aModel;

- (void)didSelectedTextDetele;

@end

NS_ASSUME_NONNULL_END
