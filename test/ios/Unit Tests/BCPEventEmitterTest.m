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

    HCArgumentCaptor *captor = [HCArgumentCaptor new];
    [verify(commandDelegate) sendPluginResult:(id) captor callbackId:@"CallbackId"];

    CDVPluginResult *result = captor.value;
    assertThat(result, notNilValue());
    assertThat(result.status, equalTo(@(CDVCommandStatus_OK)));
    assertThat(result.message, equalTo(@{@"event": @"foo", @"args": @[@"bar", @"quux"]}));
    assertThat(result.keepCallback, equalTo(@(YES)));
}

__SUPPRESS_WARNINGS_FOR_TEST_END

@end
