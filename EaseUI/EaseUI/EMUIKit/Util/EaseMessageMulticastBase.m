//
//  EaseMessageMulticastBase.m
//
//  Created by WYZ on 16/2/19.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EaseMessageMulticastBase.h"

@implementation EaseMessageMulticastBase

- (id)init
{
    if ((self = [super init]))
    {
        multicastDelegate = [[EaseMessageHelpDelegate alloc] init];
    }
    return self;
}

- (void)addDelegate:(id<EaseMessageHelperProtocal>)delegate delegateQueue:(dispatch_queue_t)delegateQueue
{
    [multicastDelegate addDelegate:delegate delegateQueue:delegateQueue];
}
- (void)removeDelegate:(id<EaseMessageHelperProtocal>)delegate
{
    [multicastDelegate removeDelegate:delegate];
}

@end

@interface EaseMessageHelpNode : NSObject {
@private
    
#if __has_feature(objc_arc_weak)
    __weak id delegate;
#if !TARGET_OS_IPHONE
    __unsafe_unretained id unsafeDelegate; // Some classes don't support weak references yet (e.g. NSWindowController)
#endif
#else
    __unsafe_unretained id delegate;
#endif
    
    dispatch_queue_t delegateQueue;
}

- (id)initWithDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;

#if __has_feature(objc_arc_weak)
@property (/* atomic */ readwrite, weak) id delegate;
#if !TARGET_OS_IPHONE
@property (/* atomic */ readwrite, unsafe_unretained) id unsafeDelegate;
#endif
#else
@property (/* atomic */ readwrite, unsafe_unretained) id delegate;
#endif

@property (nonatomic, readonly) dispatch_queue_t delegateQueue;

@end

@implementation EaseMessageHelpNode

@synthesize delegate;       // atomic
#if __has_feature(objc_arc_weak) && !TARGET_OS_IPHONE
@synthesize unsafeDelegate; // atomic
#endif
@synthesize delegateQueue;  // non-atomic

#if __has_feature(objc_arc_weak) && !TARGET_OS_IPHONE
static BOOL SupportsWeakReferences(id delegate)
{
    if ([delegate isKindOfClass:[NSATSTypesetter class]])    return NO;
    if ([delegate isKindOfClass:[NSColorSpace class]])       return NO;
    if ([delegate isKindOfClass:[NSFont class]])             return NO;
    if ([delegate isKindOfClass:[NSFontManager class]])      return NO;
    if ([delegate isKindOfClass:[NSFontPanel class]])        return NO;
    if ([delegate isKindOfClass:[NSImage class]])            return NO;
    if ([delegate isKindOfClass:[NSParagraphStyle class]])   return NO;
    if ([delegate isKindOfClass:[NSTableCellView class]])    return NO;
    if ([delegate isKindOfClass:[NSTextView class]])         return NO;
    if ([delegate isKindOfClass:[NSViewController class]])   return NO;
    if ([delegate isKindOfClass:[NSWindow class]])           return NO;
    if ([delegate isKindOfClass:[NSWindowController class]]) return NO;
    
    return YES;
}
#endif

- (id)initWithDelegate:(id)inDelegate delegateQueue:(dispatch_queue_t)inDelegateQueue
{
    if ((self = [super init]))
    {
#if __has_feature(objc_arc_weak) && !TARGET_OS_IPHONE
        {
            if (SupportsWeakReferences(inDelegate))
            {
                delegate = inDelegate;
                delegateQueue = inDelegateQueue;
            }
            else
            {
                delegate = [NSNull null];
                
                unsafeDelegate = inDelegate;
                delegateQueue = inDelegateQueue;
            }
        }
#else
        {
            delegate = inDelegate;
            delegateQueue = inDelegateQueue;
        }
#endif
        
#if !OS_OBJECT_USE_OBJC
        if (delegateQueue)
            dispatch_retain(delegateQueue);
#endif
    }
    return self;
}

- (void)dealloc
{
#if !OS_OBJECT_USE_OBJC
    if (delegateQueue)
        dispatch_release(delegateQueue);
#endif
}

@end



@interface EaseMessageHelpDelegate ()
{
    NSMutableArray *delegateNodes;
}

- (NSInvocation *)duplicateInvocation:(NSInvocation *)origInvocation;

@end

@implementation EaseMessageHelpDelegate

- (instancetype)init
{
    if ((self = [super init]))
    {
        delegateNodes = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addDelegate:(id<EaseMessageHelperProtocal>)delegate delegateQueue:(dispatch_queue_t)delegateQueue
{
    if (delegate == nil) return;
    if (delegateQueue == NULL)
    {
        return;
    }
    EaseMessageHelpNode *node = [[EaseMessageHelpNode alloc] initWithDelegate:delegate delegateQueue:delegateQueue];
    [delegateNodes addObject:node];
}

- (void)removeDelegate:(id<EaseMessageHelperProtocal>)delegate delegateQueue:(dispatch_queue_t)delegateQueue
{
    if (delegate == nil) return;
    
    NSUInteger i;
    for (i = [delegateNodes count]; i > 0; i--)
    {
        EaseMessageHelpNode *node = [delegateNodes objectAtIndex:(i-1)];
        
        id nodeDelegate = node.delegate;
#if __has_feature(objc_arc_weak) && !TARGET_OS_IPHONE
        if (nodeDelegate == [NSNull null])
            nodeDelegate = node.unsafeDelegate;
#endif
        
        if (delegate == nodeDelegate)
        {
            if ((delegateQueue == NULL) || (delegateQueue == node.delegateQueue))
            {
                node.delegate = nil;
#if __has_feature(objc_arc_weak) && !TARGET_OS_IPHONE
                node.unsafeDelegate = nil;
#endif
                
                [delegateNodes removeObjectAtIndex:(i-1)];
            }
        }
    }
}

- (void)removeDelegate:(id<EaseMessageHelperProtocal>)delegate
{
    [self removeDelegate:delegate delegateQueue:NULL];
}

- (NSInvocation *)duplicateInvocation:(NSInvocation *)origInvocation
{
    NSMethodSignature *methodSignature = [origInvocation methodSignature];
    
    NSInvocation *dupInvocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    [dupInvocation setSelector:[origInvocation selector]];
    
    NSUInteger i, count = [methodSignature numberOfArguments];
    for (i = 2; i < count; i++)
    {
        const char *type = [methodSignature getArgumentTypeAtIndex:i];
        
        if (*type == *@encode(BOOL))
        {
            BOOL value;
            [origInvocation getArgument:&value atIndex:i];
            [dupInvocation setArgument:&value atIndex:i];
        }
        else if (*type == *@encode(char) || *type == *@encode(unsigned char))
        {
            char value;
            [origInvocation getArgument:&value atIndex:i];
            [dupInvocation setArgument:&value atIndex:i];
        }
        else if (*type == *@encode(short) || *type == *@encode(unsigned short))
        {
            short value;
            [origInvocation getArgument:&value atIndex:i];
            [dupInvocation setArgument:&value atIndex:i];
        }
        else if (*type == *@encode(int) || *type == *@encode(unsigned int))
        {
            int value;
            [origInvocation getArgument:&value atIndex:i];
            [dupInvocation setArgument:&value atIndex:i];
        }
        else if (*type == *@encode(long) || *type == *@encode(unsigned long))
        {
            long value;
            [origInvocation getArgument:&value atIndex:i];
            [dupInvocation setArgument:&value atIndex:i];
        }
        else if (*type == *@encode(long long) || *type == *@encode(unsigned long long))
        {
            long long value;
            [origInvocation getArgument:&value atIndex:i];
            [dupInvocation setArgument:&value atIndex:i];
        }
        else if (*type == *@encode(double))
        {
            double value;
            [origInvocation getArgument:&value atIndex:i];
            [dupInvocation setArgument:&value atIndex:i];
        }
        else if (*type == *@encode(float))
        {
            float value;
            [origInvocation getArgument:&value atIndex:i];
            [dupInvocation setArgument:&value atIndex:i];
        }
        else if (*type == '@')
        {
            void *value;
            [origInvocation getArgument:&value atIndex:i];
            [dupInvocation setArgument:&value atIndex:i];
        }
        else if (*type == '^')
        {
            void *block;
            [origInvocation getArgument:&block atIndex:i];
            [dupInvocation setArgument:&block atIndex:i];
        }
        else
        {
            NSString *selectorStr = NSStringFromSelector([origInvocation selector]);
            
            NSString *format = @"Argument %lu to method %@ - Type(%c) not supported";
            NSString *reason = [NSString stringWithFormat:format, (unsigned long)(i - 2), selectorStr, *type];
            
            [[NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil] raise];
        }
    }
    
    [dupInvocation retainArguments];
    
    return dupInvocation;
}

- (void)doNothing{}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    for (EaseMessageHelpNode *node in delegateNodes)
    {
        id nodeDelegate = node.delegate;
#if __has_feature(objc_arc_weak) && !TARGET_OS_IPHONE
        if (nodeDelegate == [NSNull null])
            nodeDelegate = node.unsafeDelegate;
#endif
        
        NSMethodSignature *result = [nodeDelegate methodSignatureForSelector:aSelector];
        
        if (result != nil)
        {
            return result;
        }
    }
    
    return [[self class] instanceMethodSignatureForSelector:@selector(doNothing)];
}

- (void)forwardInvocation:(NSInvocation *)origInvocation
{
    SEL selector = [origInvocation selector];
    BOOL foundNilDelegate = NO;
    
    for (EaseMessageHelpNode *node in delegateNodes)
    {
        id nodeDelegate = node.delegate;
#if __has_feature(objc_arc_weak) && !TARGET_OS_IPHONE
        if (nodeDelegate == [NSNull null])
            nodeDelegate = node.unsafeDelegate;
#endif
        
        if ([nodeDelegate respondsToSelector:selector])
        {
            // All delegates MUST be invoked ASYNCHRONOUSLY.
            
            NSInvocation *dupInvocation = [self duplicateInvocation:origInvocation];
            
            dispatch_async(node.delegateQueue, ^{ @autoreleasepool {
                
                [dupInvocation invokeWithTarget:nodeDelegate];
                
            }});
        }
        else if (nodeDelegate == nil)
        {
            foundNilDelegate = YES;
        }
    }
    
    if (foundNilDelegate)
    {
        NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
        
        NSUInteger i = 0;
        for (EaseMessageHelpNode *node in delegateNodes)
        {
            id nodeDelegate = node.delegate;
#if __has_feature(objc_arc_weak) && !TARGET_OS_IPHONE
            if (nodeDelegate == [NSNull null])
                nodeDelegate = node.unsafeDelegate;
#endif
            
            if (nodeDelegate == nil)
            {
                [indexSet addIndex:i];
            }
            i++;
        }
        
        [delegateNodes removeObjectsAtIndexes:indexSet];
    }
}

@end
