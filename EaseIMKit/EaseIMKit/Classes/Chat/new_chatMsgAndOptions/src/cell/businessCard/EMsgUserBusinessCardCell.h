//
//  EMsgUserBusinessCardCell.h
//  EaseIMKit
//
//  Created by yangjian on 2022/5/25.
//

#import <EaseIMKit/EaseIMKit.h>
#import "EMsgUserBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMsgUserBusinessCardCell : EMsgUserBaseCell

@property (nonatomic,strong)UIImageView *cardHeadImageView;
@property (nonatomic,strong)UILabel *cardNameLabel;
//@property (nonatomic,strong)UILabel *addressLabel;

@end

NS_ASSUME_NONNULL_END
