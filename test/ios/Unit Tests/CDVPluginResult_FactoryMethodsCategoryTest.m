//
// Copyright © 2019 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information
//

#import <OCHamcrest/OCHamcrest.h>

#import "BCPTestCase.h"

#import "CDVPluginResult+BCPFactoryMethods.h"

@interface CDVPluginResult_FactoryMethodsCategoryTest : BCPTestCase

@end

@implementation CDVPluginResult_FactoryMethodsCategoryTest

- (void)testCreatesSuccessResult
{
    CDVPluginResult *result = [CDVPluginResult bcp_success];

    assertThat(result, notNilValue());
    assertThat(result.status, equalTo(@(CDVCommandStatus_OK)));
}

- (void)testCreatesSuccessResultWithMessageAsString
{
    CDVPluginResult *result = [CDVPluginResult bcp_successWithMessageAsString:@"foo.bar"];

    assertThat(result, notNilValue());
    assertThat(result.status, equalTo(@(CDVCommandStatus_OK)));
    assertThat(result.message, equalTo(@"foo.bar"));
}

- (void)testCreatesErrorResult
{
    CDVPluginResult *result = [CDVPluginResult bcp_error];

    assertThat(result, notNilValue());
    assertThat(result.status, equalTo(@(CDVCommandStatus_ERROR)));
}

@end
