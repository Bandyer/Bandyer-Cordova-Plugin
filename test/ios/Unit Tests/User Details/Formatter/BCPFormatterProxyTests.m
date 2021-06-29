// Copyright © 2021 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information

#import <OCHamcrest/OCHamcrest.h>
#import <Bandyer/BDKUserDetails.h>

#import "BCPTestCase.h"
#import "BCPTestingMacros.h"
#import "BCPExceptionsMatcher.h"
#import "BCPUserDetailsFormatter.h"

#import "BCPFormatterProxy.h"

@interface BCPFormatterProxyTests : BCPTestCase

@end

@implementation BCPFormatterProxyTests

__SUPPRESS_WARNINGS_FOR_TEST_BEGIN

- (void)testStringForObjectValueShouldReturnAFormattedStringProvidedByTheFallbackFormatter
{
    BCPFormatterProxy *sut = [BCPFormatterProxy new];

    BDKUserDetails *item = [self makeItem];
    NSString *string = [sut stringForObjectValue:item];

    assertThat(string, equalTo(item.alias));
}

- (void)testStringForObjectValueShouldReturnAFormattedStringProvidedByTheProxeeFormatter
{
    BCPUserDetailsFormatter *realFormatter = [[BCPUserDetailsFormatter alloc] initWithFormat:@"${firstname} ${lastname}"];
    BCPFormatterProxy *sut = [BCPFormatterProxy new];
    sut.formatter = realFormatter;

    BDKUserDetails *item = [self makeItem];
    NSString *string = [sut stringForObjectValue:item];

    assertThat(string, equalTo([NSString stringWithFormat:@"%@ %@", item.firstname, item.lastname]));
}

- (void)testSetFormatterShouldThrowAnInvalidArgumentExceptionWhenNilValueIsProvided
{
    BCPFormatterProxy *sut = [BCPFormatterProxy new];

    assertThat(^{sut.formatter = nil;}, throwsInvalidArgumentException());
}

// MARK: Helpers

- (BDKUserDetails *)makeItem
{
    return [[BDKUserDetails alloc] initWithAlias:@"bob"
                                       firstname:@"Robert"
                                        lastname:@"Martin"];
}

__SUPPRESS_WARNINGS_FOR_TEST_END

@end
