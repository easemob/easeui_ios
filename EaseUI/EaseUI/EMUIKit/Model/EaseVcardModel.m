//
//  EaseVcardModel.m
//  EaseUI
//
//  Created by WYZ on 16/3/25.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EaseVcardModel.h"
#import <objc/runtime.h>

#define ISNullByKey(dict, key) (!dict[key] || [dict[key] isKindOfClass:[NSNull class]])
#define GetVcardInfoValue(dict, key) (ISNullByKey(dict, key)?@"":dict[key])
//#define GetVcardInfoValue(dict, key) ((!dict[key] || [dict[key] isKindOfClass:[NSNull class]])?@"":dict[key])


@implementation EaseVcardModel

- (id)initWithInfo:(NSDictionary*)dict
{
    if ((self=[super init]))
    {
        [self updateFromDictionary:dict];
    }//end if
    return self;
}

- (void)updateFromDictionary:(NSDictionary *)dict
{
    if (!self || !dict) return;
    if (ISNullByKey(dict, @"username") && !_username) {
        return;
    }
    
    for (NSString *keyName in [dict allKeys]) {
        
        NSString *propertyName = keyName;
        if (!propertyName) continue;
        
        //构建出属性的set方法
        //            NSString *destMethodName = [NSString stringWithFormat:@"set%@:",[keyName capitalizedString]]; //capitalizedString返回每个单词首字母大写的字符串（每个单词的其余字母转换为小写）
        unichar firstChar = [propertyName characterAtIndex:0];
        unichar firstUpChar = toupper(firstChar);
        NSString *otherStr = [propertyName substringFromIndex:1];
        NSString *destMethodName = [NSString stringWithFormat:@"set%c%@:",
                                    firstUpChar, otherStr];
        
        SEL destMethodSelector = NSSelectorFromString(destMethodName);
        
        id obj = [dict objectForKey:keyName];
        
        if ([self respondsToSelector:destMethodSelector] && ![obj isKindOfClass:[NSNull class]]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self performSelector:destMethodSelector withObject: obj];
#pragma clang diagnostic pop
        }
    }
    if (!_nickname) {
        _nickname = _username;
    }
    if (!_avatarURL) {
        _avatarURL = @"";
    }
    
}

- (NSDictionary*)toDictionary
{
    if (!self) return nil;
    
    Class clazz = [self class];
    u_int count;
    
    objc_property_t* properties = class_copyPropertyList(clazz, &count);
    NSMutableArray* propertyArray = [NSMutableArray arrayWithCapacity:count];
    NSMutableArray* valueArray = [NSMutableArray arrayWithCapacity:count];
    
    for (int i = 0; i < count ; i++)
    {
        objc_property_t prop=properties[i];
        const char* propertyName = property_getName(prop);
        [propertyArray addObject:[NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding]];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        id value =  [self performSelector:NSSelectorFromString([NSString stringWithUTF8String:propertyName])];
#pragma clang diagnostic pop
        if(value ==nil)
            [valueArray addObject:[NSNull null]];
        else {
            [valueArray addObject:value];
        }
    }
    free(properties);
    NSDictionary* modelDic = [NSDictionary dictionaryWithObjects:valueArray forKeys:propertyArray];
    NSMutableDictionary *returnDic = [NSMutableDictionary dictionaryWithDictionary:modelDic];
    [returnDic removeObjectForKey:@"debugDescription"];
    [returnDic removeObjectForKey:@"description"];
    [returnDic removeObjectForKey:@"hash"];
    [returnDic removeObjectForKey:@"superclass"];
    return returnDic;
}


@end
