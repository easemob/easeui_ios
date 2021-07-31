/************************************************************
 *  * HyphenateChat CONFIDENTIAL
 * __________________
 * Copyright (C) 2016 HyphenateChat Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of HyphenateChat Inc.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from HyphenateChat Inc.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface EaseEmotionEscape : NSObject

+ (EaseEmotionEscape *)sharedInstance;

+ (NSMutableAttributedString *) attributtedStringFromText:(NSString *) aInputText;

+ (NSAttributedString *) attStringFromTextForChatting:(NSString *) aInputText;

+ (NSAttributedString *) attStringFromTextForInputView:(NSString *) aInputText;

- (NSAttributedString *) attStringFromTextForChatting:(NSString *) aInputText textFont:(UIFont*)font;

- (NSAttributedString *) attStringFromTextForInputView:(NSString *) aInputText textFont:(UIFont*)font;

- (void) setEaseEmotionEscapePattern:(NSString*)pattern;

- (void) setEaseEmotionEscapeDictionary:(NSDictionary*)dict;

@end

@interface EMTextAttachment : NSTextAttachment

@property(nonatomic, strong) NSString *imageName;

@end
