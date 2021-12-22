//
//  EaseTextViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/17.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EaseTextViewController.h"
#import "EaseHeaders.h"
#import "EaseTextView.h"

@interface EaseTextViewController ()<UITextViewDelegate>

@property (nonatomic, strong) NSString *originalString;
@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic) BOOL isEditable;

@property (nonatomic, strong) EaseTextView *textView;

@end

@implementation EaseTextViewController

- (instancetype)initWithString:(NSString *)aString
                   placeholder:(NSString *)aPlaceholder
                    isEditable:(BOOL)aIsEditable
{
    self = [super init];
    if (self) {
        _originalString = aString;
        _placeholder = aPlaceholder;
        _isEditable = aIsEditable;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self _setupSubviews];
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    if (self.isEditable) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:EaseLocalizableString(@"save", nil) style:UIBarButtonItemStylePlain target:self action:@selector(doneAction)];
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgView];
    [bgView Ease_makeConstraints:^(EaseConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@(self.view.frame.size.height/2));
    }];
    
    self.textView = [[EaseTextView alloc] init];
    self.textView.delegate = self;
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.font = [UIFont systemFontOfSize:16];
    if (!self.isEditable)
        self.textView.placeHolder = EaseLocalizableString(@"fetchEditPermision", nil);
    else
        self.textView.placeHolder = self.placeholder;
    self.textView.returnKeyType = UIReturnKeyDone;
    if (self.originalString && ![self.originalString isEqualToString:@""]) {
        self.textView.text = self.originalString;
    }
    self.textView.editable = self.isEditable;
    [self.view addSubview:self.textView];
    [self.textView Ease_makeConstraints:^(EaseConstraintMaker *make) {
        make.center.equalTo(bgView);
        make.top.equalTo(bgView).offset(5);
        make.left.equalTo(bgView).offset(10);
    }];
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

#pragma mark - Action

- (void)doneAction
{
    [self.view endEditing:YES];
    
    BOOL isPop = YES;
    if (_doneCompletion) {
        isPop = _doneCompletion(self.textView.text);
    }
    
    if (isPop) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
