//
// Copyright © 2019 Bandyer S.r.l. All Rights Reserved.
// See LICENSE for licensing information
//

#import "BandyerManager.h"

@interface BandyerManager() <BCXCallClientObserver, BDKCallViewControllerDelegate>

@property (nonatomic, strong) BandyerSDK *bandyer;
@property (nonatomic, strong) BandyerUserInfoFetch *userInfoFetch;

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

- (BOOL)configureBandyerWithParams:(NSDictionary * _Nonnull)params {
    BDKConfig *config = [BDKConfig new];
    BDKEnvironment *environment = [[params valueForKey:kBCPBandyerEnvironment] toBDKEnvironment];
    
    if (environment == nil) {
        return NO;
    }
    
    [config setEnvironment:environment];
    [config setCallKitEnabled:[params valueForKey:kBCPBandyerEnvironment]];
    
    NSString *appID = [params valueForKey:kBCPBandyerApplicationID];
    
    if (appID == nil || [appID length] == 0) {
        return NO;
    }
    
    if ([[params valueForKey:kBCPBandyerLogEnabled] boolValue] == YES) {
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
    NSString *user = [params valueForKey:kBCPBandyerUsername];
    
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

- (NSString * _Nullable)callClientState {
    @try {
        BCXCallClientState state = [[self.bandyer callClient] state];
        return [NSStringFromBCXCallClientState(state) lowercase];
    } @catch (NSException *exception) {
        return nil;
    }
}

- (BOOL)handleNotificationPayloadWithParams:(NSDictionary * _Nonnull)params {
    NSDictionary *payloadDict = [params valueForKey:kBCPBandyerPushPayload];
    NSDictionary *payload;
    
    if (payloadDict == nil && self.payload == nil) {
        return NO;
    }
    
    if ([payloadDict count] > 0) {
        payload = payloadDict;
        
    } else {
        payload = [[self.payload dictionaryPayload] valueForKey:kBCPBandyerKeyPathToDataDictionary];
    }
    
    [[self callClient] handleNotification:payload];
    
    return YES;
}

- (BOOL)makeCallWithParams:(NSDictionary * _Nonnull)params {
    NSArray *callee = [params valueForKey:kBCPBandyerCallee];
    NSString *joinUrl = [params valueForKey:kBCPBandyerJoinUrl];
    BDKCallType typeCall = [[params valueForKey:kBCPBandyerCallType] toBDKCallType];
    BOOL recording = [[params valueForKey:kBCPBandyerRecording] boolValue];
    
    BOOL isCallee = NO;
    
    if ([callee count] == 0 && [joinUrl length] == 0) {
        return NO;
    }
    
    if ([callee count] > 0) {
        isCallee = YES;
    }
    
    BDKCallViewControllerConfiguration *config = [BDKCallViewControllerConfiguration new];
    
    if ([self userInfoFetch]) {
        [config setUserInfoFetcher:[self userInfoFetch]];
    }
    
    NSString *pathSampleVideo = [[NSBundle mainBundle] pathForResource:@"sample" ofType:@"mp4"];
    
    if (pathSampleVideo != NULL) {
        [config setFakeCapturerFileURL:[NSURL fileURLWithPath:pathSampleVideo]];
    }
    
    BDKCallViewController *controller = [BDKCallViewController new];
    
    [controller setDelegate:self];
    [controller setConfiguration:config];
    
    if (isCallee) {
        BDKMakeCallIntent *intent = [BDKMakeCallIntent intentWithCallee:callee type:typeCall record:recording maximumDuration:0];
        
        [controller handleIntent:intent];
        
    } else {
        BDKJoinURLIntent *intent = [BDKJoinURLIntent intentWithURL:[NSURL URLWithString:joinUrl]];
        
        [controller handleIntent:intent];
    }
    
    [self.viewController presentViewController:controller animated:YES completion:NULL];
    
    return YES;
}

- (void)createUserInfoFetchWithParams:(NSDictionary *)params {
    NSArray *address = [params valueForKey:kBCPBandyerAddress];
    
    [self setUserInfoFetch:[[BandyerUserInfoFetch alloc] initWithAddress:address]];
}

- (void)clearCache {
    [self setPayload:nil];
    [self setUserInfoFetch:nil];
}

#pragma mark - BCXCallClientObserver

- (void)callClient:(id <BCXCallClient>)client didReceiveIncomingCall:(id <BCXCall>)call {  
    [self.webViewEngine evaluateJavaScript:@"window.cordova.plugins.BandyerPlugin.callClientListener('ios_didReceiveIncomingCall')" completionHandler:^(id obj, NSError *error) {
        // NOP
    }];
    
    BDKCallViewControllerConfiguration *config = [BDKCallViewControllerConfiguration new];
    
    if ([self userInfoFetch]) {
        [config setUserInfoFetcher:[self userInfoFetch]];
    }
    
    BDKCallViewController *controller = [BDKCallViewController new];
    
    [controller setDelegate:self];
    [controller setConfiguration:config];
    
    BDKIncomingCallHandlingIntent *intent = [BDKIncomingCallHandlingIntent new];
    
    [controller handleIntent:intent];
    
    [self.viewController presentViewController:controller animated:YES completion:NULL];
}

- (void)callClientWillStart:(id <BCXCallClient>)client {  
    [self.webViewEngine evaluateJavaScript:@"window.cordova.plugins.BandyerPlugin.callClientListener('ios_callClientWillStart')" completionHandler:^(id obj, NSError *error) {
        // NOP
    }];
}

- (void)callClientDidStart:(id <BCXCallClient>)client {
    [self.webViewEngine evaluateJavaScript:@"window.cordova.plugins.BandyerPlugin.callClientListener('ios_callClientDidStart')" completionHandler:^(id obj, NSError *error) {
        // NOP
    }];
}

- (void)callClientDidStartReconnecting:(id <BCXCallClient>)client {
    [self.webViewEngine evaluateJavaScript:@"window.cordova.plugins.BandyerPlugin.callClientListener('ios_callClientDidStartReconnecting')" completionHandler:^(id obj, NSError *error) {
        // NOP
    }];
}

- (void)callClientWillPause:(id <BCXCallClient>)client {
    [self.webViewEngine evaluateJavaScript:@"window.cordova.plugins.BandyerPlugin.callClientListener('ios_callClientWillPause')" completionHandler:^(id obj, NSError *error) {
        // NOP
    }];
}

- (void)callClientDidPause:(id<BCXCallClient>)client {
    [self.webViewEngine evaluateJavaScript:@"window.cordova.plugins.BandyerPlugin.callClientListener('ios_callClientDidPause')" completionHandler:^(id obj, NSError *error) {
        // NOP
    }];
}

- (void)callClientWillStop:(id <BCXCallClient>)client {
    [self.webViewEngine evaluateJavaScript:@"window.cordova.plugins.BandyerPlugin.callClientListener('ios_callClientWillStop')" completionHandler:^(id obj, NSError *error) {
        // NOP
    }];
}

- (void)callClientDidStop:(id <BCXCallClient>)client {
    [self.webViewEngine evaluateJavaScript:@"window.cordova.plugins.BandyerPlugin.callClientListener('ios_callClientDidStop')" completionHandler:^(id obj, NSError *error) {
        // NOP
    }];
}

- (void)callClientWillResume:(id <BCXCallClient>)client {
    [self.webViewEngine evaluateJavaScript:@"window.cordova.plugins.BandyerPlugin.callClientListener('ios_callClientWillResume')" completionHandler:^(id obj, NSError *error) {
        // NOP
    }];
}

- (void)callClientDidResume:(id <BCXCallClient>)client {
    [self.webViewEngine evaluateJavaScript:@"window.cordova.plugins.BandyerPlugin.callClientListener('ios_callClientDidResume')" completionHandler:^(id obj, NSError *error) {
        // NOP
    }];
}

- (void)callClient:(id <BCXCallClient>)client didFailWithError:(NSError *)error {
    [self.webViewEngine evaluateJavaScript:@"window.cordova.plugins.BandyerPlugin.callClientListener('ios_callClientFailed')" completionHandler:^(id obj, NSError *error) {
        // NOP
    }];
}

#pragma mark - BDKCallViewControllerDelegate

- (void)callViewControllerDidFinish:(BDKCallViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

@end
