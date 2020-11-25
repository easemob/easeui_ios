//
//  EaseContactsViewModel.m
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/11/5.
//

#import "EaseContactsViewModel.h"
#import "EaseHeaders.h"
#import "UIImage+EaseUI.h"

@implementation EaseContactsViewModel
@synthesize bgView = _bgView;
@synthesize cellBgColor = _cellBgColor;
@synthesize cellSeparatorInset = _cellSeparatorInset;
@synthesize cellSeparatorColor = _cellSeparatorColor;

- (instancetype)init {
    if (self = [super init]) {
        [self _setupPropertyDefault];
    }
    return self;
}



- (void)_setupPropertyDefault {

    _avatarType = Circular;
    _avatarSize = CGSizeMake(40, 40);
    _avatarEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    
    _nameLabelFont = [UIFont systemFontOfSize:17];
    _nameLabelColor = [UIColor colorWithHexString:@"#333333"];
    _nameLabelEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    
    _cellBgColor = [UIColor colorWithHexString:@"#FFFFFF"];
    
    _bgView = [[UIView alloc] init];
    _bgView.backgroundColor = [UIColor colorWithHexString:@"#F2F2F2"];
    
    _cellSeparatorInset = UIEdgeInsetsMake(1, 77, 0, 0);
    _cellSeparatorColor = [UIColor colorWithHexString:@"#F3F3F3"];
    
    _sectionTitleFont = [UIFont systemFontOfSize:17];
    _sectionTitleColor = [UIColor colorWithHexString:@"#333333"];
    _sectionTitleBgColor = [UIColor colorWithHexString:@"#F2F2F2"];
    _sectionTitleLabelHeight = 20;
    _sectionTitleEdgeInsets = UIEdgeInsetsMake(8, 20, 10, 50);
    
    _defaultAvatarImage = [UIImage easeUIImageNamed:@"defaultAvatar"];
    
}
@end
