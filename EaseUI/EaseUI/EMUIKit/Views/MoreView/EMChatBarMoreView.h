/************************************************************
  *  * EaseMob CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of EaseMob Technologies.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from EaseMob Technologies.
  */

#import <UIKit/UIKit.h>

typedef enum{
    EMChatToolbarTypeChat,
    EMChatToolbarTypeGroup,
}EMChatToolbarType;

@protocol EMChatBarMoreViewDelegate;
@interface EMChatBarMoreView : UIView

@property (nonatomic,assign) id<EMChatBarMoreViewDelegate> delegate;

@property (nonatomic) UIColor *moreViewBackgroundColor UI_APPEARANCE_SELECTOR;  //moreview背景颜色,default whiteColor

- (instancetype)initWithFrame:(CGRect)frame type:(EMChatToolbarType)type;

/*!
 @method
 @brief 新增一个新的功能按钮
 @discussion
 @param image 按钮图片
 @param highLightedImage 高亮图片
 @param title 按钮标题
 @result
 */
- (void)insertItemWithImage:(UIImage*)image
           highlightedImage:(UIImage*)highLightedImage
                      title:(NSString*)title;

/*!
 @method
 @brief 修改功能按钮图片
 @discussion
 @param image 按钮图片
 @param highLightedImage 高亮图片
 @param title 按钮标题
 @param index 按钮索引
 @result
 */
- (void)updateItemWithImage:(UIImage*)image
           highlightedImage:(UIImage*)highLightedImage
                      title:(NSString*)title
                    atIndex:(NSInteger)index;

/*!
 @method
 @brief 根据索引删除功能按钮
 @discussion
 @param index 按钮索引
 @result
 */
- (void)removeItematIndex:(NSInteger)index;

@end

@protocol EMChatBarMoreViewDelegate <NSObject>

@optional

/*!
 @method
 @brief 默认功能
 @discussion
 @param moreView 功能view
 @result
 */
- (void)moreViewTakePicAction:(EMChatBarMoreView *)moreView;
- (void)moreViewPhotoAction:(EMChatBarMoreView *)moreView;
- (void)moreViewLocationAction:(EMChatBarMoreView *)moreView;
- (void)moreViewAudioCallAction:(EMChatBarMoreView *)moreView;
- (void)moreViewVideoCallAction:(EMChatBarMoreView *)moreView;

/*!
 @method
 @brief 发送消息后的回调
 @discussion
 @param moreView 功能view
 @param index    按钮索引
 @result
 */
- (void)moreView:(EMChatBarMoreView *)moreView didItemInMoreViewAtIndex:(NSInteger)index;

@end
