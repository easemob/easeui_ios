//
//  Emoticon.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/31.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, EMEmotionType) {
    EMEmotionTypeEmoji = 0,
    EMEmotionTypePng,
    EMEmotionTypeGif,
};

@interface EaseEmoticonModel : NSObject

@property (nonatomic, strong) NSString *eId;

@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) NSString *imgName;

//local name or remote url
@property (nonatomic, strong) NSString *original;

@property (nonatomic, readonly) EMEmotionType type;

- (instancetype)initWithType:(EMEmotionType)aType;

@end


@interface EaseEmoticonGroup : NSObject

@property (nonatomic, readonly) EMEmotionType type;

@property (nonatomic, strong) id icon;

@property (nonatomic, strong, readonly) NSArray<EaseEmoticonModel *> *dataArray;

@property (nonatomic) NSInteger rowCount;

@property (nonatomic) NSInteger colCount;

- (instancetype)initWithType:(EMEmotionType)aType
                   dataArray:(NSArray<EaseEmoticonModel *> *)aDataArray
                        icon:(id)aIcon
                    rowCount:(NSInteger)aRowCount
                    colCount:(NSInteger)aColCount;

+ (instancetype)getGifGroup;

@end

@interface EMEmoticonCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imgView;

@property (nonatomic, strong) UILabel *label;

@property (nonatomic, strong) EaseEmoticonModel *model;

@end


@protocol EMEmoticonViewDelegate;
@interface EMEmoticonView : UIView

@property (nonatomic, weak) id<EMEmoticonViewDelegate> delegate;

@property (nonatomic) CGFloat viewHeight;

- (instancetype)initWithEmotionGroup:(EaseEmoticonGroup *)aEmotionGroup;

@end

@protocol EMEmoticonViewDelegate <NSObject>

@optional

- (void)emoticonViewDidSelectedModel:(EaseEmoticonModel *)aModel;

@end

NS_ASSUME_NONNULL_END
