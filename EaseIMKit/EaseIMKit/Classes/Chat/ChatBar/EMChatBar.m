//
//  EMChatBar.m
//  ChatDemo-UI3.0
//
//  Updated by zhangchong on 2020/06/05.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMChatBar.h"
#import "UIImage+EaseUI.h"
#import "UIColor+EaseUI.h"

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
//@property (nonatomic, strong) UIButton *audioDescBtn;
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
    line.backgroundColor = [UIColor colorWithHexString:@"#000000"];
    line.alpha = 0.1;
    [self addSubview:line];
    [line Ease_makeConstraints:^(EaseConstraintMaker *make) {
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
    [_audioButton Ease_makeConstraints:^(EaseConstraintMaker *make) {
        make.top.equalTo(self).offset(10);
        make.left.equalTo(self).offset(16);
        make.width.Ease_equalTo(@16);
        make.height.Ease_equalTo(kIconwidth);
    }];
    
    self.conversationToolBarBtn = [[UIButton alloc] init];
    [_conversationToolBarBtn setBackgroundImage:[UIImage easeUIImageNamed:@"more-unselected"] forState:UIControlStateNormal];
    [_conversationToolBarBtn setBackgroundImage:[UIImage easeUIImageNamed:@"more-selected"] forState:UIControlStateSelected];
    [_conversationToolBarBtn addTarget:self action:@selector(moreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_conversationToolBarBtn];
    [_conversationToolBarBtn Ease_makeConstraints:^(EaseConstraintMaker *make) {
        make.top.equalTo(self).offset(10);
        make.right.equalTo(self).offset(-16);
        make.width.height.Ease_equalTo(kIconwidth);
    }];
    
    self.emojiButton = [[UIButton alloc] init];
    [_emojiButton setBackgroundImage:[UIImage easeUIImageNamed:@"face"] forState:UIControlStateNormal];
    [_emojiButton setBackgroundImage:[UIImage easeUIImageNamed:@"character"] forState:UIControlStateSelected];
    [_emojiButton addTarget:self action:@selector(emoticonButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_emojiButton];
    [_emojiButton Ease_makeConstraints:^(EaseConstraintMaker *make) {
        make.top.equalTo(self).offset(10);
        make.right.equalTo(self.conversationToolBarBtn.ease_left).offset(-kModuleMargin);
        make.width.height.Ease_equalTo(kIconwidth);
    }];
    
    self.textView = [[EaseTextView alloc] init];
    self.textView.delegate = self;
    [self.textView setTextColor:[UIColor blackColor]];
    self.textView.font = [UIFont systemFontOfSize:16];
    self.textView.textAlignment = NSTextAlignmentLeft;
    
    self.textView.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 0);
    if (@available(iOS 11.1, *)) {
        self.textView.verticalScrollIndicatorInsets = UIEdgeInsetsMake(12, 20, 2, 0);
    } else {
        // Fallback on earlier versions
    }
    self.textView.returnKeyType = UIReturnKeySend;
    self.textView.backgroundColor = [UIColor whiteColor];
    self.textView.layer.cornerRadius = 16;
    [self addSubview:self.textView];
    [self.textView Ease_makeConstraints:^(EaseConstraintMaker *make) {
        make.top.equalTo(self).offset(5);
        make.height.Ease_equalTo(kTextViewMinHeight);
        if (_viewModel.inputBarStyle == EaseInputBarStyleAll) {
            make.left.equalTo(self.audioButton.ease_right).offset(kModuleMargin);
            make.right.equalTo(self.emojiButton.ease_left).offset(-kModuleMargin);
        }
        if (_viewModel.inputBarStyle == EaseInputBarStyleNoAudio) {
            make.left.equalTo(self).offset(16);
            make.right.equalTo(self.emojiButton.ease_left).offset(-kModuleMargin);
        }
        if (_viewModel.inputBarStyle == EaseInputBarStyleNoEmoji) {
            make.left.equalTo(self.audioButton.ease_right).offset(kModuleMargin);
            make.right.equalTo(self.conversationToolBarBtn.ease_left).offset(-kModuleMargin);
        }
        if (_viewModel.inputBarStyle == EaseInputBarStyleNoAudioAndEmoji) {
            make.left.equalTo(self).offset(16);
            make.right.equalTo(self.conversationToolBarBtn.ease_left).offset(-kModuleMargin);
        }
        if (_viewModel.inputBarStyle == EaseInputBarStyleOnlyText) {
            make.left.equalTo(self).offset(16);
            make.right.equalTo(self).offset(-16);
        }
    }];
    /*
    self.audioDescBtn = [[UIButton alloc]init];
    [self.audioDescBtn setBackgroundColor:[UIColor colorWithHexString:@"#E9E9E9"]];
    [self.audioDescBtn setTitle:@"按住 说话" forState:UIControlStateNormal];
    [self.audioDescBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [self.audioDescBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.audioDescBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    self.audioDescBtn.layer.cornerRadius = 16;
    [self.textView addSubview:self.audioDescBtn];
    [self.audioDescBtn Ease_makeConstraints:^(EaseConstraintMaker *make) {
        make.width.height.equalTo(self.textView);
        make.center.equalTo(self.textView);
    }];
    self.audioDescBtn.hidden = YES;
    [self.audioDescBtn addTarget:self action:@selector(recordButtonTouchBegin) forControlEvents:UIControlEventTouchDown];
    [self.audioDescBtn addTarget:self action:@selector(recordButtonTouchEnd) forControlEvents:UIControlEventTouchUpInside];
    [self.audioDescBtn addTarget:self action:@selector(recordButtonTouchCancelBegin) forControlEvents:UIControlEventTouchDragOutside];
    [self.audioDescBtn addTarget:self action:@selector(recordButtonTouchCancelCancel) forControlEvents:UIControlEventTouchDragInside];
    [self.audioDescBtn addTarget:self action:@selector(recordButtonTouchCancelEnd) forControlEvents:UIControlEventTouchUpOutside];*/
    
    self.bottomLine = [[UIView alloc] init];
    _bottomLine.backgroundColor = [UIColor colorWithHexString:@"#000000"];
    _bottomLine.alpha = 0.1;
    [self addSubview:self.bottomLine];
    [_bottomLine Ease_makeConstraints:^(EaseConstraintMaker *make) {
        make.top.equalTo(self.textView.ease_bottom).offset(5);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.height.equalTo(@0.5);
        make.bottom.equalTo(self).offset(-EMVIEWBOTTOMMARGIN);
    }];
    self.currentMoreView.backgroundColor = [UIColor colorWithHexString:@"#f2f2f2"];
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (self.currentMoreView) {
        [self.currentMoreView removeFromSuperview];
        [self.bottomLine Ease_updateConstraints:^(EaseConstraintMaker *make) {
            make.bottom.equalTo(self).offset(-EMVIEWBOTTOMMARGIN);
        }];
    }
    
    self.emojiButton.selected = NO;
    self.conversationToolBarBtn.selected = NO;
    self.audioButton.selected = NO;
    return YES;
}

- (void)textViewDidChangeSelection:(UITextView *)textView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(textViewDidChangeSelection:)]) {
        [self.delegate textViewDidChangeSelection:textView];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(chatBarSendMsgAction:)]) {
            [self.delegate chatBarSendMsgAction:self.textView.text];
        }
        return NO;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)]) {
        return [self.delegate textView:textView shouldChangeTextInRange:range replacementText:text];
    }

    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self _updatetextViewHeight];
    if (self.moreEmoticonView) {
        [self emoticonChangeWithText];
    }
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
    [self.textView Ease_updateConstraints:^(EaseConstraintMaker *make) {
        make.height.Ease_equalTo(height);
    }];
}

- (void)_remakeButtonsViewConstraints
{
    if (self.currentMoreView) {
        [self.bottomLine Ease_remakeConstraints:^(EaseConstraintMaker *make) {
            make.top.equalTo(self.textView.ease_bottom).offset(5);
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.height.equalTo(@1);
            make.bottom.equalTo(self.currentMoreView.ease_top);
        }];
    } else {
        [self.bottomLine Ease_remakeConstraints:^(EaseConstraintMaker *make) {
            make.top.equalTo(self.textView.ease_bottom).offset(5);
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.height.equalTo(@1);
            make.bottom.equalTo(self).offset(-EMVIEWBOTTOMMARGIN);
        }];
    }
}

- (void)emoticonChangeWithText
{
    if (self.textView.text.length > 0) {
        [self.moreEmoticonView textDidChange:YES];
    } else {
        [self.moreEmoticonView textDidChange:NO];
    }
}

#pragma mark - Public

- (void)clearInputViewText
{
    self.textView.text = @"";
    if (self.moreEmoticonView) {
        [self emoticonChangeWithText];
    }
    [self _updatetextViewHeight];
}

- (void)inputViewAppendText:(NSString *)aText
{
    if ([aText length] > 0) {
        self.textView.text = [NSString stringWithFormat:@"%@%@", self.textView.text, aText];
        [self _updatetextViewHeight];
    }
    if (self.moreEmoticonView) {
        [self emoticonChangeWithText];
    }
}

- (BOOL)deleteTailText
{
    if ([self.textView.text length] > 0) {
        NSRange range = [self.textView.text rangeOfComposedCharacterSequenceAtIndex:self.textView.text.length-1];
        self.textView.text = [self.textView.text substringToIndex:range.location];
    }
    if ([self.textView.text length] > 0) {
        return YES;
    }
    return NO;
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
    if (!self.audioButton.isSelected) {
        [self.audioButton Ease_updateConstraints:^(EaseConstraintMaker *make) {
            make.width.Ease_equalTo(@16);
        }];
    } else {
        [self.audioButton Ease_updateConstraints:^(EaseConstraintMaker *make) {
            make.width.Ease_equalTo(kIconwidth);
        }];
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
    if (!self.audioButton.isSelected) {
        [self.audioButton Ease_updateConstraints:^(EaseConstraintMaker *make) {
            make.width.Ease_equalTo(@16);
        }];
    } else {
        [self.audioButton Ease_updateConstraints:^(EaseConstraintMaker *make) {
            make.width.Ease_equalTo(kIconwidth);
        }];
    }
    
    return isEditing;
}

//语音
- (void)audioButtonAction:(UIButton *)aButton
{
    if([self _buttonAction:aButton]) {
        return;
    }

    if (aButton.selected) {
        if (self.recordAudioView) {
            self.currentMoreView = self.recordAudioView;
            [self addSubview:self.recordAudioView];
            [self.recordAudioView Ease_makeConstraints:^(EaseConstraintMaker *make) {
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
            [self emoticonChangeWithText];
            [self addSubview:self.moreEmoticonView];
            [self.moreEmoticonView Ease_makeConstraints:^(EaseConstraintMaker *make) {
                make.left.equalTo(self);
                make.right.equalTo(self);
                make.bottom.equalTo(self).offset(-EMVIEWBOTTOMMARGIN);
                make.height.Ease_equalTo(self.moreEmoticonView.viewHeight);
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
            [self.moreFunctionView Ease_makeConstraints:^(EaseConstraintMaker *make) {
                make.left.equalTo(self);
                make.right.equalTo(self);
                make.bottom.equalTo(self).offset(-EMVIEWBOTTOMMARGIN);
                make.height.Ease_equalTo(@200);
            }];
            [self _remakeButtonsViewConstraints];
            if (self.delegate && [self.delegate respondsToSelector:@selector(chatBarDidShowMoreViewAction)]) {
                [self.delegate chatBarDidShowMoreViewAction];
            }
        }
    }
}

@end
