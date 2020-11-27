//
//  EMMessageCell.h
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

@protocol EMMessageCellDelegate;
@interface EMMessageCell : UITableViewCell

@property (nonatomic, weak) id<EMMessageCellDelegate> delegate;

@property (nonatomic, strong, readonly) EMMessageBubbleView *bubbleView;

@property (nonatomic) EMMessageDirection direction;

@property (nonatomic, strong) EaseMessageModel *model;

+ (NSString *)cellIdentifierWithDirection:(EMMessageDirection)aDirection
                                     type:(EMMessageType)aType;

- (instancetype)initWithDirection:(EMMessageDirection)aDirection
                             type:(EMMessageType)aType
                        viewModel:(EaseChatViewModel*)viewModel;

@end


@protocol EMMessageCellDelegate <NSObject>

@optional
- (void)messageCellDidSelected:(EMMessageCell *)aCell;
- (void)messageCellDidLongPress:(UITableViewCell *)aCell;
- (void)messageCellDidResend:(EaseMessageModel *)aModel;
- (void)messageReadReceiptDetil:(EMMessageCell *)aCell;

- (void)avatarDidSelected:(EaseMessageModel *)model;
- (void)avatarDidLongPress:(EaseMessageModel *)model;

@end

NS_ASSUME_NONNULL_END
