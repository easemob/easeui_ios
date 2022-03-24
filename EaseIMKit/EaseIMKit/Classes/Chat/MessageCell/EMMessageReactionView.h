//
//  EMMessageReactionView.h
//  EaseIMKit
//
//  Created by 冯钊 on 2022/2/11.
//

#import <UIKit/UIKit.h>

@import HyphenateChat;

NS_ASSUME_NONNULL_BEGIN

@interface EMMessageReactionView : UIView

@property (nonatomic, assign) EMMessageDirection direction;
@property (nonatomic, strong) NSArray<EMMessageReaction *> *reactionList;
@property (nonatomic, strong) void(^onClick)(void);

@end

NS_ASSUME_NONNULL_END
