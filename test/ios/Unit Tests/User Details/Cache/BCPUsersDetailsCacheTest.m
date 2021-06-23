//
// Copyright © 2019 Bandyer S.r.l. All Rights Reserved.
// See LICENSE for licensing information
//

#import <OCHamcrest/OCHamcrest.h>

#import "BCPTestCase.h"
#import "BCPTestingMacros.h"
#import "BCPExceptionsMatcher.h"
#import "BCPUsersDetailsCache.h"

@interface BCPUsersDetailsCacheTest : BCPTestCase

@end

@implementation BCPUsersDetailsCacheTest
{
    BCPUsersDetailsCache *sut;
}

- (void)setUp
{
    [super setUp];

    sut = [BCPUsersDetailsCache new];
}

__SUPPRESS_WARNINGS_FOR_TEST_BEGIN

- (void)testSetsItem
{
    BDKUserDetails *item = [[BDKUserDetails alloc] initWithAlias:@"alias" firstname:@"First Name" lastname:@"Last Name"];

    [sut setItem:item forKey:item.alias];

    BDKUserDetails *storedItem = [sut itemForKey:item.alias];
    assertThat(storedItem, equalTo(item));
}

- (void)testThrowsInvalidArgumentExceptionWhenSettingAnItemWithANilKey
{
    BDKUserDetails *item = [[BDKUserDetails alloc] initWithAlias:@"alias"];

    assertThat(^{[sut setItem:item forKey:nil];}, throwsInvalidArgumentException());
}

- (void)testReturnsNilWhenGettingAnItemWithNilKey
{
    assertThat([sut itemForKey:nil], nilValue());
}

- (void)testPurgesAllItems
{
    BDKUserDetails *item1 = [[BDKUserDetails alloc] initWithAlias:@"alias1"];
    BDKUserDetails *item2 = [[BDKUserDetails alloc] initWithAlias:@"alias2"];
    BDKUserDetails *item3 = [[BDKUserDetails alloc] initWithAlias:@"alias3"];

    [sut setItem:item1 forKey:item1.alias];
    [sut setItem:item2 forKey:item2.alias];
    [sut setItem:item3 forKey:item3.alias];

    [sut purge];

    assertThat([sut itemForKey:item1.alias], nilValue());
    assertThat([sut itemForKey:item2.alias], nilValue());
    assertThat([sut itemForKey:item3.alias], nilValue());
}

__SUPPRESS_WARNINGS_FOR_TEST_END

@end
