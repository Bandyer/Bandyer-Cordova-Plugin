// Copyright © 2021 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information

#import "BCPFormatterProxy.h"
#import "BCPUserDetailsFormatter.h"
#import "BCPMacros.h"

@interface BCPFormatterProxy()

@end

@implementation BCPFormatterProxy
@synthesize formatter = _formatter;

- (void)setFormatter:(NSFormatter *)formatter
{
    BCPAssertOrThrowInvalidArgument(formatter, @"A formatter must be provided, got nil");

    @synchronized (self)
    {
        _formatter = formatter;
    }
}

- (NSFormatter *)formatter
{
    @synchronized (self)
    {
        return _formatter;
    }
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _formatter = [[BCPUserDetailsFormatter alloc] initWithFormat:@"${useralias}"];
    }
    return self;
}

- (NSString *)stringForObjectValue:(id)obj
{
    return [self.formatter stringForObjectValue:obj];
}

@end
