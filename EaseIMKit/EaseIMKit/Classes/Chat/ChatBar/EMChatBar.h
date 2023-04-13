//
//  EMChatBar.h
//  ChatDemo-UI3.0
//
//  Updated by zhangchong on 2020/06/05.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EaseTextView.h"
#import "EaseChatBarEmoticonView.h"
#import "EMChatBarRecordAudioView.h"
#import "EMMoreFunctionView.h"
#import "EaseChatViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol EMChatBarDelegate;
@interface EMChatBar : UIView

@property (nonatomic, weak) id<EMChatBarDelegate> delegate;

@property (nonatomic, strong) EaseTextView *textView;

@property (nonatomic, strong) EMChatBarRecordAudioView *recordAudioView;
@property (nonatomic, strong) EaseChatBarEmoticonView *moreEmoticonView;
@property (nonatomic, strong) EMMoreFunctionView *moreFunctionView;

- (instancetype)initWithViewModel:(EaseChatViewModel *)viewModel;

- (void)clearInputViewText;

- (void)inputViewAppendText:(NSString *)aText;

- (BOOL)deleteTailText;

- (void)clearMoreViewAndSelectedButton;

@end


@protocol EMChatBarDelegate <NSObject>

@optional

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;

- (void)textViewDidChangeSelection:(UITextView *)textView;

- (void)inputViewDidChange:(EaseTextView *)aInputView;

- (void)chatBarDidShowMoreViewAction;

- (void)chatBarSendMsgAction:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
