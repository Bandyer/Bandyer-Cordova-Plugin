//
// Copyright © 2019 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information
//

#import <OCHamcrest/OCHamcrest.h>
#import <OCMockito/OCMockito.h>
#import <PushKit/PushKit.h>

#import "BCPTestCase.h"
#import "BCPTestingMacros.h"
#import "BCPExceptionsMatcher.h"

#import "BCPPushTokenEventsReporter.h"
#import "BCPEventEmitter.h"
#import "BCPBandyerEvents.h"

@interface BCPFakePushCredentials : PKPushCredentials

@property (readwrite, copy) PKPushType type;
@property (readwrite, copy) NSData *token;

@end

@implementation BCPFakePushCredentials
{
    PKPushType _fakeType;
    NSData *_fakeToken;
}

@synthesize type = _fakeType;
@synthesize token = _fakeToken;

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        _fakeType = PKPushTypeVoIP;
        _fakeToken = nil;
    }

    return self;
}

@end

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
    BCPFakePushCredentials *credentials = [BCPFakePushCredentials new];
    NSString *token = @"5b4b68e78c03e2d3b4a7e29e2b7d4429aa497538ac6c8520c6a7c278b5e4047e";
    credentials.token = [self tokenDataFrom:token];

    [sut pushRegistry:nil didUpdatePushCredentials:credentials forType:PKPushTypeVoIP];

    [verify(emitter) sendEvent:[[BCPBandyerEvents iOSVoipPushTokenUpdated] value] withArgs:@[token]];
}

- (void)testFiresPushTokenInvalidatedEvent
{
    [sut pushRegistry:nil didInvalidatePushTokenForType:PKPushTypeVoIP];

    [verify(emitter) sendEvent:[[BCPBandyerEvents iOSVoipPushTokenInvalidated] value] withArgs:@[]];
}

__SUPPRESS_WARNINGS_FOR_TEST_END

// MARK: Helpers

- (NSData *)tokenDataFrom:(NSString *)string
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

@end
