//
//  NormalItem.m
//  EaseIMKitDemo
//
//  Created by 杜洁鹏 on 2020/11/10.
//  Copyright © 2020 djp. All rights reserved.
//

#import "NormalItem.h"

@implementation NormalItem

@synthesize itemId;
@synthesize firstLetter;
@synthesize type;

- (EaseContactItemType)type{
    return EaseContactItemType_Custom;
}




@end
