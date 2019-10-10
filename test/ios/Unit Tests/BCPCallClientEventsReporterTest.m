//
// Copyright © 2019 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information
//

#import <XCTest/XCTest.h>
#import <OCHamcrest/OCHamcrest.h>
#import <OCMockito/OCMockito.h>
#import <BandyerSDK/BandyerSDK.h>

#import "BCPTestingMacros.h"
#import "BCPTestCase.h"
#import "BCPExceptionsMatcher.h"

#import "BCPCallClientEventsReporter.h"
#import "BCPEventEmitter.h"
#import "BCPBandyerEvents.h"
#import "BCPConstants.h"

@interface BCPCallClientEventsReporterTest : BCPTestCase

@end

@implementation BCPCallClientEventsReporterTest
{
    BCPEventEmitter *emitter;
    id <BCXCallClient> callClient;
    BCPCallClientEventsReporter *sut;
}

- (void)setUp
{
    [super setUp];

    emitter = mock(BCPEventEmitter.class);
    callClient = mockProtocol(@protocol(BCXCallClient));
    sut = [[BCPCallClientEventsReporter alloc] initWithCallClient:callClient eventEmitter:emitter];
}

__SUPPRESS_WARNINGS_FOR_TEST_BEGIN

- (void)testThrowsInvalidArgumentExceptionWhenMandatoryArgumentIsMissingInInitialization
{
    assertThat(^{[[BCPCallClientEventsReporter alloc] initWithCallClient:callClient eventEmitter:nil];}, throwsInvalidArgumentException());
    assertThat(^{[[BCPCallClientEventsReporter alloc] initWithCallClient:nil eventEmitter:emitter];}, throwsInvalidArgumentException());
}

- (void)testStartsObservingCallClientEvents
{
    [sut start];

    [verify(callClient) addObserver:sut queue:dispatch_get_main_queue()];
    assertThatBool(sut.isRunning, isTrue());
}

- (void)testSubscribesAsCallClientObserverOnlyOnce
{
    [sut start];

    [sut start];

    [verifyCount(callClient, times(1)) addObserver:sut queue:dispatch_get_main_queue()];
}

- (void)testStopsObservingCallClientEvents
{
    [sut start];

    [sut stop];

    assertThatBool(sut.isRunning, isFalse());
    [verify(callClient) removeObserver:sut];
}

- (void)testUnsubscribesAsCallClientObserverOnlyOnce
{
    [sut start];

    [sut stop];
    [sut stop];

    [verifyCount(callClient, times(1)) removeObserver:sut];
}

- (void)testFiresEventOnClientStarted
{
    [sut start];

    [sut callClientDidStart:callClient];

    [verify(emitter) sendEvent:[[BCPBandyerEvents callModuleStatusChanged] value] withArgs:@[kBCPClientReadyJSEvent]];
}

- (void)testFiresEventOnClientStopped
{
    [sut start];

    [sut callClientDidStop:callClient];

    [verify(emitter) sendEvent:[[BCPBandyerEvents callModuleStatusChanged] value] withArgs:@[kBCPClientStoppedJSEvent]];
}

- (void)testFiresEventOnClientPaused
{
    [sut start];

    [sut callClientDidPause:callClient];

    [verify(emitter) sendEvent:[[BCPBandyerEvents callModuleStatusChanged] value] withArgs:@[kBCPClientPausedJSEvent]];
}

- (void)testFiresEventOnClientResumed
{
    [sut start];

    [sut callClientDidResume:callClient];

    [verify(emitter) sendEvent:[[BCPBandyerEvents callModuleStatusChanged] value] withArgs:@[kBCPClientReadyJSEvent]];
}

- (void)testFiresEventOnClientReconnecting
{
    [sut start];

    [sut callClientDidStartReconnecting:callClient];

    [verify(emitter) sendEvent:[[BCPBandyerEvents callModuleStatusChanged] value] withArgs:@[kBCPClientReconnectingJSEvent]];
}

- (void)testFiresEventsOnClientFailed
{
    [sut start];

    NSError *error = [NSError errorWithDomain:@"dummy" code:1 userInfo:nil];
    [sut callClient:callClient didFailWithError:error];

    [verify(emitter) sendEvent:[[BCPBandyerEvents callError] value] withArgs:@[[error localizedDescription]]];
    [verify(emitter) sendEvent:[[BCPBandyerEvents callModuleStatusChanged] value] withArgs:@[kBCPClientFailedJSEvent]];
}

__SUPPRESS_WARNINGS_FOR_TEST_END

@end
