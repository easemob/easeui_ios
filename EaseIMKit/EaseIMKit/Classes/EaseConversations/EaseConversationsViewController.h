//
//  EaseConversationsViewController.h
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/10/29.
//

#import <UIKit/UIKit.h>
#import <Hyphenate/Hyphenate.h>
#import "EaseConversationVCOptions.h"
#import "EaseConversationCellModelDelegate.h"


@protocol EaseConversationVCDelegate <NSObject>

@optional
- (id<EaseConversationCellModelDelegate>)conversationCellForModel:(NSString *)conversationId
                                                     conversationType:(EMConversationType)aType;

@end

@interface EaseConversationsViewController : UIViewController
- (instancetype)initWithOptions:(EaseConversationVCOptions *)options;

@property (nonatomic, assign) id<EaseConversationVCDelegate> delegate;

@end

