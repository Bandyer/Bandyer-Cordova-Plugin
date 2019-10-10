//
// Copyright © 2019 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information
//

#import <BandyerSDK/BandyerSDK.h>

#import "BCPCallClientEventsReporter.h"
#import "BCPEventEmitter.h"
#import "BCPMacros.h"
#import "BCPConstants.h"
#import "BCPBandyerEvents.h"

@interface BCPCallClientEventsReporter ()

@property (nonatomic, strong, readonly) id <BCXCallClient> callClient;
@property (nonatomic, strong, readonly) BCPEventEmitter *eventEmitter;
@property (nonatomic, assign, readwrite, getter=isRunning) BOOL running;

@end

@implementation BCPCallClientEventsReporter

- (instancetype)initWithCallClient:(id <BCXCallClient>)callClient eventEmitter:(BCPEventEmitter *)emitter
{
    BCPAssertOrThrowInvalidArgument(callClient, @"A call client must be provided, got nil");
    BCPAssertOrThrowInvalidArgument(emitter, @"An event emitter must be provided, got nil");

    self = [super init];

    if (self)
    {
        _callClient = callClient;
        _eventEmitter = emitter;
    }

    return self;
}

- (void)start
{
    if (self.isRunning)
        return;

    [self.callClient addObserver:self queue:dispatch_get_main_queue()];
    self.running = YES;
}

- (void)stop
{
    if (!self.isRunning)
        return;

    [self.callClient removeObserver:self];
    self.running = NO;
}

- (void)callClientDidStart:(id <BCXCallClient>)client
{
    [self.eventEmitter sendEvent:[[BCPBandyerEvents callModuleStatusChanged] value] withArgs:@[kBCPClientReadyJSEvent]];
}

- (void)callClientDidStartReconnecting:(id <BCXCallClient>)client
{
    [self.eventEmitter sendEvent:[[BCPBandyerEvents callModuleStatusChanged] value] withArgs:@[kBCPClientReconnectingJSEvent]];
}

- (void)callClientDidPause:(id <BCXCallClient>)client
{
    [self.eventEmitter sendEvent:[[BCPBandyerEvents callModuleStatusChanged] value] withArgs:@[kBCPClientPausedJSEvent]];
}

- (void)callClientDidStop:(id <BCXCallClient>)client
{
    [self.eventEmitter sendEvent:[[BCPBandyerEvents callModuleStatusChanged] value] withArgs:@[kBCPClientStoppedJSEvent]];
}

- (void)callClientDidResume:(id <BCXCallClient>)client
{
    [self.eventEmitter sendEvent:[[BCPBandyerEvents callModuleStatusChanged] value] withArgs:@[kBCPClientReadyJSEvent]];
}

- (void)callClient:(id <BCXCallClient>)client didFailWithError:(NSError *)error
{
    [self.eventEmitter sendEvent:[[BCPBandyerEvents callError] value] withArgs:@[[error localizedDescription] ?: [NSNull null]]];
    [self.eventEmitter sendEvent:[[BCPBandyerEvents callModuleStatusChanged] value] withArgs:@[kBCPClientFailedJSEvent]];
}

@end
