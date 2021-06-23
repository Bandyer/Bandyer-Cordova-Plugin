//
// Copyright © 2019 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information
//

#import <OCHamcrest/OCHamcrest.h>
#import <OCMockito/OCMockito.h>

#import "BCPTestCase.h"
#import "BCPTestingMacros.h"
#import "BCPExceptionsMatcher.h"

#import "BCPChatClientEventsReporter.h"
#import "BCPEventEmitter.h"
#import "BCPBandyerEvents.h"
#import "BCPConstants.h"

@interface BCPChatClientEventsReporterTest : BCPTestCase

@end

@implementation BCPChatClientEventsReporterTest
{
    id <BDKChatClient> client;
    BCPEventEmitter *emitter;
    BCPChatClientEventsReporter *sut;
}

- (void)setUp
{
    [super setUp];

    client = mockProtocol(@protocol(BDKChatClient));
    emitter = mock(BCPEventEmitter.class);
    sut = [[BCPChatClientEventsReporter alloc] initWithChatClient:client eventEmitter:emitter];
}

__SUPPRESS_WARNINGS_FOR_TEST_BEGIN

- (void)testThrowsInvalidArgumentExceptionWhenMandatoryArgumentIsMissingInInitialization
{
    assertThat(^{[[BCPChatClientEventsReporter alloc] initWithChatClient:nil eventEmitter:emitter];}, throwsInvalidArgumentException());
    assertThat(^{[[BCPChatClientEventsReporter alloc] initWithChatClient:client eventEmitter:nil];}, throwsInvalidArgumentException());
}

- (void)testSubscribesAsChatClientObserverOnStart
{
    [sut start];

    [verify(client) addObserver:sut queue:dispatch_get_main_queue()];
    assertThatBool(sut.isRunning, isTrue());
}

- (void)testSubscribesAsChatClientObserverOnlyOnce
{
    [sut start];

    [sut start];

    [verifyCount(client, times(1)) addObserver:sut queue:dispatch_get_main_queue()];
}

- (void)testUnSubscribesAsChatClientObserverOnStop
{
    [sut start];

    assertThatBool(sut.isRunning, isTrue());

    [sut stop];

    [verify(client) removeObserver:sut];
    assertThatBool(sut.isRunning, isFalse());
}

- (void)testUnSubscribesAsChatClientObserverOnlyOnce
{
    [sut start];
    [sut stop];

    [sut stop];

    [verifyCount(client, times(1)) removeObserver:sut];
}

- (void)testFiresEventOnClientStarted
{
    [sut start];

    [sut chatClientDidStart:client];

    [verify(emitter) sendEvent:[[BCPBandyerEvents chatModuleStatusChanged] value] withArgs:@[kBCPClientReadyJSEvent]];
}

- (void)testFiresEventOnClientPaused
{
    [sut start];

    [sut chatClientDidPause:client];

    [verify(emitter) sendEvent:[[BCPBandyerEvents chatModuleStatusChanged] value] withArgs:@[kBCPClientPausedJSEvent]];
}

- (void)testFiresEventOnClientStopped
{
    [sut start];

    [sut chatClientDidStop:client];

    [verify(emitter) sendEvent:[[BCPBandyerEvents chatModuleStatusChanged] value] withArgs:@[kBCPClientStoppedJSEvent]];
}

- (void)testFiresEventOnClientResumed
{
    [sut start];

    [sut chatClientDidResume:client];

    [verify(emitter) sendEvent:[[BCPBandyerEvents chatModuleStatusChanged] value] withArgs:@[kBCPClientReadyJSEvent]];
}

- (void)testFiresEventsOnClientFailed
{
    [sut start];

    NSError *error = [NSError errorWithDomain:@"dummy" code:1 userInfo:nil];
    [sut chatClient:client didFailWithError:error];

    [verify(emitter) sendEvent:[[BCPBandyerEvents chatError] value] withArgs:@[[error localizedDescription]]];
    [verify(emitter) sendEvent:[[BCPBandyerEvents chatModuleStatusChanged] value] withArgs:@[kBCPClientFailedJSEvent]];
}

__SUPPRESS_WARNINGS_FOR_TEST_END

@end
