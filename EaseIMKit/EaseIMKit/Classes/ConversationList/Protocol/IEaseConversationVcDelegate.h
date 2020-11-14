//
//  IEaseConversationVcDelegate.h
//  EaseIMKit
//
//  Created by 娜塔莎 on 2020/11/14.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "EaseConversationVcDelegate.h"
#import "EaseConversationViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol IEaseConversationVcDelegate <NSObject>

@required

//添加会话列表代理
- (void)addDelegate:(id<EaseConversationVCDelegate>)aDelegate;
 
@optional
//根据 viewmodel 重新刷新会话列表
- (void)resetViewModel:(EaseConversationViewModel *)viewModel;

@end

NS_ASSUME_NONNULL_END
