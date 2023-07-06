//
//  EaseMessageStatusView.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/25.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EaseHeaders.h"

@interface EaseMessageStatusView : UIView

@property (nonatomic, copy) void (^resendCompletion)(void);

- (void)setSenderStatus:(EMMessageStatus)aStatus
            isReadAcked:(BOOL)aIsReadAcked;

@end
