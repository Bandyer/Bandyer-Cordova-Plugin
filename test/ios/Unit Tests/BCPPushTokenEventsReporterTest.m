//
// Copyright © 2019 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information
//

#import <OCHamcrest/OCHamcrest.h>
#import <OCMockito/OCMockito.h>

#import "BCPTestCase.h"
#import "BCPTestingMacros.h"
#import "BCPExceptionsMatcher.h"

#import "BCPPushTokenEventsReporter.h"
#import "BCPEventEmitter.h"
#import "BCPBandyerEvents.h"

@interface BCPPushTokenEventsReporterTest : BCPTestCase

@end

@implementation BCPPushTokenEventsReporterTest
{
    BCPEventEmitter *emitter;
    BCPPushTokenEventsReporter *sut;
}

- (void)setUp
{
    [super setUp];

    emitter = mock(BCPEventEmitter.class);
    sut = [[BCPPushTokenEventsReporter alloc] initWithEventEmitter:emitter];
}

__SUPPRESS_WARNINGS_FOR_TEST_BEGIN

- (void)testThrowsInvalidArgumentExceptionWhenMandatoryArgumentIsMissing
{
    assertThat(^{[[BCPPushTokenEventsReporter alloc] initWithEventEmitter:nil];}, throwsInvalidArgumentException());
}

- (void)testFiresPushTokenUpdatedEvent
{
    PKPushCredentials *credentials = mock(PKPushCredentials.class);
    NSString *tokenAsString = @"5b4b68e78c03e2d3b4a7e29e2b7d4429aa497538ac6c8520c6a7c278b5e4047e";
    NSData *tokenAsData = [self tokenData:tokenAsString];

    [given([credentials token]) willReturn:tokenAsData];
    [sut pushRegistry:nil didUpdatePushCredentials:credentials forType:PKPushTypeVoIP];

    [verify(emitter) sendEvent:[[BCPBandyerEvents iOSVoipPushTokenUpdated] value] withArgs:@[tokenAsString]];
}

- (void)testFiresPushTokenInvalidatedEvent
{
    [sut pushRegistry:nil didInvalidatePushTokenForType:PKPushTypeVoIP];

    [verify(emitter) sendEvent:[[BCPBandyerEvents iOSVoipPushTokenInvalidated] value] withArgs:@[]];
}

- (NSData *)tokenData:(NSString *)string
{
    NSMutableData *stringData = [[NSMutableData alloc] init];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0', '\0', '\0'};
    for (int i = 0; i < [string length] / 2; i++)
    {
        byte_chars[0] = [string characterAtIndex:i * 2];
        byte_chars[1] = [string characterAtIndex:i * 2 + 1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [stringData appendBytes:&whole_byte length:1];
    }
    return stringData;
}

__SUPPRESS_WARNINGS_FOR_TEST_END

@end
