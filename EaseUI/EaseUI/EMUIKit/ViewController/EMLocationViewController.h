//
//  EMLocationViewController.h
//  ChatDemo-UI3.0
//
//  Created by dhc on 2/7/24.
//  Copyright (c) 2015年 easemob.com. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "EMViewController.h"

@protocol EMLocationViewDelegate <NSObject>

-(void)sendLocationLatitude:(double)latitude
                  longitude:(double)longitude
                 andAddress:(NSString *)address;
@end

@interface EMLocationViewController : EMViewController

@property (nonatomic, assign) id<EMLocationViewDelegate> delegate;

- (instancetype)initWithLocation:(CLLocationCoordinate2D)locationCoordinate;

@end
