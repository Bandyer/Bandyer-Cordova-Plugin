//
// Copyright © 2019 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information
//

#import "BCPChatClientEventsReporter.h"
#import "BCPEventEmitter.h"
#import "BCPMacros.h"
#import "BCPBandyerEvents.h"
#import "BCPConstants.h"

@interface BCPChatClientEventsReporter ()

@property (nonatomic, strong, readonly) id <BCHChatClient> client;
@property (nonatomic, strong, readonly) BCPEventEmitter *emitter;
@property (nonatomic, assign, readwrite, getter=isRunning) BOOL running;

@end

@implementation BCPChatClientEventsReporter

- (instancetype)initWithChatClient:(id <BCHChatClient>)chatClient eventEmitter:(BCPEventEmitter *)eventEmitter
{
    BCPAssertOrThrowInvalidArgument(chatClient, @"A chat client must be provided, got nil");
    BCPAssertOrThrowInvalidArgument(eventEmitter, @"An event emitter must be provided, got nil");

    self = [super init];

    if (self)
    {
        _client = chatClient;
        _emitter = eventEmitter;
    }

    return self;
}

- (void)start
{
    if (self.isRunning)
        return;

    [self.client addObserver:self queue:dispatch_get_main_queue()];
    self.running = YES;
}

- (void)stop
{
    if (!self.isRunning)
        return;

    [self.client removeObserver:self];
    self.running = NO;
}

- (void)chatClientDidStart:(id <BCHChatClient>)client
{
    [self.emitter sendEvent:[[BCPBandyerEvents chatModuleStatusChanged] value] withArgs:@[kBCPClientReadyJSEvent]];
}

- (void)chatClientDidPause:(id <BCHChatClient>)client
{
    [self.emitter sendEvent:[[BCPBandyerEvents chatModuleStatusChanged] value] withArgs:@[kBCPClientPausedJSEvent]];
}

- (void)chatClientDidStop:(id <BCHChatClient>)client
{
    [self.emitter sendEvent:[[BCPBandyerEvents chatModuleStatusChanged] value] withArgs:@[kBCPClientStoppedJSEvent]];
}

- (void)chatClientDidResume:(id <BCHChatClient>)client
{
    [self.emitter sendEvent:[[BCPBandyerEvents chatModuleStatusChanged] value] withArgs:@[kBCPClientReadyJSEvent]];
}

- (void)chatClient:(id <BCHChatClient>)client didFailWithError:(NSError *)error
{
    [self.emitter sendEvent:[[BCPBandyerEvents chatError] value] withArgs:@[[error localizedDescription] ?: [NSNull null]]];
    [self.emitter sendEvent:[[BCPBandyerEvents chatModuleStatusChanged] value] withArgs:@[kBCPClientFailedJSEvent]];
}


@end
