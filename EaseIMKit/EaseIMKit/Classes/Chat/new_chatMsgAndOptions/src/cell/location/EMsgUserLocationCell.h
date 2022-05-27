//
//  EMsgUserLocationCell.h
//  EaseIMKit
//
//  Created by yangjian on 2022/5/19.
//

#import <EaseIMKit/EaseIMKit.h>
#import "EMsgUserBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMsgUserLocationCell : EMsgUserBaseCell

@property (nonatomic,strong)UIImageView *mapImageView;
@property (nonatomic,strong)UILabel *locationNameLabel;
@property (nonatomic,strong)UILabel *addressLabel;

@end

NS_ASSUME_NONNULL_END
