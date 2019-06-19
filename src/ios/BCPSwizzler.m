//
// Copyright © 2019 Bandyer S.r.l. All Rights Reserved.
// See LICENSE for licensing information
//

#import <objc/runtime.h>
#import "BCPSwizzler.h"

@implementation BCPSwizzler

- (instancetype)initWithClass:(Class)sourceClass sourceSelector:(SEL)sourceSelector targetSelector:(SEL)targetSelector
{
    NSAssert(sourceClass, @"A source class must be provided, got NULL");
    NSAssert(sourceSelector, @"A source selector must be provided, got NULL");
    NSAssert(targetSelector, @"A target selector must be provided, got NULL");

    self = [super init];

    if (self)
    {
        _sourceClass = sourceClass;
        _sourceSelector = sourceSelector;
        _targetSelector = targetSelector;
    }

    return self;
}

- (void)swizzle 
{
    Method original = class_getInstanceMethod(self.sourceClass, self.sourceSelector);
    Method swizzled = class_getInstanceMethod(self.sourceClass, self.targetSelector);
    
    BOOL didAddMethod = class_addMethod(self.sourceClass, self.sourceSelector, method_getImplementation(swizzled), method_getTypeEncoding(swizzled));
    
    if (didAddMethod)
        class_replaceMethod(self.sourceClass, self.targetSelector, method_getImplementation(original), method_getTypeEncoding(original));
    else 
        method_exchangeImplementations(original, swizzled);
}

@end