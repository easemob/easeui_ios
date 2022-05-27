//
//  EMsgTableViewFunctions.h
//  EaseIMKit
//
//  Created by yangjian on 2022/5/18.
//

#import <Foundation/Foundation.h>
#import "EMsgCellLayoutAdapterConfigs.h"
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN


@interface EMsgTableViewFunctions : NSObject

//NSAttributedString *attributedString(NSString *string ,UIFont *font ,UIColor *color);
//float fitHeight_attributedString(NSAttributedString *attributedString,float maxWidth);
//float fitHeight_string(NSString *string,UIFont *font,float maxWidth);
//CGSize messageCell_imageSizeToFitSize(CGSize imageSize);

+ (NSAttributedString *)attributedString:(NSString *)string font:(UIFont *)font color:(UIColor *)color;

+ (float)fitHeight_attributedString:(NSAttributedString *)attributedString maxWidth:(float)maxWidth;

//注意!下述高度,如果因为内容长度为0获取到了0的高度,会取font的高度来返回!
+ (float)fitHeight_string:(NSString *)string font:(UIFont *)font maxWidth:(float)maxWidth;

//图片适配
+ (CGSize)messageCell_imageSizeToFitSize:(CGSize)imageSize;

//视频缩略图适配
+ (CGSize)videoCoverFitSizeFromCoverSize:(CGSize)size;


@end

NS_ASSUME_NONNULL_END



