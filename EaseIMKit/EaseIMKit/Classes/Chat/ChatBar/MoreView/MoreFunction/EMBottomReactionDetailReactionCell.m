//
//  EMBottomReactionDetailReactionCell.m
//  EaseIMKit
//
//  Created by 冯钊 on 2022/2/24.
//

#import "EMBottomReactionDetailReactionCell.h"

#import "UIImage+EaseUI.h"

@interface EMBottomReactionDetailReactionCell ()

@property (weak, nonatomic) IBOutlet UIImageView *reactionImageView;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UIView *bgView;

@end

@implementation EMBottomReactionDetailReactionCell

- (void)setReaction:(NSString *)reaction {
    _reaction = reaction;
    _reactionImageView.image = [UIImage easeUIImageNamed:reaction];
}

- (void)setCount:(NSInteger)count {
    _count = count;
    _countLabel.text = [NSString stringWithFormat:@"%ld", (long)_count];
}

- (void)setReactionSelected:(BOOL)reactionSelected {
    _reactionSelected = reactionSelected;
    _bgView.hidden = !reactionSelected;
}

@end
