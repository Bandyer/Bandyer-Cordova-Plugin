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
    BDKUserDetails *item = [self makeAnItemWithAlias:@"bob" firstname:@"Bob" lastname:nil];

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
    BDKUserDetails *item = [self makeAnItemWithAlias:@"bob" firstname:nil lastname:@"Appleseed"];

    NSString *string = [sut stringForObjectValue:item];

    assertThat(string, equalTo(@"Appleseed"));
}

- (void)testReturnsUserEmail
{
    BCPUserDetailsFormatter *sut = [self makeSUT:@"${email}"];
    BDKUserDetails *item = [self makeAnItemWithAlias:@"bob" email:@"bob.appleseed@acme.com"];

    NSString *string = [sut stringForObjectValue:item];

    assertThat(string, equalTo(@"bob.appleseed@acme.com"));
}

- (void)testReturnsUserNickname
{
    BCPUserDetailsFormatter *sut = [self makeSUT:@"${nickname}"];
    BDKUserDetails *item = [self makeAnItemWithAlias:@"bob" firstname:nil lastname:nil email:nil nickname:@"Bob"];

    NSString *string = [sut stringForObjectValue:item];

    assertThat(string, equalTo(@"Bob"));
}

- (void)testReturnsUserFullname
{
    BCPUserDetailsFormatter *sut = [self makeSUT:@"${firstName} ${lastName}"];
    BDKUserDetails *item = [self makeAnItemWithAlias:@"bob" firstname:@"Bob" lastname:@"Appleseed"];

    NSString *string = [sut stringForObjectValue:item];

    assertThat(string, equalTo(@"Bob Appleseed"));
}

- (void)testPreservesWhitespacesBetweenTokens
{
    BCPUserDetailsFormatter *sut = [self makeSUT:@"${firstName}     ${lastName}"];
    BDKUserDetails *item = [self makeAnItemWithAlias:@"bob" firstname:@"Bob" lastname:@"Appleseed"];

    NSString *string = [sut stringForObjectValue:item];

    assertThat(string, equalTo(@"Bob     Appleseed"));
}

- (void)testPreservesAnyCharacterBetweenTokens
{
    BCPUserDetailsFormatter *sut = [self makeSUT:@"${firstName} - + / . $ ${lastName}"];
    BDKUserDetails *item = [self makeAnItemWithAlias:@"bob" firstname:@"Bob" lastname:@"Appleseed"];

    NSString *string = [sut stringForObjectValue:item];

    assertThat(string, equalTo(@"Bob - + / . $ Appleseed"));
}

- (void)testMatchesAreInsensitiveToCase
{
    BCPUserDetailsFormatter *sut = [self makeSUT:@"${fIrStNaME} ${LasTNAmE}"];
    BDKUserDetails *item = [self makeAnItemWithAlias:@"bob" firstname:@"Bob" lastname:@"Appleseed"];

    NSString *string = [sut stringForObjectValue:item];

    assertThat(string, equalTo(@"Bob Appleseed"));
}

- (void)testReturnsSentence
{
    BCPUserDetailsFormatter *sut = [self makeSUT:@"Hello my name is: ${firstName} ${lastName}, friends call me ${nickname}"];
    BDKUserDetails *item = [self makeAnItemWithAlias:@"bob" firstname:@"Robert" lastname:@"Appleseed" email:nil nickname:@"Bob"];

    NSString *string = [sut stringForObjectValue:item];

    assertThat(string, equalTo(@"Hello my name is: Robert Appleseed, friends call me Bob"));
}

- (void)testPrintsOutUnknownToken
{
    BCPUserDetailsFormatter *sut = [self makeSUT:@"${firstname} ${unknown}"];
    BDKUserDetails *item = [self makeAnItemWithAlias:@"bob" firstname:@"Bob" lastname:nil];

    NSString *string = [sut stringForObjectValue:item];

    assertThat(string, equalTo(@"Bob ${unknown}"));
}

- (void)testNilValueReplacesTokenWithEmptyStringTrimmingTrailingWhitespaces
{
    BCPUserDetailsFormatter *sut = [self makeSUT:@"${firstname} ${lastname}"];
    BDKUserDetails *item = [self makeAnItemWithAlias:@"bob" firstname:@"Bob" lastname:nil];

    NSString *string = [sut stringForObjectValue:item];

    assertThat(string, equalTo(@"Bob"));
}

- (void)testReplacesTokensForEveryItemInTheArrayJoiningTheReplacedStringsWithAComma
{
    BCPUserDetailsFormatter *sut = [self makeSUT:@"${firstname} ${lastname}"];
    BDKUserDetails *firstItem = [self makeAnItemWithAlias:@"bob" firstname:@"Bob" lastname:@"Appleseed"];
    BDKUserDetails *secondItem = [self makeAnItemWithAlias:@"jane" firstname:@"Jane" lastname:@"Appleseed"];
    NSArray<BDKUserDetails *>*items = @[firstItem, secondItem];

    NSString *string = [sut stringForObjectValue:items];

    assertThat(string, notNilValue());
    assertThat(string, equalTo(@"Bob Appleseed, Jane Appleseed"));
}

- (void)testStringForObjectValueShouldDiscardAnyItemInTheArrayThatIsNotADisplayItem
{
    BCPUserDetailsFormatter *sut = [self makeSUT:@"${firstname} ${lastname}"];
    BDKUserDetails *firstItem = [self makeAnItemWithAlias:@"alias" firstname:@"Bob" lastname:@"Appleseed"];
    NSArray *items = @[firstItem, @"foreign item"];

    NSString *string = [sut stringForObjectValue:items];

    assertThat(string, notNilValue());
    assertThat(string, equalTo(@"Bob Appleseed"));
}

- (void)testReturnsUserAliasWhenNoneOfTheTokensCanBeReplacedBecauseTheItemDoesNotProvideAnyValueForTheTokensDefinedInTheFormat
{
    BCPUserDetailsFormatter *sut = [self makeSUT:@"${firstname} ${lastname}"];
    BDKUserDetails *item = [self makeAnItemWithAlias:@"alias"];
    NSArray<BDKUserDetails *>*items = @[item];

    NSString *string = [sut stringForObjectValue:items];

    assertThat(string, equalTo(item.alias));
}

// MARK: Helpers

- (BCPUserDetailsFormatter *)makeSUT:(NSString *)format
{
    return [[BCPUserDetailsFormatter alloc] initWithFormat:format];
}

- (BDKUserDetails *)makeAnItem
{
    return [self makeAnItemWithAlias:@"alias"];
}

- (BDKUserDetails *)makeAnItemWithAlias:(NSString *)alias
{
    return [self makeAnItemWithAlias:alias firstname:nil lastname:nil];
}

- (BDKUserDetails *)makeAnItemWithAlias:(NSString *)alias email:(NSString *)email
{
    return [self makeAnItemWithAlias:alias firstname:nil lastname:nil email:email];
}

- (BDKUserDetails *)makeAnItemWithAlias:(NSString *)alias
                              firstname:(nullable NSString *)firstname
                               lastname:(nullable NSString *)lastname

{
    return [self makeAnItemWithAlias:alias firstname:firstname lastname:lastname email:nil];
}

- (BDKUserDetails *)makeAnItemWithAlias:(NSString *)alias
                              firstname:(nullable NSString *)firstname
                               lastname:(nullable NSString *)lastname
                                  email:(nullable NSString *)email
{
    return [self makeAnItemWithAlias:alias firstname:firstname lastname:lastname email:email nickname:nil];
}

- (BDKUserDetails *)makeAnItemWithAlias:(NSString *)alias
                              firstname:(nullable NSString *)firstname
                               lastname:(nullable NSString *)lastname
                                  email:(nullable NSString *)email
                               nickname:(nullable NSString *)nickname
{
    NSParameterAssert(alias);

    return [[BDKUserDetails alloc] initWithAlias:alias
                                       firstname:firstname
                                        lastname:lastname
                                           email:email
                                        nickname:nickname
                                        imageURL:[NSURL fileURLWithPath:@"img/res/bob.png"]];
}

__SUPPRESS_WARNINGS_FOR_TEST_END

@end
