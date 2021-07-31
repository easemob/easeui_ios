//
//  EaseExtMenuModel.m
//  EaseIMKit
//
//  Created by 娜塔莎 on 2020/11/24.
//

#import "EaseExtMenuModel.h"

@implementation EaseExtMenuModel

- (instancetype)initWithData:(UIImage *)icon funcDesc:(NSString *)funcDesc handle:(menuItemDidSelectedHandle)menuItemHandle
{
    if (self = [super init]) {
        if (icon) {
            _icon = icon;
        }
        if (funcDesc) {
            _funcDesc = funcDesc;
        }
        if (menuItemHandle) {
            _itemDidSelectedHandle = menuItemHandle;
        }
    }
    return self;
}

@end
