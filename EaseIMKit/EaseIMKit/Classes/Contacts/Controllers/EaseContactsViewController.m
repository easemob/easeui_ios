//
//  EaseContactsViewController.m
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/11/5.
//

#import "EaseContactsViewController.h"
#import <Hyphenate/Hyphenate.h>
#import <Masonry/Masonry.h>

@interface EaseContactsViewController ()
{
    EaseContactsViewModel *_viewModel;
}

@property (nonatomic, strong) NSArray *contacts;

@end

@implementation EaseContactsViewController

- (instancetype)initWithViewModel:(EaseContactsViewModel *)model {
    if (self = [super init]) {
        _viewModel = model;

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)refreshViewWithModel:(EaseContactsViewModel *)viewModel {
    _viewModel = viewModel;
}

- (void)refreshTabView {
    [EMClient.sharedClient.contactManager getContactsFromServerWithCompletion:^(NSArray *aList, EMError *aError) {
        [self endRefresh];
    }];
}

@end
