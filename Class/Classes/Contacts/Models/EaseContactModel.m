//
//  EaseContactModel.m
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/11/5.
//

#import "EaseContactModel.h"
#import "UIImage+EaseUI.h"

@implementation EaseContactModel
@synthesize firstLetter = _firstLetter;
- (instancetype)initWithEaseId:(NSString *)easeId {
    if (self = [super init]) {
        _easeId = easeId;
    }
    return self;
}

- (NSString *)showName {
    if (_userDelegate && [_userDelegate respondsToSelector:@selector(showName)]) {
        if (_userDelegate.showName) {
            return _userDelegate.showName;
        }
        return _easeId;
    }else {
        return _easeId;
    }
}

- (NSString *)avatarURL {
    if (_userDelegate && [_userDelegate respondsToSelector:@selector(avatarURL)]) {
        return _userDelegate.avatarURL;
    }else {
        return nil;
    }
}

- (UIImage *)defaultAvatar {
    if (_userDelegate && [_userDelegate respondsToSelector:@selector(defaultAvatar)]) {
        return _userDelegate.defaultAvatar;
    }else {
        return nil;
    }
}

- (NSString *)firstLetter {
    NSString *ret = @"";
    if (_firstLetter) {
        ret = _firstLetter;
    }else {
        NSMutableString *ms = [[NSMutableString alloc]initWithString:[self showName]];
        CFStringTransform((__bridge CFMutableStringRef)ms, NULL, kCFStringTransformMandarinLatin, NO);
        CFStringTransform((__bridge CFMutableStringRef)ms, 0,kCFStringTransformStripDiacritics, NO);
        _firstLetter = [[ms substringToIndex:1] uppercaseString];
        ret = _firstLetter;
    }
    
    return _firstLetter;
}


@end
