//
//  EaseConversationsViewController.h
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/10/29.
//

#import <UIKit/UIKit.h>
#import <Hyphenate/Hyphenate.h>
#import "EaseConversationCellOptions.h"
#import "EaseConversationCellModelDelegate.h"
#import "EMRefreshViewController.h"

@protocol EaseConversationVCDelegate <NSObject>

@optional
- (id<EaseConversationCellModelDelegate>)conversationCellForModel:(id<EaseConversationModelDelegate>)model;

@end

@interface EaseConversationsViewController : EMRefreshViewController
- (instancetype)initWithOptions:(EaseConversationCellOptions *)options;

@property (nonatomic, assign) id<EaseConversationVCDelegate> delegate;

@end

