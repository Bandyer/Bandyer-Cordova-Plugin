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


- (instancetype)init:(NSString *)callbackId
     commandDelegate:(id <CDVCommandDelegate>) commandDelegate
{
    self = [super init];

    if (self)
    {
        _commandDelegate = commandDelegate;
        _callbackId = callbackId;
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
    [self _sendEvent:@"callModuleStatusChanged" args:@[kBCPCallClientReadyJSEvent]];
}

- (void)callClientDidStartReconnecting:(id <BCXCallClient>)client
{
    [self _sendEvent:@"callModuleStatusChanged" args:@[kBCPCallClientReconnectingJSEvent]];
}

- (void)callClientDidPause:(id <BCXCallClient>)client
{
    [self _sendEvent:@"callModuleStatusChanged" args:@[kBCPCallClientPausedJSEvent]];
}

- (void)callClientDidStop:(id <BCXCallClient>)client
{
    [self _sendEvent:@"callModuleStatusChanged" args:@[kBCPCallClientStoppedJSEvent]];
}

- (void)callClientDidResume:(id <BCXCallClient>)client
{
    [self _sendEvent:@"callModuleStatusChanged" args:@[kBCPCallClientReadyJSEvent]];
}

- (void)callClient:(id <BCXCallClient>)client didFailWithError:(NSError *)error
{
    [self _sendEvent:@"callModuleStatusChanged" args:@[kBCPCallClientFailedJSEvent]];
}

- (void)_sendEvent:(NSString *)eventName
              args:(NSArray *) args {
    
    NSDictionary *message = @{ @"event":eventName, @"args":  args};
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary: message];
    [pluginResult setKeepCallbackAsBool:YES];
    [_commandDelegate sendPluginResult:pluginResult callbackId:_callbackId];
}

@end
