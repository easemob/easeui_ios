//
//  EaseUserDataProtocol.h
//  EaseIMKit
//
//  Created by 娜塔莎 on 2020/11/23.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@protocol EaseUserData <NSObject>

@property (nonatomic, strong) UIImage *avatarImg;
@property (nonatomic, strong) NSString *Nickname;

@end
