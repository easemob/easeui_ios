//
//  EMMessageReactionView.h
//  EaseIMKit
//
//  Created by 冯钊 on 2022/2/11.
//

#import <UIKit/UIKit.h>

@import HyphenateChat;
@class EMMessageReaction;

NS_ASSUME_NONNULL_BEGIN

@interface EMMessageReactionView : UIView

@property (nonatomic, assign) EMMessageDirection direction;
@property (nonatomic, strong) NSArray<EMMessageReaction *> *reactionList;

@end

NS_ASSUME_NONNULL_END
