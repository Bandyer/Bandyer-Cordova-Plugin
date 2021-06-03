//
// Copyright © 2019 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information
//

#import <OCHamcrest/OCHamcrest.h>
#import <CallKit/CallKit.h>

#import "BCPiOS10AndAboveTestCase.h"
#import "BCPTestingMacros.h"
#import "BCPExceptionsMatcher.h"

#import "BCPContactHandleProvider.h"
#import "BCPUsersDetailsCache.h"
#import "BCPUserDetailsFormatter.h"

API_AVAILABLE(ios(10.0))
@interface BCPContactHandleProviderTest : BCPiOS10AndAboveTestCase

@end

@implementation BCPContactHandleProviderTest
{
    BDKUserInfoDisplayItem *item1;
    BDKUserInfoDisplayItem *item2;
    BDKUserInfoDisplayItem *item3;
}

- (void)setUp
{
    [super setUp];

    [self createItems];
}

- (void)createItems
{
    item1 = [[BDKUserInfoDisplayItem alloc] initWithAlias:@"item1"];
    item1.firstName = @"John";
    item1.lastName = @"Appleseed";

    item2 = [[BDKUserInfoDisplayItem alloc] initWithAlias:@"item2"];
    item2.firstName = @"Jane";
    item2.lastName = @"Appleseed";

    item3 = [[BDKUserInfoDisplayItem alloc] initWithAlias:@"item3"];
}

__SUPPRESS_WARNINGS_FOR_TEST_BEGIN

- (void)testThrowsInvalidArgumentExceptionWhenMandatoryArgumentIsNotProvidedInDesignatedInitializer
{
    assertThat(^{[[BCPContactHandleProvider alloc] initWithCache:nil formatter:[NSFormatter new]];}, throwsInvalidArgumentException());
    assertThat(^{[[BCPContactHandleProvider alloc] initWithCache:[self makeEmptyCache] formatter:nil];}, throwsInvalidArgumentException());
}

- (void)testCreatesGenericHandleWithValueFormattedByTheFormatterProvidedInInitialization
{
    BCPUsersDetailsCache *cache = [self makePopulatedCache];
    NSFormatter *formatter = [self makeDetailsFormatter:@"${firstname} ${lastname}"];
    BCPContactHandleProvider *sut = [self makeSUTWithCache:cache formatter:formatter];

    XCTestExpectation *expc = [self expectationWithDescription:@"Callback invoked"];

    [sut handleForAliases:@[item1.alias] completion:^(CXHandle *handle) {
        [expc fulfill];

        assertThat(handle, notNilValue());
        assertThatInteger(handle.type, equalToInteger(CXHandleTypeGeneric));
        assertThat(handle.value, equalTo(@"John Appleseed"));
    }];

    [self waitForExpectations:@[expc] timeout:0];
}

- (void)testCreatesGenericContactHandleWhenItemIsMissingFromCache
{
    BCPUsersDetailsCache *cache = [self makePopulatedCache];
    NSFormatter *formatter = [self makeDetailsFormatter:@"${firstname} ${lastname}"];
    BCPContactHandleProvider *sut = [self makeSUTWithCache:cache formatter:formatter];

    XCTestExpectation *expc = [self expectationWithDescription:@"Callback invoked"];

    [sut handleForAliases:@[@"missing"] completion:^(CXHandle *handle) {
        [expc fulfill];

        assertThat(handle, notNilValue());
        assertThatInteger(handle.type, equalToInteger(CXHandleTypeGeneric));
        assertThat(handle.value, equalTo(@"missing"));
    }];

    [self waitForExpectations:@[expc] timeout:0];
}

- (void)testCreatesGenericContactHandleWithAliasAsHandleValueWhenItemIsMissingTheRequestedValues
{
    BCPUsersDetailsCache *cache = [self makePopulatedCache];
    NSFormatter *formatter = [self makeDetailsFormatter:@"${firstname} ${lastname}"];
    BCPContactHandleProvider *sut = [self makeSUTWithCache:cache formatter:formatter];

    XCTestExpectation *expc = [self expectationWithDescription:@"Callback invoked"];

    [sut handleForAliases:@[item3.alias] completion:^(CXHandle *handle) {
        [expc fulfill];

        assertThat(handle, notNilValue());
        assertThatInteger(handle.type, equalToInteger(CXHandleTypeGeneric));
        assertThat(handle.value, equalTo(item3.alias));
    }];

    [self waitForExpectations:@[expc] timeout:0];
}

- (void)testCreatesGenericContactHandleConcatenatingItemsFullnamesAsHandleValue
{
    BCPUsersDetailsCache *cache = [self makePopulatedCache];
    NSFormatter *formatter = [self makeDetailsFormatter:@"${firstname} ${lastname}"];
    BCPContactHandleProvider *sut = [self makeSUTWithCache:cache formatter:formatter];

    XCTestExpectation *expc = [self expectationWithDescription:@"Callback invoked"];

    [sut handleForAliases:@[item1.alias, item2.alias] completion:^(CXHandle *handle) {
        [expc fulfill];

        assertThat(handle, notNilValue());
        assertThatInteger(handle.type, equalToInteger(CXHandleTypeGeneric));

        NSString *expectedValue = [NSString stringWithFormat:@"%@ %@, %@ %@", item1.firstName, item1.lastName, item2.firstName, item2.lastName];
        assertThat(handle.value, equalTo(expectedValue));
    }];

    [self waitForExpectations:@[expc] timeout:0];
}

- (void)testCreatesUnknownContactHandleWhenEmptyAliasesArrayIsProvided
{
    BCPUsersDetailsCache *cache = [self makePopulatedCache];
    NSFormatter *formatter = [self makeDetailsFormatter:@"${firstname} ${lastname}"];
    BCPContactHandleProvider *sut = [self makeSUTWithCache:cache formatter:formatter];

    XCTestExpectation *expc = [self expectationWithDescription:@"Callback invoked"];

    [sut handleForAliases:@[] completion:^(CXHandle *handle) {
        [expc fulfill];

        assertThat(handle, notNilValue());
        assertThatInteger(handle.type, equalToInteger(CXHandleTypeGeneric));
        assertThat(handle.value, equalTo(@"Unknown"));
    }];

    [self waitForExpectations:@[expc] timeout:0];
}

- (void)testCopyReturnsCopy
{
    BCPUsersDetailsCache *cache = [self makePopulatedCache];
    NSFormatter *formatter = [self makeDetailsFormatter:@"${firstname} ${lastname}"];
    BCPContactHandleProvider *sut = [self makeSUTWithCache:cache formatter:formatter];

    BCPContactHandleProvider *copy = [sut copy];

    assertThat(copy, notNilValue());
    assertThat(copy, isNot(sameInstance(sut)));
}

- (void)testCopyReturnsCopyWithTheSameFormatter
{
    BCPUsersDetailsCache *cache = [self makePopulatedCache];
    NSFormatter *formatter = [self makeDetailsFormatter:@"${firstname} ${lastname}"];
    BCPContactHandleProvider *sut = [self makeSUTWithCache:cache formatter:formatter];

    BCPContactHandleProvider *copy = [sut copy];

    XCTestExpectation *expc1 = [self expectationWithDescription:@"Original instance completion block invoked"];

    [sut handleForAliases:@[item1.alias] completion:^(CXHandle * _Nonnull handle) {
        [expc1 fulfill];

        assertThat(handle.value, equalTo([NSString stringWithFormat:@"%@ %@", item1.firstName, item1.lastName]));
    }];

    XCTestExpectation *expc2 = [self expectationWithDescription:@"Copy instance completion block invoked"];

    [copy handleForAliases:@[item1.alias] completion:^(CXHandle * _Nonnull handle) {
        [expc2 fulfill];

        assertThat(handle.value, equalTo([NSString stringWithFormat:@"%@ %@", item1.firstName, item1.lastName]));
    }];

    [self waitForExpectations:@[expc1, expc2] timeout:0];
}

#pragma mark - Helpers

- (BCPContactHandleProvider *)makeSUTWithCache:(BCPUsersDetailsCache *)cache formatter:(NSFormatter *)formatter
{
    return [[BCPContactHandleProvider alloc] initWithCache:cache formatter:formatter];
}

- (BCPUsersDetailsCache *)makePopulatedCache
{
    BCPUsersDetailsCache* cache = [self makeEmptyCache];

    [cache setItem:item1 forKey:item1.alias];
    [cache setItem:item2 forKey:item2.alias];
    [cache setItem:item3 forKey:item3.alias];

    return cache;
}

- (BCPUsersDetailsCache *)makeEmptyCache
{
    return [BCPUsersDetailsCache new];
}

- (NSFormatter *)makeDetailsFormatter:(NSString *)format
{
    return [[BCPUserDetailsFormatter alloc] initWithFormat:format];
}

__SUPPRESS_WARNINGS_FOR_TEST_END

@end
