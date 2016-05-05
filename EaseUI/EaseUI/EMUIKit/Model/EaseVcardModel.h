//
//  EaseVcardModel.h
//  EaseUI
//
//  Created by WYZ on 16/3/25.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IVcardModel.h"

@interface EaseVcardModel : NSObject<IVcardModel>

@property (nonatomic, strong) NSString *nickname; //用户昵称，默认环信id

@property (nonatomic, strong) NSString *avatarURL; //头像链接

@property (nonatomic, strong) NSString *username; //环信Id

- (id)initWithInfo:(NSDictionary*)dict;

- (void)updateFromDictionary:(NSDictionary *)dict;

- (NSDictionary *)toDictionary;

@end
