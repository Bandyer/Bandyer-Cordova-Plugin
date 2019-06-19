//
// Copyright © 2019 Bandyer S.r.l. All Rights Reserved.
// See LICENSE for licensing information
//

#import "BCPBandyerPlugin.h"
#import "BCPBandyerManager.h"

@implementation BCPBandyerPlugin

- (void)pluginInitialize {
    [super pluginInitialize];
    
    [[BCPBandyerManager shared] setViewController:self.viewController];
    [[BCPBandyerManager shared] setWebViewEngine:self.webViewEngine];
}

- (void)initializeBandyer:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *pluginResult = nil;
    NSDictionary *params = [command.arguments firstObject];
    BOOL result = [[BCPBandyerManager shared] configureBandyerWithParams:params];
    
    if (result) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)addCallClient:(CDVInvokedUrlCommand *)command {
    [[BCPBandyerManager shared] addCallClient];

    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

- (void)removeCallClient:(CDVInvokedUrlCommand *)command {
    [[BCPBandyerManager shared] removeCallClient];
    
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

- (void)start:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *pluginResult = nil;
    NSDictionary *params = [command.arguments firstObject];
    BOOL result = [[BCPBandyerManager shared] startCallClientWithParams:params];
    
    if (result) 
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    else
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)stop:(CDVInvokedUrlCommand *)command {
    [[BCPBandyerManager shared] stopCallClient];
    
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

- (void)pause:(CDVInvokedUrlCommand *)command {
    [[BCPBandyerManager shared] pauseCallClient];
    
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

- (void)resume:(CDVInvokedUrlCommand *)command {
    [[BCPBandyerManager shared] resumeCallClient];
    
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

- (void)state:(CDVInvokedUrlCommand *)command {
    NSString *state = [[BCPBandyerManager shared] callClientState];
    
    if (state)
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:state] callbackId:command.callbackId];
    else
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR] callbackId:command.callbackId];
}

- (void)handlePushNotificationPayload:(CDVInvokedUrlCommand *)command {
    NSDictionary *params = [command.arguments firstObject];
    BOOL result = [[BCPBandyerManager shared] handleNotificationPayloadWithParams:params];
    
    if (result) 
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId]; 
    else
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR] callbackId:command.callbackId];
}

- (void)makeCall:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *pluginResult = nil;
    NSDictionary *params = [command.arguments firstObject];
    BOOL result = [[BCPBandyerManager shared] makeCallWithParams:params];
    
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
        [[BCPBandyerManager shared] createUserInfoFetchWithParams:params];    
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)clearCache:(CDVInvokedUrlCommand *)command {
    [[BCPBandyerManager shared] clearCache];
    
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

@end
