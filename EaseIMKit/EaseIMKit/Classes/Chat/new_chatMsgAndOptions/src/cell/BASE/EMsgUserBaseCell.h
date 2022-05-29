//
//  EMsgUserBaseCell.h
//  EaseIMKit
//
//  Created by yangjian on 2022/5/18.
//

#import "EMsgBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMsgUserBaseCell : EMsgBaseCell

@property (nonatomic,strong)UIView *customBackgroundView;
@property (nonatomic,strong)UIImageView *headImageView;
@property (nonatomic,strong)UILabel *nameLabel;
@property (nonatomic,strong)UIView *msgBackgroundView;

@property (nonatomic)EMMessageDirection currentDirection;

- (void)resetSubViewsLayout:(EMMessageDirection)direction
                   showHead:(BOOL)showHead
                   showName:(BOOL)showName;

//子类重构,由子类调用 [super function:];  常规为气泡添加手势,特殊情况下没有气泡时可能添加其他位置手势.
- (void)messageTapGestureClick:(UITapGestureRecognizer *)tapGesture;
- (void)messagePressGestureClick:(UILongPressGestureRecognizer *)longPressGesture;

//给定一个长按的view(可重写返回一个合适的view,默认为msssageBackgroundView)
- (UIView *)longPressView;

@end


@protocol EMsgUserBaseCellDelegate <NSObject>
@optional
//消息部分点击与长按
- (void)userMessageDidSelected:(EMsgUserBaseCell *)cell model:(EMsgBaseCellModel*)model;
- (void)userMessageDidLongPress:(EMsgUserBaseCell *)cell model:(EMsgBaseCellModel*)model cgPoint:(CGPoint)point;

//消息重发
- (void)userMessageCellDidResend:(EMsgUserBaseCell *)cell model:(EMsgBaseCellModel*)model;

//消息??
- (void)userMessageReadReceiptDetil:(EMsgUserBaseCell *)cell model:(EMsgBaseCellModel*)model;

//头像部分点击与长按
- (void)userMessageHeadDidSelected:(EMsgUserBaseCell *)cell model:(EMsgBaseCellModel *)model;
- (void)userMessageHeadDidLongPress:(EMsgUserBaseCell *)cell model:(EMsgBaseCellModel *)model;

@end




NS_ASSUME_NONNULL_END
