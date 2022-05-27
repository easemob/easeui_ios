//
//  EMsgUserFileCell.h
//  EaseIMKit
//
//  Created by yangjian on 2022/5/28.
//

#import <EaseIMKit/EaseIMKit.h>
#import "EMsgUserBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMsgUserFileCell : EMsgUserBaseCell


@property (nonatomic,strong)UIImageView *fileIconImageView;
@property (nonatomic,strong)UILabel *fileNameLabel;
@property (nonatomic,strong)UILabel *fileSizeLabel;
//@property (nonatomic,strong)UILabel *addressLabel;


@end

NS_ASSUME_NONNULL_END
