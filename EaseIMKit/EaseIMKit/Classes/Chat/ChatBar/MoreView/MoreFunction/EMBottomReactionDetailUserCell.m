//
//  EMBottomReactionDetailUserCell.m
//  EaseIMKit
//
//  Created by 冯钊 on 2022/2/24.
//

#import "EMBottomReactionDetailUserCell.h"

@import HyphenateChat;
#import "UIImage+EaseUI.h"

@interface EMBottomReactionDetailUserCell ()

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@end

@implementation EMBottomReactionDetailUserCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [_deleteButton setImage:[UIImage easeUIImageNamed:@"delete_reaction_list"] forState:UIControlStateNormal];
}

- (void)setUserId:(NSString *)userId {
    _userId = userId;
    _deleteButton.hidden = ![userId isEqualToString:EMClient.sharedClient.currentUsername];
}

- (void)setUsername:(NSString *)username {
    _username = username;
    _nameLabel.text = username;
}

- (IBAction)onDeleteButtonClick {
    if (_didClickRemove) {
        _didClickRemove();
    }
}

@end
