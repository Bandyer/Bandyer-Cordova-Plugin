//
// Copyright © 2019 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information
//

#import <OCHamcrest/OCHamcrest.h>

#import "BCPTestCase.h"
#import "BCPTestingMacros.h"
#import "BCPExceptionsMatcher.h"

#import "BCPUserInterfaceCoordinator.h"
#import "BCPUsersDetailsCache.h"

@interface BCPUserInterfaceCoordinatorTest : BCPTestCase

@end

@implementation BCPUserInterfaceCoordinatorTest

__SUPPRESS_WARNINGS_FOR_TEST_BEGIN

- (void)testThrowsInvalidArgumentExceptionWhenMandatoryArgumentIsMissingDuringInitialization
{
    assertThat(^{[[BCPUserInterfaceCoordinator alloc] initWithRootViewController:nil usersCache:[BCPUsersDetailsCache new]];}, throwsInvalidArgumentException());
    assertThat(^{[[BCPUserInterfaceCoordinator alloc] initWithRootViewController:[[UIViewController alloc] init] usersCache:nil];}, throwsInvalidArgumentException());
}

__SUPPRESS_WARNINGS_FOR_TEST_END

@end
