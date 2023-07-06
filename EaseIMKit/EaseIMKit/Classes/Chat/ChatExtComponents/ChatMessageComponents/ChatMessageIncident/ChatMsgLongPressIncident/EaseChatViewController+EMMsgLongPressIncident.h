//
//  EaseChatViewController+EMMsgLongPressIncident.h
//  EaseIM
//
//  Created by 娜塔莎 on 2020/7/9.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import "EaseChatViewController.h"
#import "EaseMessageModel.h"
#import "EaseMessageCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface EaseChatViewController (EMMsgLongPressIncident)

//长按操作栏
@property (strong, nonatomic) NSIndexPath *__nullable longPressIndexPath;

- (void)deleteLongPressAction:(void (^)(EMChatMessage *deleteMsg))aCompletionBlock;
- (void)recallLongPressAction;
- (void)copyLongPressAction;

- (void)resetCellLongPressStatus:(EaseMessageCell *)aCell;

@end

NS_ASSUME_NONNULL_END
