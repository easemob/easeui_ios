//
//  EaseEmojiHelper.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/31.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EaseEmojiHelper.h"

#define EMOJI_CODE_TO_SYMBOL(x) ((((0x808080F0 | (x & 0x3F000) >> 4) | (x & 0xFC0) << 10) | (x & 0x1C0000) << 18) | (x & 0x3F) << 24);

static EaseEmojiHelper *helper = nil;
@implementation EaseEmojiHelper

- (instancetype)init
{
    self = [super init];
    if (self) {
        _convertEmojiDic = @{@"[):]":@"😊", @"[:D]":@"😃", @"[;)]":@"😉", @"[:-o]":@"😮", @"[:p]":@"😋", @"[(H)]":@"😎", @"[:@]":@"😡", @"[:s]":@"😖", @"[:$]":@"😳", @"[:(]":@"😞", @"[:'(]":@"😭", @"[:|]":@"😐", @"[(a)]":@"😇", @"[8o|]":@"😬", @"[8-|]":@"😆", @"[+o(]":@"😱", @"[<o)]":@"🎅", @"[|-)]":@"😴", @"[*-)]":@"😕", @"[:-#]":@"😷", @"[:-*]":@"😯", @"[^o)]":@"😏", @"[8-)]":@"😑", @"[(|)]":@"💖", @"[(u)]":@"💔", @"[(S)]":@"🌙", @"[(*)]":@"🌟", @"[(#)]":@"🌞", @"[(R)]":@"🌈", @"[(})]":@"😚", @"[({)]":@"😍", @"[(k)]":@"💋", @"[(F)]":@"🌹", @"[(W)]":@"🍂", @"[(D)]":@"👍"};
    }
    
    return self;
}

+ (instancetype)sharedHelper
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[EaseEmojiHelper alloc] init];
    });
    
    return helper;
}

+ (NSString *)emojiWithCode:(int)aCode
{
    int sym = EMOJI_CODE_TO_SYMBOL(aCode);
    return [[NSString alloc] initWithBytes:&sym length:sizeof(sym) encoding:NSUTF8StringEncoding];
}

+ (NSArray<NSString *> *)getAllEmojis
{
    NSArray *emojis = @[[EaseEmojiHelper emojiWithCode:0x1F60a],
                        [EaseEmojiHelper emojiWithCode:0x1F603],
                        [EaseEmojiHelper emojiWithCode:0x1F609],
                        [EaseEmojiHelper emojiWithCode:0x1F62e],
                        [EaseEmojiHelper emojiWithCode:0x1F60b],
                        [EaseEmojiHelper emojiWithCode:0x1F60e],
                        [EaseEmojiHelper emojiWithCode:0x1F621],
                        [EaseEmojiHelper emojiWithCode:0x1F616],
                        [EaseEmojiHelper emojiWithCode:0x1F633],
                        [EaseEmojiHelper emojiWithCode:0x1F61e],
                        [EaseEmojiHelper emojiWithCode:0x1F62d],
                        [EaseEmojiHelper emojiWithCode:0x1F610],
                        [EaseEmojiHelper emojiWithCode:0x1F607],
                        [EaseEmojiHelper emojiWithCode:0x1F62c],
                        [EaseEmojiHelper emojiWithCode:0x1F606],
                        [EaseEmojiHelper emojiWithCode:0x1F631],
                        [EaseEmojiHelper emojiWithCode:0x1F385],
                        [EaseEmojiHelper emojiWithCode:0x1F634],
                        [EaseEmojiHelper emojiWithCode:0x1F615],
                        [EaseEmojiHelper emojiWithCode:0x1F637],
                        [EaseEmojiHelper emojiWithCode:0x1F62f],
                        [EaseEmojiHelper emojiWithCode:0x1F60f],
                        [EaseEmojiHelper emojiWithCode:0x1F611],
                        [EaseEmojiHelper emojiWithCode:0x1F496],
                        [EaseEmojiHelper emojiWithCode:0x1F494],
                        [EaseEmojiHelper emojiWithCode:0x1F319],
                        [EaseEmojiHelper emojiWithCode:0x1f31f],
                        [EaseEmojiHelper emojiWithCode:0x1f31e],
                        [EaseEmojiHelper emojiWithCode:0x1F308],
                        [EaseEmojiHelper emojiWithCode:0x1F60d],
                        [EaseEmojiHelper emojiWithCode:0x1F61a],
                        [EaseEmojiHelper emojiWithCode:0x1F48b],
                        [EaseEmojiHelper emojiWithCode:0x1F339],
                        [EaseEmojiHelper emojiWithCode:0x1F342],
                        [EaseEmojiHelper emojiWithCode:0x1F44d]];

    return emojis;
}

+ (BOOL)isStringContainsEmoji:(NSString *)aString
{
    __block BOOL ret = NO;
    [aString enumerateSubstringsInRange:NSMakeRange(0, [aString length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        const unichar hs = [substring characterAtIndex:0];
        if (0xd800 <= hs && hs <= 0xdbff) {
            if (substring.length > 1) {
                const unichar ls = [substring characterAtIndex:1];
                const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                if (0x1d000 <= uc && uc <= 0x1f77f) {
                    ret = YES;
                }
            }
        } else if (substring.length > 1) {
            const unichar ls = [substring characterAtIndex:1];
            if (ls == 0x20e3) {
                ret = YES;
            }
        } else {
            if (0x2100 <= hs && hs <= 0x27ff) {
                ret = YES;
            } else if (0x2B05 <= hs && hs <= 0x2b07) {
                ret = YES;
            } else if (0x2934 <= hs && hs <= 0x2935) {
                ret = YES;
            } else if (0x3297 <= hs && hs <= 0x3299) {
                ret = YES;
            } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                ret = YES;
            }
        }
    }];
    
    return ret;
}

+ (NSString *)convertEmoji:(NSString *)aString
{
    NSDictionary *emojisDic = [EaseEmojiHelper sharedHelper].convertEmojiDic;
    NSRange range;
    range.location = 0;
    
    NSMutableString *retStr = [NSMutableString stringWithString:aString];
    for (NSString *key in emojisDic) {
        range.length = retStr.length;
        NSString *value = emojisDic[key];
        [retStr replaceOccurrencesOfString:key withString:value options:NSLiteralSearch range:range];
    }
    
    return retStr;
}

@end
