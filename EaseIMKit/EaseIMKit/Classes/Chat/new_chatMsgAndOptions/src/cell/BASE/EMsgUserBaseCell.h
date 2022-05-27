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

@end

NS_ASSUME_NONNULL_END
