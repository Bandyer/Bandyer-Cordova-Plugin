//
// Copyright © 2019 Bandyer S.r.l. All Rights Reserved.
// See LICENSE for licensing information
//

#import <XCTest/XCTest.h>
#import <OCHamcrest/OCHamcrest.h>
#import <OCMockito/OCMockito.h>
#import <Cordova/CDV.h>

#import "BCPTestCase.h"
#import "BCPTestingMacros.h"
#import "BCPExceptionsMatcher.h"
#import "BCPPluginResultMatcher.h"

#import "BCPEventEmitter.h"

@interface BCPEventEmitterTest : BCPTestCase

@end

@implementation BCPEventEmitterTest
{
    id <CDVCommandDelegate> commandDelegate;
}

- (void)setUp
{
    [super setUp];

    commandDelegate = mockProtocol(@protocol(CDVCommandDelegate));
}

__SUPPRESS_WARNINGS_FOR_TEST_BEGIN

- (void)testThrowsInvalidArgumentWhenMandatoryArgumentIsMissing
{
    assertThat(^{[[BCPEventEmitter alloc] initWithCallbackId:nil commandDelegate:commandDelegate];}, throwsInvalidArgumentException());
    assertThat(^{[[BCPEventEmitter alloc] initWithCallbackId:@"ID" commandDelegate:nil];}, throwsInvalidArgumentException());
}

- (void)testSendsPluginResultContainingEventAndArgsToCommandDelegate
{
    BCPEventEmitter *sut = [[BCPEventEmitter alloc] initWithCallbackId:@"CallbackId" commandDelegate:commandDelegate];

    [sut sendEvent:@"foo" withArgs:@[@"bar", @"quux"]];

    CDVPluginResult *expectedResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{@"event": @"foo", @"args": @[@"bar", @"quux"]}];
    expectedResult.keepCallback = @YES;

    [verify(commandDelegate) sendPluginResult:equalToResult(expectedResult) callbackId:@"CallbackId"];
}

__SUPPRESS_WARNINGS_FOR_TEST_END

@end
