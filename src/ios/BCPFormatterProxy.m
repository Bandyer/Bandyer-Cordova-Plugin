// Copyright © 2021 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information

#import "BCPFormatterProxy.h"
#import "BCPUserDetailsFormatter.h"
#import "BCPMacros.h"

@interface BCPFormatterProxy()

@end

@implementation BCPFormatterProxy

- (void)setFormatter:(NSFormatter *)formatter
{
    BCPAssertOrThrowInvalidArgument(formatter, @"A formatter must be provided, got nil");

    _formatter = formatter;
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
