//
// Copyright © 2019 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information
//

#import "BCPEventEmitter.h"
#import "BCPMacros.h"

@interface BCPEventEmitter ()

@property (nonatomic, strong, readonly) NSString *callbackId;
@property (nonatomic, weak, readonly) id <CDVCommandDelegate> commandDelegate;

@end

@implementation BCPEventEmitter

- (instancetype)initWithCallbackId:(NSString *)callbackId commandDelegate:(id <CDVCommandDelegate>)commandDelegate
{
    BCPAssertOrThrowInvalidArgument(callbackId, @"A callback id must be provided, got nil");
    BCPAssertOrThrowInvalidArgument(commandDelegate, @"A command delegate must be provided, got nil");

    self = [super init];

    if (self)
    {
        _callbackId = callbackId;
        _commandDelegate = commandDelegate;
    }

    return self;
}

- (void)sendEvent:(NSString *)event withArgs:(NSArray *)args
{
    NSDictionary *message = @{@"event": event, @"args": args};
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:message];
    [pluginResult setKeepCallbackAsBool:YES];

    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
}
@end
