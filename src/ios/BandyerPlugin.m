//
//  Created by WhiteTiger "sgama la rete" on 21/05/2019.
//

#import <Cordova/CDV.h>
#import "BandyerHeader.h"

@interface BandyerPlugin: CDVPlugin

- (void)initializeBandyer:(CDVInvokedUrlCommand *)command;
- (void)addCallClient:(CDVInvokedUrlCommand *)command;
- (void)removeCallClient:(CDVInvokedUrlCommand *)command;
- (void)start:(CDVInvokedUrlCommand *)command;
- (void)stop:(CDVInvokedUrlCommand *)command;
- (void)pause:(CDVInvokedUrlCommand *)command;
- (void)resume:(CDVInvokedUrlCommand *)command;
- (void)state:(CDVInvokedUrlCommand *)command;
- (void)makeCall:(CDVInvokedUrlCommand *)command;
- (void)handlerPayload:(CDVInvokedUrlCommand *)command;
- (void)createUserInfoFetch:(CDVInvokedUrlCommand *)command;
- (void)clearCache:(CDVInvokedUrlCommand *)command;

@end

@implementation BandyerPlugin

- (void)pluginInitialize {
    [super pluginInitialize];
    
    [[BandyerManager shared] setViewController:self.viewController];
    [[BandyerManager shared] setWebViewEngine:self.webViewEngine];
}

- (void)initializeBandyer:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *pluginResult = nil;
    NSDictionary *params = [command.arguments firstObject];
    bool result = [[BandyerManager shared] configureBandyerWithParams:params];
    
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
    bool result = [[BandyerManager shared] startCallClientWithParams:params];
    
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
    NSString *state = [[BandyerManager shared] stateCallClient];
    
    if (state != nil) {
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:state] callbackId:command.callbackId];
        
    } else {
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR] callbackId:command.callbackId];
    }
}

- (void)handlerPayload:(CDVInvokedUrlCommand *)command {
    NSDictionary *params = [command.arguments firstObject];
    bool result = [[BandyerManager shared] handlerPayloadWithParams:params];
    
    if (result) {
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
        
    } else {
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR] callbackId:command.callbackId];
    }
}

- (void)makeCall:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *pluginResult = nil;
    NSDictionary *params = [command.arguments firstObject];
    bool result = [[BandyerManager shared] makeCallWithParams:params];
    
    if (result) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)createUserInfoFetch:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *pluginResult = nil;
    NSDictionary *params = [command.arguments firstObject];
    
    if ([params count] == 0) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        
    } else {
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
