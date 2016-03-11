//
//  EaseLocationViewController.h
//  ChatDemo-UI3.0
//
//  Created by dhc on 2/7/24.
//  Copyright (c) 2015年 easemob.com. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "EaseViewController.h"
#import "IMessageModel.h"

@protocol EMLocationViewDelegate <NSObject>

-(void)sendLocationLatitude:(double)latitude
                  longitude:(double)longitude
                 andAddress:(NSString *)address;
@optional
- (void)locationMessageReadAck:(id<IMessageModel>)messageModel;
@end

@interface EaseLocationViewController : EaseViewController

@property (nonatomic, assign) id<EMLocationViewDelegate> delegate;

@property (nonatomic, strong) id<IMessageModel> localMessageModel;

- (instancetype)initWithLocation:(CLLocationCoordinate2D)locationCoordinate;

@end
