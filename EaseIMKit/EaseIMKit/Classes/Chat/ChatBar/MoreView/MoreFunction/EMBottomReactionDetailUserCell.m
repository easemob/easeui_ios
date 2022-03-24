//
//  EMBottomReactionDetailUserCell.m
//  EaseIMKit
//
//  Created by 冯钊 on 2022/2/24.
//

#import "EMBottomReactionDetailUserCell.h"

@import HyphenateChat;
#import "UIImage+EaseUI.h"
#import "EaseIMKitManager.h"
#import "UIImageView+EaseWebCache.h"

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
    __weak typeof(self)weakSelf = self;
    id<EaseIMKitManagerGeneralDelegate> delegate = EaseIMKitManager.shared.generalDelegate;
    
    UIImage *defaultAvatarImage = nil;
    if (delegate && [delegate respondsToSelector:@selector(defaultAvatar)]) {
        defaultAvatarImage = delegate.defaultAvatar;
    } else {
        defaultAvatarImage = [UIImage easeUIImageNamed:@"defaultAvatar"];
    }
    if (delegate && [delegate respondsToSelector:@selector(getUserInfo:result:)]) {
        [delegate getUserInfo:userId result:^(EMUserInfo * _Nonnull userInfo) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (userInfo.nickname.length > 0) {
                    weakSelf.nameLabel.text = userInfo.nickname;
                } else {
                    weakSelf.nameLabel.text = userInfo.userId;
                }
                [weakSelf.headImageView Ease_setImageWithURL:[NSURL URLWithString:userInfo.avatarUrl]
                                            placeholderImage:defaultAvatarImage];
            });
        }];
    } else {
        _nameLabel.text = userId;
        _headImageView.image = defaultAvatarImage;
    }
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
