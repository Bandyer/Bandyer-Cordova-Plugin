//
// Copyright © 2019 Bandyer S.r.l. All Rights Reserved.
// See LICENSE for licensing information
//

#import "BCPBandyerPlugin.h"

@implementation BCPBandyerPlugin

- (void)pluginInitialize {
    [super pluginInitialize];
    
    [[BandyerManager shared] setViewController:self.viewController];
    [[BandyerManager shared] setWebViewEngine:self.webViewEngine];
}

- (void)initializeBandyer:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *pluginResult = nil;
    NSDictionary *params = [command.arguments firstObject];
    BOOL result = [[BandyerManager shared] configureBandyerWithParams:params];
    
    if (result) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)addCallClient:(CDVInvokedUrlCommand *)command {
    [[BandyerManager shared] addCallClient];

    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

- (void)removeCallClient:(CDVInvokedUrlCommand *)command {
    [[BandyerManager shared] removeCallClient];
    
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

- (void)start:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *pluginResult = nil;
    NSDictionary *params = [command.arguments firstObject];
    BOOL result = [[BandyerManager shared] startCallClientWithParams:params];
    
    if (result) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)stop:(CDVInvokedUrlCommand *)command {
    [[BandyerManager shared] stopCallClient];
    
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

- (void)pause:(CDVInvokedUrlCommand *)command {
    [[BandyerManager shared] pauseCallClient];
    
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

- (void)resume:(CDVInvokedUrlCommand *)command {
    [[BandyerManager shared] resumeCallClient];
    
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

- (void)state:(CDVInvokedUrlCommand *)command {
    NSString *state = [[BandyerManager shared] callClientState];
    
    if (state)
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:state] callbackId:command.callbackId];
    else
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR] callbackId:command.callbackId];
}

- (void)handlePushNotificationPayload:(CDVInvokedUrlCommand *)command {
    NSDictionary *params = [command.arguments firstObject];
    BOOL result = [[BandyerManager shared] handleNotificationPayloadWithParams:params];
    
    if (result) 
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId]; 
    else
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR] callbackId:command.callbackId];
}

- (void)makeCall:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *pluginResult = nil;
    NSDictionary *params = [command.arguments firstObject];
    BOOL result = [[BandyerManager shared] makeCallWithParams:params];
    
    if (result)
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    else
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)createUserInfoFetch:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *pluginResult = nil;
    NSDictionary *params = [command.arguments firstObject];
    
    if ([params count] == 0) 
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];    
    } else 
    {
        [[BandyerManager shared] createUserInfoFetchWithParams:params];    
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)clearCache:(CDVInvokedUrlCommand *)command {
    [[BandyerManager shared] clearCache];
    
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

@end
