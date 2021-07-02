// Copyright © 2021 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information

#import "BCPiOS12AndAboveTestCase.h"

@implementation BCPiOS12AndAboveTestCase

+ (instancetype)testCaseWithSelector:(SEL)selector
{
    if (@available(iOS 12.0, *))
    {
        return [super testCaseWithSelector:selector];
    } else
    {
        return nil;
    }
}

+ (instancetype)testCaseWithInvocation:(NSInvocation *)invocation
{
    if (@available(iOS 12.0, *))
    {
        return [super testCaseWithInvocation:invocation];
    } else
    {
        return nil;
    }
}

@end
