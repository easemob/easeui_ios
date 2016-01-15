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

@class EaseEmotion;
@protocol EaseFacialViewDelegate

@optional
-(void)selectedFacialView:(NSString*)str;
-(void)deleteSelected:(NSString *)str;
-(void)sendFace;
-(void)sendFace:(EaseEmotion *)emotion;

@end

@class EaseEmotionManager;
@interface EaseFacialView : UIView
{
	NSMutableArray *_faces;
}

@property(nonatomic, weak) id<EaseFacialViewDelegate> delegate;

@property(strong, nonatomic, readonly) NSArray *faces;

-(void)loadFacialView:(NSArray*)emotionManagers size:(CGSize)size;

-(void)loadFacialViewWithPage:(NSInteger)page;

//-(void)loadFacialView:(int)page size:(CGSize)size;

@end
