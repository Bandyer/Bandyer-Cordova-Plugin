//
//  Created by WhiteTiger "sgama la rete" on 21/05/2019.
//

#import "BandyerManager.h"

@interface BandyerManager() <BCXCallClientObserver, BDKCallViewControllerDelegate>

@property (nonatomic, strong) BandyerSDK *bandyer;

@end

@implementation BandyerManager

+ (instancetype _Nullable)shared {
    static BandyerManager *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    
    return shared;
}

- (instancetype _Nullable)init {
    if (self = [super init]) {
        self.bandyer = [BandyerSDK instance];
    }
    
    return self;
}

- (id<BCXCallClient>)callClient {
    @try {
        return [self.bandyer callClient];
        
    } @catch (NSException *exception) {
        return nil;
    }
}

- (bool)configureBandyerWithParams:(NSDictionary * _Nonnull)params {
    BDKConfig *config = [BDKConfig new];
    BDKEnvironment *environment = [[params valueForKey:kBandyerEnvironment] convertIntoBandyerEnvironment];
    
    if (environment == nil) {
        return NO;
    }
    
    [config setEnvironment:environment];
    [config setCallKitEnabled:[params valueForKey:kBandyerEnvironment]];
    
    NSString *appID = [params valueForKey:kBandyerApplicationID];
    
    if (appID == nil || [appID length] == 0) {
        return NO;
    }
    
    if ([[params valueForKey:kBandyerLogEnable] boolValue] == YES) {
        [BCXConfig setLogLevel:BDFDDLogLevelAll];
        [BDKConfig setLogLevel:BDFDDLogLevelAll];
    }
    
    [self.bandyer initializeWithApplicationId:appID config:config];
    
    return YES;
}

- (void)addCallClient {
    [[self callClient] addObserver:self queue:dispatch_get_main_queue()];
}

- (void)removeCallClient {
    [[self callClient] removeObserver:self];
}

- (bool)startCallClientWithParams:(NSDictionary * _Nonnull)params {
    NSString *user = [params valueForKey:kBandyerUsername];
    
    if (user != nil && [user length] > 0) {
        [[self callClient] start:user];
        
        return YES;
    }
    
    return NO;
}

- (void)pauseCallClient {
    [[self callClient] pause];
}

- (void)resumeCallClient {
    [[self callClient] resume];
}

- (void)stopCallClient {
    [[self callClient] stop];
}

- (NSString * _Nullable)stateCallClient {
    @try {
        BCXCallClientState state = [[self.bandyer callClient] state];
        
        switch (state) {
            case BCXCallClientStatePaused: return @"paused";
            case BCXCallClientStateRunning: return @"running";
            case BCXCallClientStateStopped: return @"stopped";
            case BCXCallClientStateResuming: return @"resuming";
            case BCXCallClientStateStarting: return @"starting";
            case BCXCallClientStateReconnecting: return @"reconnecting";
        }
        
    } @catch (NSException *exception) {
        return nil;
    }
}

- (bool)handlerPayloadWithParams:(NSDictionary * _Nonnull)params {
    NSDictionary *payloadDict = [params valueForKey:kBandyerPayload];
    NSDictionary *payload;
    
    if (payloadDict == nil && self.payload == nil) {
        return NO;
    }
    
    if ([payloadDict count] > 0) {
        payload = payloadDict;
        
    } else {
        payload = [[self.payload dictionaryPayload] valueForKey:kBandyerKeyPathToDataDictionary];
    }
    
    [[self callClient] handleNotification:payload];
    
    return YES;
}

- (bool)makeCallWithParams:(NSDictionary * _Nonnull)params {
    NSArray *calle = [params valueForKey:kBandyerCallee];
    
    if ([calle count] == 0) {
        return NO;
    }
    
    BDKCallViewControllerConfiguration *config = [BDKCallViewControllerConfiguration new];
    BDKCallViewController *controller = [BDKCallViewController new];
    
    [controller setDelegate:self];
    [controller setConfiguration:config];
    
    BDKMakeCallIntent *intent = [BDKMakeCallIntent intentWithCallee:calle type:BDKCallTypeAudioVideo record:NO maximumDuration:0];
    
    [controller handleIntent:intent];
    
    [self.viewController presentViewController:controller animated:YES completion:NULL];
    
    return YES;
}

#pragma mark - BCXCallClientObserver

- (void)callClient:(id <BCXCallClient>)client didReceiveIncomingCall:(id <BCXCall>)call {
    NSLog(@"%s", __FUNCTION__);
    
    [self.webViewEngine evaluateJavaScript:@"window.cordova.plugins.BandyerPlugin.callClientListener('ios_didReceiveIncomingCall')" completionHandler:^(id obj, NSError *error) {
        // NOP
    }];
    
    BDKCallViewControllerConfiguration *config = [BDKCallViewControllerConfiguration new];
    BDKCallViewController *controller = [BDKCallViewController new];
    
    [controller setDelegate:self];
    [controller setConfiguration:config];
    
    BDKIncomingCallHandlingIntent *intent = [BDKIncomingCallHandlingIntent new];
    
    [controller handleIntent:intent];
    
    [self.viewController presentViewController:controller animated:YES completion:NULL];
}

- (void)callClientWillStart:(id <BCXCallClient>)client {
    NSLog(@"%s", __FUNCTION__);
    
    [self.webViewEngine evaluateJavaScript:@"window.cordova.plugins.BandyerPlugin.callClientListener('ios_callClientWillStart')" completionHandler:^(id obj, NSError *error) {
        // NOP
    }];
}

- (void)callClientDidStart:(id <BCXCallClient>)client {
    NSLog(@"%s", __FUNCTION__);
    
    [self.webViewEngine evaluateJavaScript:@"window.cordova.plugins.BandyerPlugin.callClientListener('ios_callClientDidStart')" completionHandler:^(id obj, NSError *error) {
        // NOP
    }];
}

- (void)callClientDidStartReconnecting:(id <BCXCallClient>)client {
    NSLog(@"%s", __FUNCTION__);
    
    [self.webViewEngine evaluateJavaScript:@"window.cordova.plugins.BandyerPlugin.callClientListener('ios_callClientDidStartReconnecting')" completionHandler:^(id obj, NSError *error) {
        // NOP
    }];
}

- (void)callClientWillPause:(id <BCXCallClient>)client {
    NSLog(@"%s", __FUNCTION__);
    
    [self.webViewEngine evaluateJavaScript:@"window.cordova.plugins.BandyerPlugin.callClientListener('ios_callClientWillPause')" completionHandler:^(id obj, NSError *error) {
        // NOP
    }];
}

- (void)callClientDidPause:(id<BCXCallClient>)client {
    NSLog(@"%s", __FUNCTION__);
    
    [self.webViewEngine evaluateJavaScript:@"window.cordova.plugins.BandyerPlugin.callClientListener('ios_callClientDidPause')" completionHandler:^(id obj, NSError *error) {
        // NOP
    }];
}

- (void)callClientWillStop:(id <BCXCallClient>)client {
    NSLog(@"%s", __FUNCTION__);
    
    [self.webViewEngine evaluateJavaScript:@"window.cordova.plugins.BandyerPlugin.callClientListener('ios_callClientWillStop')" completionHandler:^(id obj, NSError *error) {
        // NOP
    }];
}

- (void)callClientDidStop:(id <BCXCallClient>)client {
    NSLog(@"%s", __FUNCTION__);
    
    [self.webViewEngine evaluateJavaScript:@"window.cordova.plugins.BandyerPlugin.callClientListener('ios_callClientDidStop')" completionHandler:^(id obj, NSError *error) {
        // NOP
    }];
}

- (void)callClientWillResume:(id <BCXCallClient>)client {
    NSLog(@"%s", __FUNCTION__);
    
    [self.webViewEngine evaluateJavaScript:@"window.cordova.plugins.BandyerPlugin.callClientListener('ios_callClientWillResume')" completionHandler:^(id obj, NSError *error) {
        // NOP
    }];
}

- (void)callClientDidResume:(id <BCXCallClient>)client {
    NSLog(@"%s", __FUNCTION__);
    
    [self.webViewEngine evaluateJavaScript:@"window.cordova.plugins.BandyerPlugin.callClientListener('ios_callClientDidResume')" completionHandler:^(id obj, NSError *error) {
        // NOP
    }];
}

- (void)callClient:(id <BCXCallClient>)client didFailWithError:(NSError *)error {
    NSLog(@"%s", __FUNCTION__);
    
    [self.webViewEngine evaluateJavaScript:@"window.cordova.plugins.BandyerPlugin.callClientListener('ios_callClientFailed')" completionHandler:^(id obj, NSError *error) {
        // NOP
    }];
}

#pragma mark - BDKCallViewControllerDelegate

- (void)callViewControllerDidFinish:(BDKCallViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

@end
