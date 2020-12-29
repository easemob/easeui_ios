

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
/*
#if __has_include(<Hyphenate/Hyphenate.h>)
#import <Hyphenate/Hyphenate.h>
#endif
#if __has_include(<HyphenateLite/HyphenateLite.h>)
#import <HyphenateLite/HyphenateLite.h>
#endif */


#if ENABLE_CALL == 1
#import <Hyphenate/Hyphenate.h>
#else
#import <HyphenateLite/HyphenateLite.h>


#import "EaseEnums.h"
#import "EaseDefines.h"


