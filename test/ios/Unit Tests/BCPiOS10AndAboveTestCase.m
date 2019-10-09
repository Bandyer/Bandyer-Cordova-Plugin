//
// Copyright © 2019 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information
//

#import "BCPiOS10AndAboveTestCase.h"


@implementation BCPiOS10AndAboveTestCase

+ (instancetype)testCaseWithInvocation:(nullable NSInvocation *)invocation
{
    if (@available(iOS 10.0, *))
        return [super testCaseWithInvocation:invocation];
    else
        return nil;
}

+ (instancetype)testCaseWithSelector:(SEL)selector
{
    if (@available(iOS 10.0, *))
        return [super testCaseWithSelector:selector];
    else
        return nil;
}


@end
