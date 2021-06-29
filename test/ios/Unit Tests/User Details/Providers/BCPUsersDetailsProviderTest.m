// Copyright © 2019 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information

#import <OCHamcrest/OCHamcrest.h>
#import <CallKit/CallKit.h>

#import "BCPTestCase.h"
#import "BCPTestingMacros.h"
#import "BCPExceptionsMatcher.h"
#import "BCPUsersDetailsProvider.h"
#import "BCPUsersDetailsCache.h"
#import "BCPUserDetailsFormatter.h"

@interface BCPUsersDetailsProviderTest : BCPTestCase

@end

@implementation BCPUsersDetailsProviderTest
{
    BDKUserDetails *item1;
    BDKUserDetails *item2;
    BDKUserDetails *item3;
}

- (void)setUp
{
    [super setUp];

    item1 = [[BDKUserDetails alloc] initWithAlias:@"item1" firstname:@"John" lastname:@"Appleseed"];
    item2 = [[BDKUserDetails alloc] initWithAlias:@"item2" firstname:@"Jane" lastname:@"Appleseed"];
    item3 = [[BDKUserDetails alloc] initWithAlias:@"item3"];
}

__SUPPRESS_WARNINGS_FOR_TEST_BEGIN

- (void)testThrowsInvalidArgumentExceptionWhenMandatoryArgumentIsNotProvidedInDesignatedInitializer
{
    assertThat(^{[[BCPUsersDetailsProvider alloc] initWithCache:nil formatter:[NSFormatter new]];}, throwsInvalidArgumentException());
    assertThat(^{[[BCPUsersDetailsProvider alloc] initWithCache:[self makeEmptyCache] formatter:nil];}, throwsInvalidArgumentException());
}

- (void)testFetchesUsersDetailsFromCache
{
    BCPUsersDetailsCache *cache = [self makePopulatedCache];
    BCPUsersDetailsProvider *sut = [self makeSUTWithCache:cache formatter:[NSFormatter new]];

    XCTestExpectation *expc = [self expectationWithDescription:@"Callback invocation expectation"];

    [sut provideDetails:@[item1.alias, item2.alias] completion:^(NSArray<BDKUserDetails *> * _Nonnull details) {
        [expc fulfill];

        assertThat(details, containsIn(@[item1, item2]));
    }];

    [self waitForExpectations:@[expc] timeout:0];
}

- (void)testCreatesItemWhenOneCouldNotBeFoundInTheCache
{
    BCPUsersDetailsCache *cache = [self makePopulatedCache];
    BCPUsersDetailsProvider *sut = [self makeSUTWithCache:cache formatter:[NSFormatter new]];

    XCTestExpectation *expc = [self expectationWithDescription:@"Callback invocation expectation"];

    [sut provideDetails:@[item1.alias, @"foo.bar"] completion:^(NSArray<BDKUserDetails *> * _Nonnull details) {
        [expc fulfill];

        assertThat(details, hasCountOf(2));

        BDKUserDetails *missingItem = [[BDKUserDetails alloc] initWithAlias:@"foo.bar"];
        assertThat(details, containsIn(@[item1, missingItem]));
    }];

    [self waitForExpectations:@[expc] timeout:0];
}

- (void)testCreatesGenericHandleWithValueFormattedByTheFormatterProvidedInInitialization
{
    BCPUsersDetailsCache *cache = [self makePopulatedCache];
    NSFormatter *formatter = [self makeDetailsFormatter:@"${firstname} ${lastname}"];
    BCPUsersDetailsProvider *sut = [self makeSUTWithCache:cache formatter:formatter];

    XCTestExpectation *expc = [self expectationWithDescription:@"Callback invoked"];

    [sut provideHandle:@[item1.alias] completion:^(CXHandle * _Nonnull handle) {
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
    BCPUsersDetailsProvider *sut = [self makeSUTWithCache:cache formatter:formatter];

    XCTestExpectation *expc = [self expectationWithDescription:@"Callback invoked"];

    [sut provideHandle:@[@"missing"] completion:^(CXHandle * _Nonnull handle) {
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
    BCPUsersDetailsProvider *sut = [self makeSUTWithCache:cache formatter:formatter];

    XCTestExpectation *expc = [self expectationWithDescription:@"Callback invoked"];

    [sut provideHandle:@[item3.alias] completion:^(CXHandle * _Nonnull handle) {
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
    BCPUsersDetailsProvider *sut = [self makeSUTWithCache:cache formatter:formatter];

    XCTestExpectation *expc = [self expectationWithDescription:@"Callback invoked"];

    [sut provideHandle:@[item1.alias, item2.alias] completion:^(CXHandle * _Nonnull handle) {
        [expc fulfill];

        assertThat(handle, notNilValue());
        assertThatInteger(handle.type, equalToInteger(CXHandleTypeGeneric));

        NSString *expectedValue = [NSString stringWithFormat:@"%@ %@, %@ %@", item1.firstname, item1.lastname, item2.firstname, item2.lastname];
        assertThat(handle.value, equalTo(expectedValue));
    }];

    [self waitForExpectations:@[expc] timeout:0];
}

- (void)testCreatesUnknownContactHandleWhenEmptyAliasesArrayIsProvided
{
    BCPUsersDetailsCache *cache = [self makePopulatedCache];
    NSFormatter *formatter = [self makeDetailsFormatter:@"${firstname} ${lastname}"];
    BCPUsersDetailsProvider *sut = [self makeSUTWithCache:cache formatter:formatter];

    XCTestExpectation *expc = [self expectationWithDescription:@"Callback invoked"];

    [sut provideHandle:@[] completion:^(CXHandle * _Nonnull handle) {
        [expc fulfill];

        assertThat(handle, notNilValue());
        assertThatInteger(handle.type, equalToInteger(CXHandleTypeGeneric));
        assertThat(handle.value, equalTo(@"Unknown"));
    }];

    [self waitForExpectations:@[expc] timeout:0];
}

#pragma mark - Helpers

- (BCPUsersDetailsProvider *)makeSUTWithCache:(BCPUsersDetailsCache *)cache formatter:(NSFormatter *)formatter
{
    return [[BCPUsersDetailsProvider alloc] initWithCache:cache formatter:formatter];
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
