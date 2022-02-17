//
//  EMMessageReactionView.m
//  EaseIMKit
//
//  Created by 冯钊 on 2022/2/11.
//

#import "EMMessageReactionView.h"

#import "View+EaseAdditions.h"

@import HyphenateChat;

@interface EMMessageReactionView ()

@property (nonatomic, strong) NSMutableArray<UILabel *> *labels;

@end

@implementation EMMessageReactionView

- (void)setReactionList:(NSArray<EMMessageReaction *> *)reactionList {
    _reactionList = reactionList;
    [self Ease_updateConstraints:^(EaseConstraintMaker *make) {
        make.height.Ease_equalTo(reactionList.count * 30);
    }];
    
    if (reactionList.count > 0) {
        if (!self.labels) {
            self.labels = [NSMutableArray array];
        }
        if (self.labels.count < reactionList.count) {
            unsigned long loopCount = reactionList.count - self.labels.count;
            for (int i = 0; i < loopCount; i ++) {
                UILabel *label = [[UILabel alloc] init];
                [self addSubview:label];
                [self.labels addObject:label];
            }
        }
    }
    
    for (int i = 0; i < self.labels.count; i ++) {
        if (reactionList.count > i) {
            self.labels[i].textAlignment = self.direction == EMMessageDirectionSend ? NSTextAlignmentRight : NSTextAlignmentLeft;
            self.labels[i].hidden = NO;
            self.labels[i].text = [NSString stringWithFormat:@"%@ * %d", reactionList[i].reaction, (int)reactionList[i].count];
            self.labels[i].frame = CGRectMake(0, 30 * i, 100, 30);
        } else {
            self.labels[i].hidden = YES;
        }
    }
    
}

@end
