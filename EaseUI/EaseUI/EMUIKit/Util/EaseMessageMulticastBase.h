//
//  EaseMessageMulticastBase.h
//
//  Created by WYZ on 16/2/19.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EaseMessageHelperProtocal.h"

@interface EaseMessageMulticastBase : NSObject
{
    id multicastDelegate;
}
- (void)addDelegate:(id<EaseMessageHelperProtocal>)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
- (void)removeDelegate:(id<EaseMessageHelperProtocal>)delegate;

@end


@interface EaseMessageHelpDelegate : NSObject

- (void)addDelegate:(id<EaseMessageHelperProtocal>)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
- (void)removeDelegate:(id<EaseMessageHelperProtocal>)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
- (void)removeDelegate:(id<EaseMessageHelperProtocal>)delegate;

@end