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

API_AVAILABLE(ios(10.0)) @interface BCPContactHandleProviderTest : BCPiOS10AndAboveTestCase

@end

@implementation BCPContactHandleProviderTest
{
    BCPUsersDetailsCache *cache;
    BDKUserInfoDisplayItem *item1;
    BDKUserInfoDisplayItem *item2;
    BDKUserInfoDisplayItem *item3;
    BCPContactHandleProvider *sut;
}

- (void)setUp
{
    [super setUp];

    cache = [BCPUsersDetailsCache new];

    [self createItems];

    sut = [[BCPContactHandleProvider alloc] initWithCache:cache];
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

- (void)testThrowsInvalidArgumentExceptionWhenNilCacheIsProvidedInInitialization
{
    assertThat(^{[[BCPContactHandleProvider alloc] initWithCache:nil];}, throwsInvalidArgumentException());
}

- (void)testThrowsInvalidArgumentExcpetionWhenNilFormatIsProvided
{
    assertThat(^{ sut.format = nil; }, throwsInvalidArgumentException());
}

- (void)testCreatesContactHandleWithAliasesAsHandleValueUsingDefaultFormatterWhenNoFormatIsProvided
{
    [self populateCache];

    XCTestExpectation *expc = [self expectationWithDescription:@"Callback invoked"];

    [sut handleForAliases:@[item1.alias] completion:^(CXHandle *handle) {
        [expc fulfill];

        assertThat(handle, notNilValue());
        assertThatInteger(handle.type, equalToInteger(CXHandleTypeGeneric));
        assertThat(handle.value, equalTo(item1.alias));
    }];

    [self waitForExpectations:@[expc] timeout:0];
}

- (void)testCreatesGenericContactHandleWithContactFullnameAsHandleValueWhenFormatIsProvided
{
    [self populateCache];
    sut.format = @"${firstname} ${lastname}";

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
    [self populateCache];
    sut.format = @"${firstname} ${lastname}";

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
    [self populateCache];
    sut.format = @"${firstname} ${lastname}";

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
    [self populateCache];
    sut.format = @"${firstname} ${lastname}";

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
    [self populateCache];

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
    BCPContactHandleProvider *copy = [sut copy];

    assertThat(copy, notNilValue());
    assertThat(copy, isNot(sameInstance(sut)));
}

- (void)testCopyReturnsCopyWithTheSameFormatter
{
    [self populateCache];
    sut.format = @"${firstname} ${lastname}";

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

- (void)populateCache
{
    [cache setItem:item1 forKey:item1.alias];
    [cache setItem:item2 forKey:item2.alias];
    [cache setItem:item3 forKey:item3.alias];
}

__SUPPRESS_WARNINGS_FOR_TEST_END

@end
