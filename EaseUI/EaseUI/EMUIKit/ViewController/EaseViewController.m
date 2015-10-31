//
//  EaseViewController.m
//  ChatDemo-UI3.0
//
//  Created by dhc on 15/6/24.
//  Copyright (c) 2015年 easemob.com. All rights reserved.
//

#import "EaseViewController.h"

@interface EaseViewController ()

@property (strong, nonatomic) UITapGestureRecognizer *tapRecognizer;

@end

@implementation EaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]){
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    
    _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapViewAction:)];
    [self.view addGestureRecognizer:_tapRecognizer];
    _endEditingWhenTap = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - setter

- (void)setEndEditingWhenTap:(BOOL)endEditingWhenTap
{
    if (_endEditingWhenTap != endEditingWhenTap) {
        _endEditingWhenTap = endEditingWhenTap;
        
        if (_endEditingWhenTap) {
            [self.view addGestureRecognizer:self.tapRecognizer];
        }
        else{
            [self.view removeGestureRecognizer:self.tapRecognizer];
        }
    }
}

#pragma mark - action

- (void)tapViewAction:(UITapGestureRecognizer *)tapRecognizer
{
    if (tapRecognizer.state == UIGestureRecognizerStateEnded) {
        [self.view endEditing:YES];
    }
}

@end
