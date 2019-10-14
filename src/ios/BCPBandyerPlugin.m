//
// Copyright © 2019 Bandyer S.r.l. All Rights Reserved.
// See LICENSE for licensing information
//

#import "BCPBandyerPlugin.h"
#import "BCPBandyerManager.h"
#import "BCPCallClientEventEmitter.h"
#import "CDVPluginResult+BCPFactoryMethods.h"

@implementation BCPBandyerPlugin

- (void)pluginInitialize 
{
    [super pluginInitialize];

    BCPBandyerManager.shared.viewController = self.viewController;
    BCPBandyerManager.shared.webViewEngine = self.webViewEngine;
}

- (void)initializeBandyer:(CDVInvokedUrlCommand *)command 
{
    CDVPluginResult *pluginResult = nil;
    NSDictionary *params = [command.arguments firstObject];
    BOOL result = [[BCPBandyerManager shared] configureBandyerWithParams:params];
    BCPBandyerManager.shared.notifier = [[BCPCallClientEventEmitter alloc] init:command.callbackId commandDelegate: self.commandDelegate];
}

- (void)start:(CDVInvokedUrlCommand *)command 
{
    [self stop:command];
    CDVPluginResult *pluginResult = nil;
    NSDictionary *params = [command.arguments firstObject];
    BOOL result = [[BCPBandyerManager shared] startCallClientWithParams:params];
    
    if (result)
        pluginResult = [CDVPluginResult bcp_success];
    else
        pluginResult = [CDVPluginResult bcp_error];
        
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)stop:(CDVInvokedUrlCommand *)command 
{
    [[BCPBandyerManager shared] stopCallClient];

    [self.commandDelegate sendPluginResult:[CDVPluginResult bcp_success] callbackId:command.callbackId];
}

- (void)pause:(CDVInvokedUrlCommand *)command 
{
    [[BCPBandyerManager shared] pauseCallClient];

    [self.commandDelegate sendPluginResult:[CDVPluginResult bcp_success] callbackId:command.callbackId];
}

- (void)resume:(CDVInvokedUrlCommand *)command 
{
    [[BCPBandyerManager shared] resumeCallClient];

    [self.commandDelegate sendPluginResult:[CDVPluginResult bcp_success] callbackId:command.callbackId];
}

- (void)state:(CDVInvokedUrlCommand *)command 
{
    NSString *state = [[BCPBandyerManager shared] callClientState];
    
    if (state)
        [self.commandDelegate sendPluginResult:[CDVPluginResult bcp_successWithMessageAsString:state] callbackId:command.callbackId];
    else
        [self.commandDelegate sendPluginResult:[CDVPluginResult bcp_error] callbackId:command.callbackId];
}

- (void)handlePushNotificationPayload:(CDVInvokedUrlCommand *)command 
{
    [self.commandDelegate sendPluginResult:[CDVPluginResult bcp_error] callbackId:command.callbackId];
}

- (void)startCall:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = nil;
    NSDictionary *params = [command.arguments firstObject];
    BOOL result = [[BCPBandyerManager shared] startCallWithParams:params];
    
    if (result)
        pluginResult = [CDVPluginResult bcp_success];
    else
        pluginResult = [CDVPluginResult bcp_error];
        
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)addUsersDetails:(CDVInvokedUrlCommand *)command 
{
    CDVPluginResult *pluginResult = nil;
    NSDictionary *params = [command.arguments firstObject];
    
    if ([params count] == 0) 
    {
        pluginResult = [CDVPluginResult bcp_error];
    } else 
    {
        [[BCPBandyerManager shared] addUsersDetails:params];
        pluginResult = [CDVPluginResult bcp_success];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)removeUsersDetails:(CDVInvokedUrlCommand *)command 
{
    [[BCPBandyerManager shared] removeUsersDetails];

    [self.commandDelegate sendPluginResult:[CDVPluginResult bcp_success] callbackId:command.callbackId];
}

@end
