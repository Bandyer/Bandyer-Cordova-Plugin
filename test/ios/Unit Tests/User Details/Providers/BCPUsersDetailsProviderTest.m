//
// Copyright © 2019 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information
//

#import <OCHamcrest/OCHamcrest.h>

#import "BCPTestCase.h"
#import "BCPTestingMacros.h"
#import "BCPExceptionsMatcher.h"

#import "BCPUsersDetailsProvider.h"
#import "BCPUsersDetailsCache.h"

@interface BCPUsersDetailsProviderTest : BCPTestCase

@end

@implementation BCPUsersDetailsProviderTest
{
    BCPUsersDetailsCache *cache;
    BCPUsersDetailsProvider *sut;
    BDKUserDetails *item1;
    BDKUserDetails *item2;
}

- (void)setUp
{
    [super setUp];

    item1 = [[BDKUserDetails alloc] initWithAlias:@"alias1"];
    item2 = [[BDKUserDetails alloc] initWithAlias:@"alias2"];

    cache = [BCPUsersDetailsCache new];
    sut = [[BCPUsersDetailsProvider alloc] initWithCache:cache];
}

__SUPPRESS_WARNINGS_FOR_TEST_BEGIN

- (void)testThrowsInvalidArgumentExceptionWhenNilCacheIsProvidedInInitialization
{
    assertThat(^{[[BCPUsersDetailsProvider alloc] initWithCache:nil];}, throwsInvalidArgumentException());
}

- (void)testFetchesUsersDetailsFromCache
{
    [cache setItem:item1 forKey:item1.alias];
    [cache setItem:item2 forKey:item2.alias];

    XCTestExpectation *expc = [self expectationWithDescription:@"Callback invocation expectation"];

    [sut provideDetails:@[item1.alias, item2.alias] completion:^(NSArray<BDKUserDetails *> * _Nonnull details) {
        [expc fulfill];

        assertThat(details, containsIn(@[item1, item2]));
    }];

    [self waitForExpectations:@[expc] timeout:0];
}

- (void)testCreatesItemWhenOneCouldNotBeFoundInTheCache
{
    [cache setItem:item1 forKey:item1.alias];

    XCTestExpectation *expc = [self expectationWithDescription:@"Callback invocation expectation"];

    [sut provideDetails:@[item1.alias, @"foo.bar"] completion:^(NSArray<BDKUserDetails *> * _Nonnull details) {
        [expc fulfill];

        assertThat(details, hasCountOf(2));

        BDKUserDetails *missingItem = [[BDKUserDetails alloc] initWithAlias:@"foo.bar"];
        assertThat(details, containsIn(@[item1, missingItem]));
    }];

    [self waitForExpectations:@[expc] timeout:0];
}

__SUPPRESS_WARNINGS_FOR_TEST_END

@end
