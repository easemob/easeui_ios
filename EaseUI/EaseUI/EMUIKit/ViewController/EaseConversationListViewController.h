//
//  EaseConversationListViewController.h
//  ChatDemo-UI3.0
//
//  Created by dhc on 15/6/25.
//  Copyright (c) 2015年 easemob.com. All rights reserved.
//

#import "EaseRefreshTableViewController.h"

#import "EaseConversationModel.h"
#import "EaseConversationCell.h"

typedef NS_ENUM(int, DXDeleteConvesationType) {
    DXDeleteConvesationOnly,
    DXDeleteConvesationWithMessages,
};

@class EaseConversationListViewController;

@protocol EaseConversationListViewControllerDelegate <NSObject>

- (void)conversationListViewController:(EaseConversationListViewController *)conversationListViewController
            didSelectConversationModel:(id<IConversationModel>)conversationModel;

@optional

//- (void)conversationListViewController:(EaseConversationListViewController *)conversationListViewController
//                 didDeleteConversation:(id<IConversationModel>)conversation
//                          deletionMode:(DXDeleteConvesationType)deletionType;
//
//- (void)conversationListViewController:(EaseConversationListViewController *)conversationListViewController
//           didFailDeletingConversation:(id<IConversationModel>)conversation
//                          deletionMode:(DXDeleteConvesationType)deletionType;


@end

@protocol EaseConversationListViewControllerDataSource <NSObject>

- (id<IConversationModel>)conversationListViewController:(EaseConversationListViewController *)conversationListViewController
                        modelForConversation:(EMConversation *)conversation;

@optional

- (NSString *)conversationListViewController:(EaseConversationListViewController *)conversationListViewController
      latestMessageTitleForConversationModel:(id<IConversationModel>)conversationModel;

- (NSString *)conversationListViewController:(EaseConversationListViewController *)conversationListViewController
       latestMessageTimeForConversationModel:(id<IConversationModel>)conversationModel;

@end


@interface EaseConversationListViewController : EaseRefreshTableViewController

@property (weak, nonatomic) id<EaseConversationListViewControllerDelegate> delegate;
@property (weak, nonatomic) id<EaseConversationListViewControllerDataSource> dataSource;

- (void)tableViewDidTriggerHeaderRefresh;

@end
