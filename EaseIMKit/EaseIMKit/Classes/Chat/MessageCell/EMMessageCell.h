//
//  EMMessageCell.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/25.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EMMessageModel.h"
#import "EMMessageBubbleView.h"
#import "EMViewModel.h"


#define avatarLonger 40
#define componentSpacing 10

NS_ASSUME_NONNULL_BEGIN

@protocol EMMessageCellDelegate;
@interface EMMessageCell : UITableViewCell

@property (nonatomic, weak) id<EMMessageCellDelegate> delegate;

@property (nonatomic, strong, readonly) EMMessageBubbleView *bubbleView;

@property (nonatomic) EMMessageDirection direction;

@property (nonatomic, strong) EMMessageModel *model;

+ (NSString *)cellIdentifierWithDirection:(EMMessageDirection)aDirection
                                     type:(EMMessageType)aType;

- (instancetype)initWithDirection:(EMMessageDirection)aDirection
                             type:(EMMessageType)aType
                        viewModel:(EMViewModel*)viewModel;

@end


@protocol EMMessageCellDelegate <NSObject>

@optional
- (void)messageCellDidSelected:(EMMessageCell *)aCell;

- (void)messageCellDidLongPress:(EMMessageCell *)aCell;

- (void)messageCellDidResend:(EMMessageModel *)aModel;

- (void)messageReadReceiptDetil:(EMMessageCell *)aCell;

@end

NS_ASSUME_NONNULL_END
