//
//  EaseMessageQuoteView.h
//  EaseIMKit
//
//  Created by 冯钊 on 2023/4/26.
//

#import <HyphenateChat/HyphenateChat.h>

NS_ASSUME_NONNULL_BEGIN

@protocol EaseMessageQuoteViewDelegate <NSObject>
@optional
- (NSAttributedString *)quoteViewShowContent:(EMChatMessage *)message;

@end

@interface EaseMessageQuoteView : UIView

@property (nonatomic, weak) id<EaseMessageQuoteViewDelegate> delegate;

@property (nonatomic, copy) EMChatMessage *message;

@end

NS_ASSUME_NONNULL_END
