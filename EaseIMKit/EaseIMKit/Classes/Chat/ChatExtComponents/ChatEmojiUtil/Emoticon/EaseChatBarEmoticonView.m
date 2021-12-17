//
//  EaseChatBarEmoticonView.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/30.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EaseChatBarEmoticonView.h"
#import "UIImage+EaseUI.h"
#import "EaseHeaders.h"
#import "EaseEmojiHelper.h"

@interface EaseChatBarEmoticonView()<EMEmoticonViewDelegate>

@property (nonatomic) CGFloat bottomHeight;

@property (nonatomic, strong) NSMutableArray<EaseEmoticonGroup *> *groups;
@property (nonatomic, strong) NSMutableArray<EMEmoticonView *> *emotionViews;
@property (nonatomic, strong) NSMutableArray<UIButton *> *emotionButtons;
@property (nonatomic, strong) UIButton *selectedButton;

@property (nonatomic, strong) UIView *emotionBgView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIScrollView *bottomScrollView;
@property (nonatomic, strong) UIButton *extBtn;
@property (nonatomic, strong) UIButton *deleteBtn;
@property (nonatomic, strong) UIButton *sendBtn;

@end

@implementation EaseChatBarEmoticonView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _initDataSource];
        [self _setupSubviews];
        [self segmentedButtonAction:self.emotionButtons[0]];
    }
    
    return self;
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    [self _setupBottomView];
    [self _setupEmotionViews];
}

- (void)_setupBottomView
{
    CGFloat itemWidth = 60;
    NSInteger count = [self.groups count];
    
    self.bottomView = [[UIView alloc] init];
    self.bottomView.backgroundColor = [UIColor whiteColor];;
    [self addSubview:self.bottomView];
    [self.bottomView Ease_makeConstraints:^(EaseConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.bottom.equalTo(self);
        make.height.Ease_equalTo(self.bottomHeight);
    }];
    
    self.sendBtn = [[UIButton alloc]init];
    self.sendBtn.layer.cornerRadius = 8;
    [self.sendBtn setTitle:EaseLocalizableString(@"send", nil) forState:UIControlStateNormal];
    [self.sendBtn.titleLabel setFont:[UIFont systemFontOfSize:14.f]];
    [self.sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.sendBtn setTitleColor:[UIColor colorWithHexString:@"#ADADAD"] forState:UIControlStateDisabled];
    [self.sendBtn addTarget:self action:@selector(sendEmoticonAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.extBtn = [[UIButton alloc] init];
    [self.extBtn setBackgroundImage:[UIImage easeUIImageNamed:@"EmojiExt"] forState:UIControlStateNormal];
    
    self.deleteBtn = [[UIButton alloc]init];
    self.deleteBtn.backgroundColor = [UIColor clearColor];
    [self.deleteBtn setBackgroundImage:[UIImage easeUIImageNamed:@"deleteEmoticon"] forState:UIControlStateNormal];
    [self.deleteBtn setBackgroundImage:[UIImage easeUIImageNamed:@"deleteEmoticonDisable"] forState:UIControlStateDisabled];
    [self.deleteBtn addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.bottomScrollView = [[UIScrollView alloc] init];
    self.bottomScrollView.scrollEnabled = NO;
    self.bottomScrollView.backgroundColor = [UIColor whiteColor];;
    self.bottomScrollView.contentSize = CGSizeMake(itemWidth * count, self.bottomHeight);
    [self addSubview:self.bottomScrollView];
    [self.bottomScrollView Ease_makeConstraints:^(EaseConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    for (int i = 0; i < count; i++) {
        UIButton *button = [[UIButton alloc] init];
        button.tag = i;
        [button addTarget:self action:@selector(segmentedButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomScrollView addSubview:button];
        [button Ease_makeConstraints:^(EaseConstraintMaker *make) {
            make.top.equalTo(self.bottomView);
            make.left.equalTo(self.bottomView).offset(i * itemWidth);
            make.width.Ease_equalTo(itemWidth);
            make.height.Ease_equalTo(self.bottomHeight);
        }];
        
        id icon = [self.groups[i] icon];
        if ([icon isKindOfClass:[UIImage class]]) {
            button.imageEdgeInsets = UIEdgeInsetsMake(5, 0, 5, 0);
            button.imageView.contentMode = UIViewContentModeScaleAspectFit;
            [button setImage:(UIImage *)icon forState:UIControlStateNormal];
        } else if ([icon isKindOfClass:[NSString class]]) {
            button.titleLabel.font = [UIFont fontWithName:@"AppleColorEmoji" size:18.0];
            [button setTitle:(NSString *)icon forState:UIControlStateNormal];
        }
        [self.emotionButtons addObject:button];
    }
}

- (void)_setupEmotionViews
{
    self.emotionBgView = [[UIView alloc] init];
    self.emotionBgView.backgroundColor = [UIColor colorWithHexString:@"#EAEBEC"];
    [self addSubview:self.emotionBgView];
    [self.emotionBgView Ease_makeConstraints:^(EaseConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.bottom.equalTo(self.bottomView.ease_top);
    }];
    
    NSInteger count = [self.groups count];
    for (int i = 0; i < count; i++) {
        EMEmoticonView *view = [[EMEmoticonView alloc] initWithEmotionGroup:self.groups[i]];
        view.delegate = self;
        view.viewHeight = self.viewHeight - self.bottomHeight;
        [self.emotionViews addObject:view];
    }
}

#pragma mark - Data

- (void)_initDataSource
{
    _viewHeight = 200;
    _bottomHeight = 40;
    self.groups = [[NSMutableArray alloc] init];
    self.emotionViews = [[NSMutableArray alloc] init];
    self.emotionButtons = [[NSMutableArray alloc] init];
    
    NSArray *emojis = [EaseEmojiHelper getAllEmojis];
    NSMutableArray *models1 = [[NSMutableArray alloc] init];
    for (NSString *emoji in emojis) {
        EaseEmoticonModel *model = [[EaseEmoticonModel alloc] initWithType:EMEmotionTypeEmoji];
        model.eId = emoji;
        model.name = emoji;
        model.original = emoji;
        [models1 addObject:model];
    }
    NSString *tagImgName = [models1[0] name];
    EaseEmoticonGroup *group1 = [[EaseEmoticonGroup alloc] initWithType:EMEmotionTypeEmoji dataArray:models1 icon:tagImgName rowCount:3 colCount:7];
    [self.groups addObject:group1];
    
    [self.groups addObject:[EaseEmoticonGroup getGifGroup]];
}

#pragma mark - EMEmoticonViewDelegate

- (void)emoticonViewDidSelectedModel:(EaseEmoticonModel *)aModel
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectedEmoticonModel:)]) {
        [self.delegate didSelectedEmoticonModel:aModel];
    }
}

#pragma mark - Action

- (void)sendEmoticonAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didChatBarEmoticonViewSendAction)]) {
        [self.delegate didChatBarEmoticonViewSendAction];
    }
}

- (void)segmentedButtonAction:(UIButton *)aButton
{
    NSInteger tag = aButton.tag;
    if (self.selectedButton && self.selectedButton.tag == tag) {
        return;
    }
    
    if (self.selectedButton) {
        EMEmoticonView *oldView = self.emotionViews[self.selectedButton.tag];
        [oldView removeFromSuperview];
        
        self.selectedButton.selected = NO;
        self.selectedButton.backgroundColor = [UIColor whiteColor];
        self.selectedButton = nil;
    }
    
    aButton.selected = YES;
    aButton.backgroundColor = [UIColor colorWithHexString:@"#F2F2F2"];
    self.selectedButton = aButton;
    
    if (tag == 0) {
        [self.bottomView addSubview:self.extBtn];
        [self.extBtn Ease_makeConstraints:^(EaseConstraintMaker *make) {
            make.top.equalTo(self.bottomView).offset(11);
            make.right.equalTo(self.bottomView.ease_right).offset(-22);
            make.width.height.Ease_equalTo(@18);
        }];
        [self.bottomScrollView Ease_remakeConstraints:^(EaseConstraintMaker *make) {
            make.left.equalTo(self);
            make.right.equalTo(self.extBtn.ease_left);
            make.bottom.equalTo(self);
            make.height.Ease_equalTo(self.bottomHeight);
        }];
        [self addSubview:self.sendBtn];
        [self.sendBtn Ease_makeConstraints:^(EaseConstraintMaker *make) {
            make.bottom.equalTo(self.bottomView.ease_top).offset(-12);
            make.right.equalTo(self.bottomView.ease_right).offset(-12);
            make.width.Ease_equalTo(@40);
            make.height.Ease_equalTo(@30);
        }];
        [self addSubview:self.deleteBtn];
        [self.deleteBtn Ease_makeConstraints:^(EaseConstraintMaker *make) {
            make.bottom.equalTo(self.bottomView.ease_top).offset(-12);
            make.right.equalTo(self.sendBtn.ease_left).offset(-22);
            make.width.Ease_equalTo(@28);
            make.height.Ease_equalTo(@28);
        }];
    } else {
        [self.sendBtn removeFromSuperview];
        [self.extBtn removeFromSuperview];
        [self.deleteBtn removeFromSuperview];
        [self.bottomScrollView Ease_remakeConstraints:^(EaseConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    
    //TODO:code
    EMEmoticonView *view = self.emotionViews[tag];
    [self.emotionBgView addSubview:view];
    [view Ease_makeConstraints:^(EaseConstraintMaker *make) {
        make.edges.equalTo(self.emotionBgView);
    }];
}

- (void)deleteAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectedTextDetele)]) {
        BOOL isEditing = [self.delegate didSelectedTextDetele];
        [self textDidChange:isEditing];
    }
}

- (void)textDidChange:(BOOL)isEditing
{
    if (!isEditing) {
        self.sendBtn.backgroundColor = [UIColor whiteColor];
        self.sendBtn.enabled = NO;
        self.deleteBtn.enabled = NO;
    } else {
        [self.sendBtn setBackgroundColor:[UIColor colorWithHexString:@"#04AEF0"]];
        self.sendBtn.enabled = YES;
        self.deleteBtn.enabled = YES;
    }
}

@end
