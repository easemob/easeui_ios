//
//  EaseMessageCell.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/25.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EaseMessageModel.h"
#import "EMMessageBubbleView.h"
#import "EaseChatViewModel.h"

#define avatarLonger 40
#define componentSpacing 10

NS_ASSUME_NONNULL_BEGIN

@protocol EaseMessageCellDelegate;
@interface EaseMessageCell : UITableViewCell

@property (nonatomic, weak) id<EaseMessageCellDelegate> delegate;

@property (nonatomic, strong, readonly) EMMessageBubbleView *bubbleView;

@property (nonatomic) EMMessageDirection direction;

@property (nonatomic, strong) EaseMessageModel *model;

+ (NSString *)cellIdentifierWithDirection:(EMMessageDirection)aDirection
                                     type:(EMMessageType)aType;

- (instancetype)initWithDirection:(EMMessageDirection)aDirection
                    chatType:(EMChatType)aChatType
                  messageType:(EMMessageType)aMessageType
                    viewModel:(EaseChatViewModel*)viewModel;

- (void)setStatusHidden:(BOOL)isHidden;

@end


@protocol EaseMessageCellDelegate <NSObject>

@optional
- (void)messageCellDidSelected:(EaseMessageCell *)aCell;
- (void)messageCellDidLongPress:(UITableViewCell *)aCell cgPoint:(CGPoint)point;
- (void)messageCellDidResend:(EaseMessageModel *)aModel;
- (void)messageReadReceiptDetil:(EaseMessageCell *)aCell;

- (void)avatarDidSelected:(EaseMessageModel *)model;
- (void)avatarDidLongPress:(EaseMessageModel *)model;

@end

NS_ASSUME_NONNULL_END
