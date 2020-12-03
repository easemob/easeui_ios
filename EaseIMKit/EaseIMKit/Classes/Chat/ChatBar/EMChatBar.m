//
//  EMChatBar.m
//  ChatDemo-UI3.0
//
//  Updated by zhangchong on 2020/06/05.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMChatBar.h"
#import "UIImage+EaseUI.h"
#import "EaseDefines.h"

#define kTextViewMinHeight 32
#define kTextViewMaxHeight 80
#define kIconwidth 22
#define kModuleMargin 10

@interface EMChatBar()<UITextViewDelegate>

@property (nonatomic) CGFloat version;

@property (nonatomic) CGFloat previousTextViewContentHeight;

@property (nonatomic, strong) UIButton *selectedButton;

@property (nonatomic, strong) UIView *currentMoreView;

@property (nonatomic, strong) UIButton *conversationToolBarBtn;//更多

@property (nonatomic, strong) UIButton *emojiButton;//表情

@property (nonatomic, strong) UIButton *audioButton;//语音

@property (nonatomic, strong) UIView *bottomLine;//下划线

@property (nonatomic, strong) EaseChatViewModel *viewModel;

@end

@implementation EMChatBar

- (instancetype)initWithViewModel:(EaseChatViewModel *)viewModel
{
    self = [super init];
    if (self) {
        _version = [[[UIDevice currentDevice] systemVersion] floatValue];
        _previousTextViewContentHeight = kTextViewMinHeight;
        _viewModel = viewModel;
        [self _setupSubviews];
    }
    
    return self;
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    self.backgroundColor = _viewModel.chatBarBgColor;
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = kColor_Gray;
    [self addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.height.equalTo(@0.5);
    }];
    
    self.audioButton = [[UIButton alloc] init];
    [_audioButton setBackgroundImage:[UIImage easeUIImageNamed:@"audio-unSelected"] forState:UIControlStateNormal];
    [_audioButton setBackgroundImage:[UIImage easeUIImageNamed:@"character"] forState:UIControlStateSelected];
    [_audioButton addTarget:self action:@selector(audioButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.audioButton];
    [_audioButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(10);
        make.left.equalTo(self).offset(16);
        make.width.mas_equalTo(@16);
        make.height.mas_equalTo(kIconwidth);
    }];
    
    self.conversationToolBarBtn = [[UIButton alloc] init];
    [_conversationToolBarBtn setBackgroundImage:[UIImage easeUIImageNamed:@"more-unselected"] forState:UIControlStateNormal];
    [_conversationToolBarBtn setBackgroundImage:[UIImage easeUIImageNamed:@"more-selected"] forState:UIControlStateSelected];
    [_conversationToolBarBtn addTarget:self action:@selector(moreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_conversationToolBarBtn];
    [_conversationToolBarBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(10);
        make.right.equalTo(self).offset(-16);
        make.width.height.mas_equalTo(kIconwidth);
    }];
    
    self.emojiButton = [[UIButton alloc] init];
    [_emojiButton setBackgroundImage:[UIImage easeUIImageNamed:@"face"] forState:UIControlStateNormal];
    [_emojiButton setBackgroundImage:[UIImage easeUIImageNamed:@"character"] forState:UIControlStateSelected];
    [_emojiButton addTarget:self action:@selector(emoticonButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_emojiButton];
    [_emojiButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(10);
        make.right.equalTo(self.conversationToolBarBtn.mas_left).offset(-kModuleMargin);
        make.width.height.mas_equalTo(kIconwidth);
    }];
    
    self.textView = [[EaseTextView alloc] init];
    self.textView.delegate = self;
    [self.textView setTextColor:[UIColor blackColor]];
    self.textView.font = [UIFont systemFontOfSize:16];
    self.textView.textAlignment = NSTextAlignmentLeft;
    self.textView.textContainerInset = UIEdgeInsetsMake(10, 10, 12, 0);
    if (@available(iOS 11.1, *)) {
        self.textView.verticalScrollIndicatorInsets = UIEdgeInsetsMake(12, 20, 2, 0);
    } else {
        // Fallback on earlier versions
    }
    self.textView.returnKeyType = UIReturnKeySend;
    self.textView.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
    self.textView.layer.cornerRadius = 16;
    [self addSubview:self.textView];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(5);
        make.height.mas_equalTo(kTextViewMinHeight);
        if (_viewModel.inputBarStyle == EaseInputBarStyleAll) {
            make.left.equalTo(self.audioButton.mas_right).offset(kModuleMargin);
            make.right.equalTo(self.emojiButton.mas_left).offset(-kModuleMargin);
        }
        if (_viewModel.inputBarStyle == EaseInputBarStyleNoAudio) {
            make.left.equalTo(self).offset(16);
            make.right.equalTo(self.emojiButton.mas_left).offset(-kModuleMargin);
        }
        if (_viewModel.inputBarStyle == EaseInputBarStyleNoEmoji) {
            make.left.equalTo(self.audioButton.mas_right).offset(kModuleMargin);
            make.right.equalTo(self.conversationToolBarBtn.mas_left).offset(-kModuleMargin);
        }
        if (_viewModel.inputBarStyle == EaseInputBarStyleNoAudioAndEmoji) {
            make.left.equalTo(self).offset(16);
            make.right.equalTo(self.conversationToolBarBtn.mas_left).offset(-kModuleMargin);
        }
        if (_viewModel.inputBarStyle == EaseInputBarStyleOnlyText) {
            make.left.equalTo(self).offset(16);
            make.right.equalTo(self).offset(-16);
        }
    }];
    
    self.bottomLine = [[UIView alloc] init];
    _bottomLine.backgroundColor = kColor_Gray;
    [self addSubview:self.bottomLine];
    [_bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.textView.mas_bottom).offset(5);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.height.equalTo(@0.5);
        make.bottom.equalTo(self).offset(-EMVIEWBOTTOMMARGIN);
    }];
    self.currentMoreView.backgroundColor = kColor_ExtFunctionView;
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (self.currentMoreView) {
        [self.currentMoreView removeFromSuperview];
        [self.bottomLine mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self).offset(-EMVIEWBOTTOMMARGIN);
        }];
    }
    
    self.emojiButton.selected = NO;
    self.conversationToolBarBtn.selected = NO;
    self.audioButton.selected = NO;
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(textView:shouldInteractWithURL:inRange:)]) {
        return [self.delegate textView:textView shouldChangeTextInRange:range replacementText:text];
    }
    if ([text isEqualToString:@"\n"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(chatBarSendMsgAction:)]) {
            [self.delegate chatBarSendMsgAction:self.textView.text];
        }
        //[textView resignFirstResponder];
        return NO;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputView:shouldChangeTextInRange:replacementText:)]) {
        return [self.delegate inputView:self.textView shouldChangeTextInRange:range replacementText:text];
    } 
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self _updatetextViewHeight];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputViewDidChange:)]) {
        [self.delegate inputViewDidChange:self.textView];
    }
}

#pragma mark - Private

- (CGFloat)_gettextViewContontHeight
{
    if (self.version >= 7.0) {
        return ceilf([self.textView sizeThatFits:self.textView.frame.size].height);
    } else {
        return self.textView.contentSize.height;
    }
}

- (void)_updatetextViewHeight
{
    CGFloat height = [self _gettextViewContontHeight];
    if (height < kTextViewMinHeight) {
        height = kTextViewMinHeight;
    }
    if (height > kTextViewMaxHeight) {
        height = kTextViewMaxHeight;
    }
    
    if (height == self.previousTextViewContentHeight) {
        return;
    }
    
    self.previousTextViewContentHeight = height;
    [self.textView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
}

- (void)_remakeButtonsViewConstraints
{
    if (self.currentMoreView) {
        [self.bottomLine mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.textView.mas_bottom).offset(5);
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.height.equalTo(@1);
            make.bottom.equalTo(self.currentMoreView.mas_top);
        }];
    } else {
        [self.bottomLine mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.textView.mas_bottom).offset(5);
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.height.equalTo(@1);
            make.bottom.equalTo(self).offset(-EMVIEWBOTTOMMARGIN);
        }];
    }
}

#pragma mark - Public

- (void)clearInputViewText
{
    self.textView.text = @"";
    [self _updatetextViewHeight];
}

- (void)inputViewAppendText:(NSString *)aText
{
    if ([aText length] > 0) {
        self.textView.text = [NSString stringWithFormat:@"%@%@", self.textView.text, aText];
        [self _updatetextViewHeight];
    }
}

- (void)deleteTailText
{
    if ([self.textView.text length] > 0) {
        NSRange range = [self.textView.text rangeOfComposedCharacterSequenceAtIndex:self.textView.text.length-1];
        self.textView.text = [self.textView.text substringToIndex:range.location];
    }
}

- (void)clearMoreViewAndSelectedButton
{
    if (self.currentMoreView) {
        [self.currentMoreView removeFromSuperview];
        self.currentMoreView = nil;
        [self _remakeButtonsViewConstraints];
    }
    
    if (self.selectedButton) {
        self.selectedButton.selected = NO;
        self.selectedButton = nil;
    }
}

#pragma mark - Action

- (BOOL)_buttonAction:(UIButton *)aButton
{
    BOOL isEditing = NO;
    [self.textView resignFirstResponder];
    if (self.currentMoreView) {
        [self.currentMoreView removeFromSuperview];
        self.currentMoreView = nil;
        [self _remakeButtonsViewConstraints];
    }
    
    if (self.selectedButton != aButton) {
        self.selectedButton.selected = NO;
        self.selectedButton = nil;
        self.selectedButton = aButton;
        [aButton setSelected:!aButton.selected];
    } else {
        self.selectedButton = nil;
        if (aButton.isSelected) {
            [self.textView becomeFirstResponder];
            isEditing = YES;
        }
    }
    if (aButton.selected) {
        self.selectedButton = aButton;
    }
    return isEditing;
}

//语音
- (void)audioButtonAction:(UIButton *)aButton
{
    if (aButton.isSelected) {
        [self.audioButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(@16);
        }];
    } else {
        [self.audioButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(kIconwidth);
        }];
    }
    if([self _buttonAction:aButton]) {
        return;
    }
    if (aButton.selected) {
        if (self.recordAudioView) {
            self.currentMoreView = self.recordAudioView;
            [self addSubview:self.recordAudioView];
            [self.recordAudioView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self);
                make.right.equalTo(self);
                make.bottom.equalTo(self).offset(-EMVIEWBOTTOMMARGIN);
            }];
            [self _remakeButtonsViewConstraints];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(chatBarDidShowMoreViewAction)]) {
                [self.delegate chatBarDidShowMoreViewAction];
            }
        }
    }
}

//表情
- (void)emoticonButtonAction:(UIButton *)aButton
{
    if([self _buttonAction:aButton]) {
        return;
    }
    if (aButton.selected) {
        if (self.moreEmoticonView) {
            self.currentMoreView = self.moreEmoticonView;
            [self addSubview:self.moreEmoticonView];
            [self.moreEmoticonView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self);
                make.right.equalTo(self);
                make.bottom.equalTo(self).offset(-EMVIEWBOTTOMMARGIN);
                make.height.mas_equalTo(self.moreEmoticonView.viewHeight);
            }];
            [self _remakeButtonsViewConstraints];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(chatBarDidShowMoreViewAction)]) {
                [self.delegate chatBarDidShowMoreViewAction];
            }
        }
    }
}

//更多
- (void)moreButtonAction:(UIButton *)aButton
{
    if([self _buttonAction:aButton]) {
        return;
    }
    if (aButton.selected){
        if(self.moreFunctionView) {
            self.currentMoreView = self.moreFunctionView;
            [self addSubview:self.moreFunctionView];
            [self.moreFunctionView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self);
                make.right.equalTo(self);
                make.bottom.equalTo(self).offset(-EMVIEWBOTTOMMARGIN);
                make.height.mas_equalTo(@200);
            }];
            [self _remakeButtonsViewConstraints];
            if (self.delegate && [self.delegate respondsToSelector:@selector(chatBarDidShowMoreViewAction)]) {
                [self.delegate chatBarDidShowMoreViewAction];
            }
        }
    }
}

@end
