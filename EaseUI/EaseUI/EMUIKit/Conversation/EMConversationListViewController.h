//
//  EMConversationListViewController.h
//  ChatDemo-UI3.0
//
//  Created by dhc on 15/6/25.
//  Copyright (c) 2015年 easemob.com. All rights reserved.
//

#import "EMRefreshTableViewController.h"

#import "EMConversationModel.h"
#import "EMConversationCell.h"

typedef NS_ENUM(int, DXDeleteConvesationType) {
    DXDeleteConvesationOnly,
    DXDeleteConvesationWithMessages,
};

@class EMConversationListViewController;

@protocol EMConversationListViewControllerDelegate <NSObject>

- (void)conversationListViewController:(EMConversationListViewController *)conversationListViewController
            didSelectConversationModel:(id<IConversationModel>)conversationModel;

@optional

//- (void)conversationListViewController:(EMConversationListViewController *)conversationListViewController
//                 didDeleteConversation:(id<IConversationModel>)conversation
//                          deletionMode:(DXDeleteConvesationType)deletionType;
//
//- (void)conversationListViewController:(EMConversationListViewController *)conversationListViewController
//           didFailDeletingConversation:(id<IConversationModel>)conversation
//                          deletionMode:(DXDeleteConvesationType)deletionType;


@end

@protocol EMConversationListViewControllerDataSource <NSObject>

- (id<IConversationModel>)conversationListViewController:(EMConversationListViewController *)conversationListViewController
                        modelForConversation:(EMConversation *)conversation;

@optional

- (NSString *)conversationListViewController:(EMConversationListViewController *)conversationListViewController
      latestMessageTitleForConversationModel:(id<IConversationModel>)conversationModel;

- (NSString *)conversationListViewController:(EMConversationListViewController *)conversationListViewController
       latestMessageTimeForConversationModel:(id<IConversationModel>)conversationModel;

@end


@interface EMConversationListViewController : EMRefreshTableViewController

@property (weak, nonatomic) id<EMConversationListViewControllerDelegate> delegate;
@property (weak, nonatomic) id<EMConversationListViewControllerDataSource> dataSource;

- (void)tableViewDidTriggerHeaderRefresh;

@end
