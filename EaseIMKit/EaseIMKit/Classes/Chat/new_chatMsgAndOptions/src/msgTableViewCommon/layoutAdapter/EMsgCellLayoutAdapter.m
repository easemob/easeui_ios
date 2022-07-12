//
//  EMsgCellLayoutAdapter.m
//  EaseIMKit
//
//  Created by yangjian on 2022/5/17.
//

#import "EMsgCellLayoutAdapter.h"
//#import "EMsgTableViewFunctions.h"
@implementation EMsgCellUserInfoLayoutAdapter

- (float)headTakeWidth{
    return self.headFromSide + self.headWidth;
    
}
- (float)nameTakeHeight{
    return self.nameTop + self.nameHeight;
}

@end

@implementation EMsgCellMsgBackgroundLayoutAdapter

- (float)msgBackgroundWidth_userInfoAdapter:(EMsgCellUserInfoLayoutAdapter *)userInfoAdapter{
    return
    ESCREEN_W
    - userInfoAdapter.headTakeWidth
    - self.fromSide
    - self.toSide;
}

- (float)cellHeight_apartFrom_msgBackgroundHeight_userInfoAdapter:(EMsgCellUserInfoLayoutAdapter *)userInfoAdapter
                                         showName:(BOOL)showName{
    return
    self.top
    + self.bottom
    + (showName ? userInfoAdapter.nameTakeHeight : 0);
    
}
- (float)cellMinHeight_userInfoAdapter:(EMsgCellUserInfoLayoutAdapter *)userInfoAdapter{
    return
    userInfoAdapter.headTop
    + userInfoAdapter.headHeight
    + self.bottom;
}

@end

@implementation EMsgCellMsgContentLayoutAdapter
- (float)cellHeight_apartFrom_msgContentHeight_userInfoAdapter:(EMsgCellUserInfoLayoutAdapter *)userInfoAdapter
                             backgroundAdapter:(EMsgCellMsgBackgroundLayoutAdapter *)backgroundAdapter
                                      showName:(BOOL)showName{
    return
    [backgroundAdapter cellHeight_apartFrom_msgBackgroundHeight_userInfoAdapter:userInfoAdapter showName:showName]
    + self.top
    + self.bottom;
}

- (float)msgContentMaxWidth_userInfoAdapter:(EMsgCellUserInfoLayoutAdapter *)userInfoAdapter
          backgroundAdapter:(EMsgCellMsgBackgroundLayoutAdapter *)backgroundAdapter{
    return
    [backgroundAdapter msgBackgroundWidth_userInfoAdapter:userInfoAdapter]
    - self.fromSide
    - self.toSide;
}


@end

@implementation EMsgCellBubbleLayoutAdapter

- (UIImage *)bubbleImage:(EMMessageDirection)direction{
    switch (direction) {
        case EMMessageDirectionSend:
            return
            [[UIImage imageNamed:self.sendImageName]
                        resizableImageWithCapInsets:
                 UIEdgeInsetsMake(self.resizableTop, self.resizableToSide, self.resizableBottom, self.resizableFromSide)];
        case EMMessageDirectionReceive:
            return
            [[UIImage imageNamed:self.receiveImageName]
                        resizableImageWithCapInsets:
                 UIEdgeInsetsMake(self.resizableTop, self.resizableFromSide, self.resizableBottom, self.resizableToSide)];
        default:
            return [UIImage imageNamed:self.sendImageName];
    }
}

@end
