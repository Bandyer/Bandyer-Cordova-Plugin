// Copyright © 2020 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information

#import <XCTest/XCTest.h>
#import <OCHamcrest/OCHamcrest.h>
#import <Bandyer/Bandyer.h>

#import "BCPTestCase.h"
#import "BCPUserDetailsFormatter.h"
#import "BCPExceptionsMatcher.h"
#import "BCPTestingMacros.h"

@interface BCPUserDetailsFormatterTests : BCPTestCase

@end

@implementation BCPUserDetailsFormatterTests

__SUPPRESS_WARNINGS_FOR_TEST_BEGIN

- (void)testThrowsInvalidArgumentExceptionWhenNilFormatIsProvided
{
    assertThat(^{[[BCPUserDetailsFormatter alloc] initWithFormat:nil];}, throwsInvalidArgumentException());
}

- (void)testReturnsUserFirstName
{
    BCPUserDetailsFormatter *sut = [self makeSUT:@"${firstName}"];
    BDKUserInfoDisplayItem *item = [self makeAnItem];
    item.firstName = @"Bob";

    NSString *string = [sut stringForObjectValue:item];

    assertThat(string, equalTo(@"Bob"));
}

- (void)testReturnsNilWhenUnknownItemIsProvidedAsArgument
{
    BCPUserDetailsFormatter *sut = [self makeSUT:@"${firstName}"];

    NSString *string = [sut stringForObjectValue:self];

    assertThat(string, nilValue());
}

- (void)testReturnsUserLastName
{
    BCPUserDetailsFormatter *sut = [self makeSUT:@"${lastName}"];
    BDKUserInfoDisplayItem *item = [self makeAnItem];
    item.lastName = @"Appleseed";

    NSString *string = [sut stringForObjectValue:item];

    assertThat(string, equalTo(@"Appleseed"));
}

- (void)testReturnsUserEmail
{
    BCPUserDetailsFormatter *sut = [self makeSUT:@"${email}"];
    BDKUserInfoDisplayItem *item = [self makeAnItem];
    item.email = @"bob.appleseed@acme.com";

    NSString *string = [sut stringForObjectValue:item];

    assertThat(string, equalTo(@"bob.appleseed@acme.com"));
}

- (void)testReturnsUserNickname
{
    BCPUserDetailsFormatter *sut = [self makeSUT:@"${nickname}"];
    BDKUserInfoDisplayItem *item = [self makeAnItem];
    item.nickname = @"Bob";

    NSString *string = [sut stringForObjectValue:item];

    assertThat(string, equalTo(@"Bob"));
}

- (void)testReturnsUserFullname
{
    BCPUserDetailsFormatter *sut = [self makeSUT:@"${firstName} ${lastName}"];
    BDKUserInfoDisplayItem *item = [self makeAnItem];
    item.firstName = @"Bob";
    item.lastName = @"Appleseed";

    NSString *string = [sut stringForObjectValue:item];

    assertThat(string, equalTo(@"Bob Appleseed"));
}

- (void)testPreservesWhitespacesBetweenTokens
{
    BCPUserDetailsFormatter *sut = [self makeSUT:@"${firstName}     ${lastName}"];
    BDKUserInfoDisplayItem *item = [self makeAnItem];
    item.firstName = @"Bob";
    item.lastName = @"Appleseed";

    NSString *string = [sut stringForObjectValue:item];

    assertThat(string, equalTo(@"Bob     Appleseed"));
}

- (void)testPreservesAnyCharacterBetweenTokens
{
    BCPUserDetailsFormatter *sut = [self makeSUT:@"${firstName} - + / . $ ${lastName}"];
    BDKUserInfoDisplayItem *item = [self makeAnItem];
    item.firstName = @"Bob";
    item.lastName = @"Appleseed";

    NSString *string = [sut stringForObjectValue:item];

    assertThat(string, equalTo(@"Bob - + / . $ Appleseed"));
}

- (void)testMatchesAreInsensitiveToCase
{
    BCPUserDetailsFormatter *sut = [self makeSUT:@"${fIrStNaME} ${LasTNAmE}"];
    BDKUserInfoDisplayItem *item = [self makeAnItem];
    item.firstName = @"Bob";
    item.lastName = @"Appleseed";

    NSString *string = [sut stringForObjectValue:item];

    assertThat(string, equalTo(@"Bob Appleseed"));
}

- (void)testReturnsSentence
{
    BCPUserDetailsFormatter *sut = [self makeSUT:@"Hello my name is: ${firstName} ${lastName}, friends call me ${nickname}"];
    BDKUserInfoDisplayItem *item = [self makeAnItem];
    item.firstName = @"Robert";
    item.lastName = @"Appleseed";

    NSString *string = [sut stringForObjectValue:item];

    assertThat(string, equalTo(@"Hello my name is: Robert Appleseed, friends call me Bob"));
}

- (void)testPrintsOutUnknownToken
{
    BCPUserDetailsFormatter *sut = [self makeSUT:@"${firstname} ${unknown}"];
    BDKUserInfoDisplayItem *item = [self makeAnItem];
    item.firstName = @"Bob";

    NSString *string = [sut stringForObjectValue:item];

    assertThat(string, equalTo(@"Bob ${unknown}"));
}

- (void)testNilValueReplacesTokenWithEmptyStringTrimmingTrailingWhitespaces
{
    BCPUserDetailsFormatter *sut = [self makeSUT:@"${firstname} ${lastname}"];
    BDKUserInfoDisplayItem *item = [self makeAnItem];
    item.firstName = @"Bob";
    item.lastName = nil;

    NSString *string = [sut stringForObjectValue:item];

    assertThat(string, equalTo(@"Bob"));
}

// MARK: Helpers

- (BCPUserDetailsFormatter *)makeSUT:(NSString *)format
{
    return [[BCPUserDetailsFormatter alloc] initWithFormat:format];
}

- (BDKUserInfoDisplayItem *)makeAnItem
{
    BDKUserInfoDisplayItem *item = [[BDKUserInfoDisplayItem alloc] initWithAlias:@"alias"];
    item.firstName = @"Robert";
    item.lastName = @"Appleseed";
    item.email = @"bob.appleseed@acme.com";
    item.nickname = @"Bob";
    item.imageURL = [NSURL fileURLWithPath:@"img/res/bob.png"];
    return item;
}

__SUPPRESS_WARNINGS_FOR_TEST_END

@end
