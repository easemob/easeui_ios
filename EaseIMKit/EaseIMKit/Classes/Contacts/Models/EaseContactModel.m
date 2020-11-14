//
//  EaseContactModel.m
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/11/5.
//

#import "EaseContactModel.h"

@implementation EaseContactModel {
    NSString *_showName;
    NSString *_firstLetter;
    UIImage *_defaultAvatar;
}

- (instancetype)initWithShowName:(NSString *)showName {
    if (self = [super init]) {
        _showName = showName;
        _defaultAvatar = [UIImage imageNamed:@"defaultAvatar.png"];
    }
    return self;
}

- (NSString *)showName {
    return _showName;
}

- (NSString *)avatarURL {
    return @"";
}

- (EaseContactItemType)type {
    return Contact;
}

- (NSString *)firstLetter {
    if (_firstLetter) {
        return _firstLetter;
    }
    NSMutableString *ms = [[NSMutableString alloc]initWithString:[self showName]];
    CFStringTransform((__bridge CFMutableStringRef)ms, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((__bridge CFMutableStringRef)ms, 0,kCFStringTransformStripDiacritics, NO);
    _firstLetter = [[ms substringToIndex:1] uppercaseString];
    return _firstLetter;
}

- (UIImage *)defaultAvatar {
    return _defaultAvatar;
}

@synthesize type;

@synthesize defaultAvatar;

@synthesize itemId;

@synthesize showName;

@end
