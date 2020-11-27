//
//  MineViewController.m
//  EaseIMKitDemo
//
//  Created by 杜洁鹏 on 2020/11/5.
//  Copyright © 2020 djp. All rights reserved.
//

#import "MineViewController.h"

@interface MineViewController ()
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation MineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    self.versionLabel.text = EMClient.sharedClient.version;
}

- (IBAction)logoutBtnClicked:(id)sender {
//    [EMClient.sharedClient logout:YES completion:^(EMError *aError) {
//            
//    }];
}


@end
