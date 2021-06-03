// Copyright © 2021 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information

#import <OCHamcrest/OCHamcrest.h>
#import <Bandyer/BDKUserInfoDisplayItem.h>

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

    BDKUserInfoDisplayItem *item = [self makeItem];
    NSString *string = [sut stringForObjectValue:item];

    assertThat(string, equalTo(item.alias));
}

- (void)testStringForObjectValueShouldReturnAFormattedStringProvidedByTheProxeeFormatter
{
    BCPUserDetailsFormatter *realFormatter = [[BCPUserDetailsFormatter alloc] initWithFormat:@"${firstname} ${lastname}"];
    BCPFormatterProxy *sut = [BCPFormatterProxy new];
    sut.formatter = realFormatter;

    BDKUserInfoDisplayItem *item = [self makeItem];
    NSString *string = [sut stringForObjectValue:item];

    assertThat(string, equalTo([NSString stringWithFormat:@"%@ %@", item.firstName, item.lastName]));
}

- (void)testSetFormatterShouldThrowAnInvalidArgumentExceptionWhenNilValueIsProvided
{
    BCPFormatterProxy *sut = [BCPFormatterProxy new];

    assertThat(^{sut.formatter = nil;}, throwsInvalidArgumentException());
}

// MARK: Helpers

- (BDKUserInfoDisplayItem *)makeItem
{
    BDKUserInfoDisplayItem *item = [[BDKUserInfoDisplayItem alloc] initWithAlias:@"bob"];
    item.firstName = @"Robert";
    item.lastName = @"Martin";
    return item;
}

__SUPPRESS_WARNINGS_FOR_TEST_END

@end
