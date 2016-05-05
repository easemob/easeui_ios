//
//  EaseBubbleView+Vcard.m
//  EaseUI
//
//  Created by WYZ on 16/4/5.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EaseBubbleView+Vcard.h"

#define BUBBLE_TITLE_HEIGHT          20.0
#define BUBBLE_LINE_HEIGHT           1.0
#define BUBBLE_HEAD_WIDTH            40.0
#define BUBBLE_HEAD_HEIGHT           40.0
#define BUBBLE_MARGIN                10.0


@implementation EaseBubbleView (Vcard)

#pragma mark - private

- (void)_setupTitleConstraints
{
    NSLayoutConstraint *marginTopConstraint = [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeTop multiplier:1.0 constant:self.margin.top];
    
    NSLayoutConstraint *marginHeightConstraint = [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:BUBBLE_TITLE_HEIGHT];

    NSLayoutConstraint *marginLeftConstraint = [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-self.margin.right];
    
    NSLayoutConstraint *marginRightConstraint = [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:self.margin.left];
    
    [self.marginConstraints removeAllObjects];
    [self.marginConstraints addObject:marginTopConstraint];
    [self.marginConstraints addObject:marginHeightConstraint];
    [self.marginConstraints addObject:marginLeftConstraint];
    [self.marginConstraints addObject:marginRightConstraint];
    
    [self addConstraints:self.marginConstraints];
}

- (void)_setupLineBubbleConstraints
{
    [self _setupTitleConstraints];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.lineView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.titleLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.lineView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:BUBBLE_LINE_HEIGHT]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.lineView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.titleLabel attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.lineView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.titleLabel attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
}

- (void)_setupHeadImageBubbleConstraints
{
    [self _setupLineBubbleConstraints];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.headImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.titleLabel attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.headImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeBottom multiplier:0.5 constant:(self.margin.top + BUBBLE_LINE_HEIGHT + BUBBLE_TITLE_HEIGHT - BUBBLE_HEAD_HEIGHT) / 2]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.headImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:BUBBLE_HEAD_WIDTH]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.headImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:BUBBLE_HEAD_HEIGHT]];
}

- (void)_setupNickBubbleConstraints
{
    [self _setupHeadImageBubbleConstraints];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nickLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.headImageView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nickLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:BUBBLE_HEAD_HEIGHT / 2]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nickLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.headImageView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:BUBBLE_HEAD_WIDTH + BUBBLE_MARGIN]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nickLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.titleLabel attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
}

- (void)_setupEmIdBubbleConstraints {
    [self _setupNickBubbleConstraints];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.usernameLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.nickLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.usernameLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:BUBBLE_HEAD_HEIGHT / 2]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.usernameLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.headImageView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:BUBBLE_HEAD_WIDTH + BUBBLE_MARGIN]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.usernameLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.titleLabel attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
}

#pragma mark - public

- (void)setupVcardBubbleView
{
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.font = [UIFont systemFontOfSize:12];
    self.titleLabel.textColor = [UIColor grayColor];
    self.titleLabel.text = NSLocalizedString(@"message.personalVcard", @"personal vcard");
    
    self.lineView = [[UIView alloc] init];
    self.lineView.translatesAutoresizingMaskIntoConstraints = NO;
    self.lineView.backgroundColor = [UIColor lightGrayColor];
    
    self.headImageView = [[UIImageView alloc] init];
    self.headImageView.backgroundColor = [UIColor clearColor];
    self.headImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.nickLabel = [[UILabel alloc] init];
    self.nickLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.nickLabel.backgroundColor = [UIColor clearColor];
    self.nickLabel.font = [UIFont systemFontOfSize:15];
    self.nickLabel.textColor = [UIColor grayColor];
    
    self.usernameLabel = [[UILabel alloc] init];
    self.usernameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.usernameLabel.backgroundColor = [UIColor clearColor];
    self.usernameLabel.font = [UIFont systemFontOfSize:12];
    self.usernameLabel.textColor = [UIColor grayColor];
    
    [self.backgroundImageView addSubview:self.titleLabel];
    [self.backgroundImageView addSubview:self.lineView];
    [self.backgroundImageView addSubview:self.headImageView];
    [self.backgroundImageView addSubview:self.nickLabel];
    [self.backgroundImageView addSubview:self.usernameLabel];
    self.backgroundImageView.userInteractionEnabled = YES;
    
    [self _setupEmIdBubbleConstraints];
}

- (void)updateVcardMargin:(UIEdgeInsets)margin
{
    if (_margin.top == margin.top && _margin.bottom == margin.bottom && _margin.left == margin.left && _margin.right == margin.right) {
        return;
    }
    _margin = margin;
    
    [self removeConstraints:self.marginConstraints];
    [self _setupEmIdBubbleConstraints];
}

@end
