//
// Copyright © 2019 Bandyer S.r.l. All Rights Reserved.
// See LICENSE for licensing information
//

#import "BCPBandyerPlugin.h"
#import "BCPBandyerManager.h"
#import "BCPCallClientEventEmitter.h"

@implementation BCPBandyerPlugin

- (void)pluginInitialize 
{
    [super pluginInitialize];

    BCPBandyerManager.shared.viewController = self.viewController;
    BCPBandyerManager.shared.webViewEngine = self.webViewEngine;
    BCPBandyerManager.shared.notifier = [[BCPCallClientEventEmitter alloc] initWithWebViewEngine:self.webViewEngine];
}

- (void)initializeBandyer:(CDVInvokedUrlCommand *)command 
{
    CDVPluginResult *pluginResult = nil;
    NSDictionary *params = [command.arguments firstObject];
    BOOL result = [[BCPBandyerManager shared] configureBandyerWithParams:params];
    
    if (result)
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    else
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)start:(CDVInvokedUrlCommand *)command 
{
    CDVPluginResult *pluginResult = nil;
    NSDictionary *params = [command.arguments firstObject];
    BOOL result = [[BCPBandyerManager shared] startCallClientWithParams:params];
    
    if (result) 
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    else
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)stop:(CDVInvokedUrlCommand *)command 
{
    [[BCPBandyerManager shared] stopCallClient];
    
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

- (void)pause:(CDVInvokedUrlCommand *)command 
{
    [[BCPBandyerManager shared] pauseCallClient];
    
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

- (void)resume:(CDVInvokedUrlCommand *)command 
{
    [[BCPBandyerManager shared] resumeCallClient];
    
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

- (void)state:(CDVInvokedUrlCommand *)command 
{
    NSString *state = [[BCPBandyerManager shared] callClientState];
    
    if (state)
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:state] callbackId:command.callbackId];
    else
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR] callbackId:command.callbackId];
}

- (void)handlePushNotificationPayload:(CDVInvokedUrlCommand *)command 
{
    NSDictionary *params = [command.arguments firstObject];
    BOOL result = [[BCPBandyerManager shared] handleNotificationPayloadWithParams:params];
    
    if (result) 
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId]; 
    else
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR] callbackId:command.callbackId];
}

- (void)startCall:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = nil;
    NSDictionary *params = [command.arguments firstObject];
    BOOL result = [[BCPBandyerManager shared] startCallWithParams:params];
    
    if (result)
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    else
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)addUsersDetails:(CDVInvokedUrlCommand *)command 
{
    CDVPluginResult *pluginResult = nil;
    NSDictionary *params = [command.arguments firstObject];
    
    if ([params count] == 0) 
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];    
    } else 
    {
        [[BCPBandyerManager shared] addUsersDetails:params];    
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)removeUsersDetails:(CDVInvokedUrlCommand *)command 
{
    [[BCPBandyerManager shared] removeUsersDetails];
    
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

@end
