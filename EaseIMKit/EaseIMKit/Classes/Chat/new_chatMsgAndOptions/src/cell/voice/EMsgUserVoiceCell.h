//
//  EMsgUserVoiceCell.h
//  EaseIMKit
//
//  Created by yangjian on 2022/5/26.
//

#import <EaseIMKit/EaseIMKit.h>
#import "EMsgUserBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMsgUserVoiceCell : EMsgUserBaseCell

@property (nonatomic,strong)UIImageView *waveImageView;
@property (nonatomic,strong)UILabel *durationLabel;
@property (nonatomic,strong)UILabel *convertTextLabel;

- (void)playing:(BOOL)playing;

@end

NS_ASSUME_NONNULL_END
