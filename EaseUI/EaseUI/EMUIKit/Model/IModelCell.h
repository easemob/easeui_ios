//
//  IModelCell.h
//  ChatDemo-UI3.0
//
//  Created by dhc on 15/6/24.
//  Copyright (c) 2015年 easemob.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IModelCell <NSObject>

@required

@property (strong, nonatomic) id model;

+ (NSString *)cellIdentifierWithModel:(id)model;

+ (CGFloat)cellHeightWithModel:(id)model;

@optional

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
                        model:(id)model;

@end
