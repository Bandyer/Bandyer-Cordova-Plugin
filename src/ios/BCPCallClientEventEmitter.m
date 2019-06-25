//
// Copyright © 2019 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information
//

#import <BandyerSDK/BandyerSDK.h>

#import "BCPCallClientEventEmitter.h"
#import "BCPConstants.h"

@interface BCPCallClientEventEmitter () <BCXCallClientObserver>

@property (nonatomic, assign, getter=isRunning) BOOL running;

@end

@implementation BCPCallClientEventEmitter


- (instancetype)initWithWebViewEngine:(id <CDVWebViewEngineProtocol>)engine
{
    NSAssert(engine, @"An engine must be provided");

    self = [super init];

    if (self)
    {
        _webViewEngine = engine;
    }

    return self;
}

- (void)start
{
    if (self.isRunning)
        return;

    self.running = YES;
    [[BandyerSDK instance].callClient addObserver:self queue:dispatch_get_main_queue()];
}

- (void)stop
{
    if (!self.isRunning)
        return;

    [[BandyerSDK instance].callClient removeObserver:self];
    self.running = NO;
}

- (void)callClientDidStart:(id <BCXCallClient>)client
{
    [self _sendCallClientEventToJS:kBCPCallClientReadyJSEvent];
}

- (void)callClientDidStartReconnecting:(id <BCXCallClient>)client
{
    [self _sendCallClientEventToJS:kBCPCallClientReconnectingJSEvent];
}

- (void)callClientDidPause:(id <BCXCallClient>)client
{
    [self _sendCallClientEventToJS:kBCPCallClientPausedJSEvent];
}

- (void)callClientDidStop:(id <BCXCallClient>)client
{
    [self _sendCallClientEventToJS:kBCPCallClientStoppedJSEvent];
}

- (void)callClientDidResume:(id <BCXCallClient>)client
{
    [self _sendCallClientEventToJS:kBCPCallClientReadyJSEvent];
}

- (void)callClient:(id <BCXCallClient>)client didFailWithError:(NSError *)error
{
    [self _sendCallClientEventToJS:kBCPCallClientFailedJSEvent];
}

- (void)_sendCallClientEventToJS:(NSString *)eventName
{
    NSString *jsCallClientListenerFormat = @"window.BandyerPlugin.callClientListener('%@')";
    NSString *javascript = [NSString stringWithFormat:jsCallClientListenerFormat, eventName];
    [self.webViewEngine evaluateJavaScript:javascript completionHandler:^(id obj, NSError *error) {}];
}


@end
