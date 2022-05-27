//
//  EMsgTableViewFunctions.m
//  EaseIMKit
//
//  Created by yangjian on 2022/5/18.
//

#import "EMsgTableViewFunctions.h"

NSAttributedString *attributedString(NSString *string ,UIFont *font ,UIColor *color){
    return
    [[NSAttributedString alloc] initWithString:string
                                    attributes:@{
        NSFontAttributeName :font,
        NSForegroundColorAttributeName :color,
    }];
}

float fitHeight_attributedString(NSAttributedString *attributedString,float maxWidth){
    return ceilf([attributedString boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size.height);
}

float fitHeight_string(NSString *string,UIFont *font,float maxWidth){
    return ceilf(
                 [string boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
                                      options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                   attributes:@{NSFontAttributeName : font} context:nil].size.height
                 );
    
}


//图片宽高
#define MESSAGECELL_IMAGE_MINWIDTH      30
#define MESSAGECELL_IMAGE_MINHEIGHT     30
#define MESSAGECELL_IMAGE_MAXWIDTH      EMsgCellLayoutAdapterConfigs.shared.msgContentMaxWidth
#define MESSAGECELL_IMAGE_MAXHEIGHT     800
CGSize messageCell_imageSizeToFitSize(CGSize imageSize) {
    /*
     1
     宽比高的比例最小值为 minwidth : maxheight
     如果超过上述底线,说明图片过高,则直接按照宽度为最小值,高度为最大值,裁切图片展示.
     ===至此已完成图片比例控制以及展示
     2
     宽比高的比例最大值为 maxwidth : minheight
     如果超过上述上线,说明图片过宽,则直接按照宽度为最大值,高度为最小值,裁切图片展示.
     ===至此已完成图片比例控制以及展示
     3
     当图片比例在范围内时.
     (在范围内时说明,任何一方过大,按照比例缩小至下限或扩大至上限,依然不会超出比例范围)
     判断
     宽是否过大
     高是否过大
     若都过大,按照 图片尺寸比最大尺寸比值最大的一个边为准
     若上述成立,则
     按照过大一方,比例缩小至上限宽度
     ===至此已完成图片比例控制以及展示
     4
     判断
     宽是否过小
     高是否过小
     若都过小,按照 图片尺寸比最小尺寸比值最小的一个边为准
     若上述成立,则
     按照过小一方,比例扩大至下限宽度
     ===至此已完成图片比例控制以及展示
     5
     当以上都不成立时
     按照正常尺寸展示
     ===至此已完成图片比例控制以及展示
     */

    //bug补充
    if (imageSize.width == 0 || imageSize.height == 0) {
        return CGSizeMake(MESSAGECELL_IMAGE_MINWIDTH, MESSAGECELL_IMAGE_MINHEIGHT);
    }
    
    //第一步,判断比例,做等比缩放
    float imageAspectRatio = imageSize.width / imageSize.height;
    float minAspectRatio = MESSAGECELL_IMAGE_MINWIDTH / MESSAGECELL_IMAGE_MAXHEIGHT;
    float maxAspectRatio = MESSAGECELL_IMAGE_MAXWIDTH / MESSAGECELL_IMAGE_MINHEIGHT;
    if (imageAspectRatio < minAspectRatio || imageAspectRatio > maxAspectRatio) {
        //在比例超限的前提下 宽度过宽 或 高度过高
        float fitWidth = 0;
        float fitHeight = 0;
        if (imageSize.width < MESSAGECELL_IMAGE_MINWIDTH) {
            fitWidth = MESSAGECELL_IMAGE_MINWIDTH;
        }else if (imageSize.width > MESSAGECELL_IMAGE_MAXWIDTH) {
            fitWidth = MESSAGECELL_IMAGE_MAXWIDTH;
        }else{
            fitWidth = imageSize.width;
        }
        if (imageSize.height < MESSAGECELL_IMAGE_MINHEIGHT) {
            fitHeight = MESSAGECELL_IMAGE_MINHEIGHT;
        }else if (imageSize.height > MESSAGECELL_IMAGE_MAXHEIGHT) {
            fitHeight = MESSAGECELL_IMAGE_MAXHEIGHT;
        }else{
            fitHeight = imageSize.height;
        }
        return
        CGSizeMake(fitWidth, fitHeight);
    }
    
    //第二步,在范围内.判断是否小于最小值.
    //宽度
    if (imageSize.width < MESSAGECELL_IMAGE_MINWIDTH) {
        float fitHeight =  imageSize.height * MESSAGECELL_IMAGE_MINWIDTH / imageSize.width;
        return
        CGSizeMake(MESSAGECELL_IMAGE_MINWIDTH, floorf(fitHeight));
    }
    //高度
    if (imageSize.height < MESSAGECELL_IMAGE_MINHEIGHT) {
        float fitWidth =  imageSize.width * MESSAGECELL_IMAGE_MINHEIGHT / imageSize.height;
        return
        CGSizeMake(floorf(fitWidth), MESSAGECELL_IMAGE_MINHEIGHT);
    }
    
    //第三步,判断是否大于最大值.
    //宽度
    if (imageSize.width > MESSAGECELL_IMAGE_MAXWIDTH) {
        float fitHeight = imageSize.height * MESSAGECELL_IMAGE_MAXWIDTH / imageSize.width;
        return
        CGSizeMake(MESSAGECELL_IMAGE_MAXWIDTH, floorf(fitHeight));
    }
    //高度
    if (imageSize.height > MESSAGECELL_IMAGE_MAXHEIGHT) {
        float fitWidth = imageSize.width * MESSAGECELL_IMAGE_MAXHEIGHT / imageSize.height;
        return
        CGSizeMake(floorf(fitWidth), MESSAGECELL_IMAGE_MAXHEIGHT);
    }
    return imageSize;

}



@implementation EMsgTableViewFunctions

+ (NSAttributedString *)attributedString:(NSString *)string font:(UIFont *)font color:(UIColor *)color{
    return
    attributedString(string, font, color);
}
+ (float)fitHeight_attributedString:(NSAttributedString *)attributedString maxWidth:(float)maxWidth{
    return fitHeight_attributedString(attributedString, maxWidth);
}
+ (float)fitHeight_string:(NSString *)string font:(UIFont *)font maxWidth:(float)maxWidth{
    return MAX(fitHeight_string(string, font, maxWidth), font.lineHeight);
}
+ (CGSize)messageCell_imageSizeToFitSize:(CGSize)imageSize{
    return messageCell_imageSizeToFitSize(imageSize);
}

+ (CGSize)videoCoverFitSizeFromCoverSize:(CGSize)size{
    if (size.width > size.height) {
        return CGSizeMake(EMsgCellLayoutAdapterConfigs.shared.msgContentMaxWidth, ceilf(EMsgCellLayoutAdapterConfigs.shared.msgContentMaxWidth * 9 / 16));
    }
    return CGSizeMake(ceilf(EMsgCellLayoutAdapterConfigs.shared.msgContentMaxWidth * 9 / 16),EMsgCellLayoutAdapterConfigs.shared.msgContentMaxWidth);
}


@end
