//
//  EMImageManager.m
//  EaseUI
//
//  Created by XieYajie on 06/11/2017.
//  Copyright © 2017 easemob. All rights reserved.
//

#import "EMImageManager.h"

static EMImageManager *sharedManager = nil;

@interface EMImageManager()

@property (nonatomic, strong) NSMutableArray *delegates;

@end

@implementation EMImageManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _delegates = [[NSMutableArray alloc] init];
    }
    
    return self;
}

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[EMImageManager alloc] init];
    });
    
    return sharedManager;
}

- (void)addDelegate:(id<EMImageManagerDelegate>)aDelegate
              queue:(dispatch_queue_t)aQueue
{
    if (aDelegate) {
        [self.delegates addObject:aDelegate];
    }
}

- (void)removeDelegate:(id<EMImageManagerDelegate>)aDelegate
{
    [self.delegates removeObject:aDelegate];
}

- (void)showImageWithView:(UIImageView *)aImgView
                 imageUrl:(NSString *)aUrl
             defaultImage:(UIImage *)aDefaultImg
{
    for (NSInteger i = 0; i < [self.delegates count]; i++) {
        id delegate = [self.delegates objectAtIndex:i];
        if ([delegate respondsToSelector:@selector(didShowImageWithView:imageUrl:defaultImage:)]) {
            [delegate didShowImageWithView:aImgView imageUrl:aUrl defaultImage:aDefaultImg];
        }
    }
}

@end
