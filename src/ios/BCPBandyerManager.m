//
// Copyright © 2019 Bandyer S.r.l. All Rights Reserved.
// See LICENSE for licensing information
//

#import <BandyerSDK/BandyerSDK.h>

#import "BCPBandyerManager.h"
#import "BCPConstants.h"
#import "BCPUsersDetailsCache.h"
#import "NSString+BandyerPlugin.h"

@interface BCPBandyerManager() <BCXCallClientObserver, BDKCallViewControllerDelegate>

@property (nonatomic, strong) BandyerSDK *bandyer;
@property (nonatomic, strong) BCPUsersDetailsCache *userDetailsCache;

@end

@implementation BCPBandyerManager

+ (instancetype)shared 
{
    static BCPBandyerManager *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    
    return shared;
}

- (instancetype)init 
{
    self = [super init];

    if (self) 
    {
        _bandyer = [BandyerSDK instance];
        _userDetailsCache = [BCPUsersDetailsCache new];
    }

    return self;
}

- (id<BCXCallClient>)callClient 
{
    @try {
        return [self.bandyer callClient];
        
    } @catch (NSException *exception) {
        return nil;
    }
}

- (BOOL)configureBandyerWithParams:(NSDictionary * _Nonnull)params 
{
    BDKConfig *config = [BDKConfig new];
    BDKEnvironment *environment = [[params valueForKey:kBCPBandyerEnvironment] toBDKEnvironment];
    
    if (environment == nil)
        return NO;
    
    [config setEnvironment:environment];
    [config setCallKitEnabled:[params valueForKey:kBCPBandyerEnvironment]];
    
    NSString *appID = [params valueForKey:kBCPBandyerApplicationID];
    
    if (appID == nil || [appID length] == 0)
        return NO;
    
    if ([[params valueForKey:kBCPBandyerLogEnabled] boolValue] == YES) 
    {
        [BCXConfig setLogLevel:BDFDDLogLevelAll];
        [BDKConfig setLogLevel:BDFDDLogLevelAll];
    }
    
    [self.bandyer initializeWithApplicationId:appID config:config];
    
    return YES;
}

- (void)addCallClient 
{
    [[self callClient] addObserver:self queue:dispatch_get_main_queue()];
}

- (void)removeCallClient 
{
    [[self callClient] removeObserver:self];
}

- (BOOL)startCallClientWithParams:(NSDictionary * _Nonnull)params 
{
    NSString *user = [params valueForKey:kBCPBandyerUserAlias];
    
    if (user != nil && [user length] > 0) 
    {
        [[self callClient] start:user];    
        return YES;
    }
    
    return NO;
}

- (void)pauseCallClient 
{
    [[self callClient] pause];
}

- (void)resumeCallClient 
{
    [[self callClient] resume];
}

- (void)stopCallClient 
{
    [[self callClient] stop];
}

- (NSString * _Nullable)callClientState 
{
    @try {
        BCXCallClientState state = [[self.bandyer callClient] state];
        return [NSStringFromBCXCallClientState(state) lowercaseString];
    } @catch (NSException *exception) {
        return nil;
    }
}

- (BOOL)handleNotificationPayloadWithParams:(NSDictionary * _Nonnull)params 
{
    NSDictionary *payloadDict = [params valueForKey:kBCPBandyerPushPayload];
   
    if (payloadDict == nil && self.payload == nil)
        return NO;

    NSDictionary *payload;    
    if ([payloadDict count] > 0)
        payload = payloadDict;    
    else
        payload = [[self.payload dictionaryPayload] valueForKey:kBCPBandyerKeyPathToDataDictionary];
    
    [[self callClient] handleNotification:payload];
    
    return YES;
}

- (BOOL)makeCallWithParams:(NSDictionary * _Nonnull)params 
{
    NSArray *callee = [params valueForKey:kBCPBandyerCallee];
    NSString *joinUrl = [params valueForKey:kBCPBandyerJoinUrl];
    BDKCallType typeCall = [[params valueForKey:kBCPBandyerCallType] toBDKCallType];
    BOOL recording = [[params valueForKey:kBCPBandyerRecording] boolValue];
    BOOL isCallee = NO;
    
    if ([callee count] == 0 && [joinUrl length] == 0) 
        return NO;
    
    if ([callee count] > 0) 
        isCallee = YES;
    
    BDKCallViewControllerConfiguration *config = [BDKCallViewControllerConfiguration new];    
    [config setUserInfoFetcher:self.userDetailsCache];
    
    NSURL *sampleURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sample" ofType:@"mp4"]];
    if (sampleURL) 
        [config setFakeCapturerFileURL:sampleURL];
    
    BDKCallViewController *controller = [BDKCallViewController new];
    
    [controller setDelegate:self];
    [controller setConfiguration:config];
    
    if (isCallee) 
    {
        BDKMakeCallIntent *intent = [BDKMakeCallIntent intentWithCallee:callee type:typeCall record:recording maximumDuration:0];    
        [controller handleIntent:intent];
    } else 
    {
        BDKJoinURLIntent *intent = [BDKJoinURLIntent intentWithURL:[NSURL URLWithString:joinUrl]];
        [controller handleIntent:intent];
    }
    
    [self.viewController presentViewController:controller animated:YES completion:NULL];
    
    return YES;
}

- (void)addUsersDetails:(NSDictionary *)params
{
    NSArray *details = [params valueForKey:kBCPBandyerUserDetailsKey];
    [self.userDetailsCache addUsersDetails:details];
}

- (void)removeUsersDetails
{
    [self.userDetailsCache removeUsersDetails];
}

#pragma mark - BCXCallClientObserver

- (void)callClient:(id <BCXCallClient>)client didReceiveIncomingCall:(id <BCXCall>)call 
{  
    [self.webViewEngine evaluateJavaScript:@"window.cordova.plugins.BandyerPlugin.callClientListener('ios_didReceiveIncomingCall')" completionHandler:^(id obj, NSError *error) {
        // NOP
    }];
    
    BDKCallViewControllerConfiguration *config = [BDKCallViewControllerConfiguration new];
    [config setUserInfoFetcher:self.userDetailsCache];
    
    NSURL *sampleURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sample" ofType:@"mp4"]];
    if (sampleURL)
        [config setFakeCapturerFileURL:sampleURL];

    BDKCallViewController *controller = [BDKCallViewController new];
    
    [controller setDelegate:self];
    [controller setConfiguration:config];
    
    BDKIncomingCallHandlingIntent *intent = [BDKIncomingCallHandlingIntent new];
    
    [controller handleIntent:intent];
    
    [self.viewController presentViewController:controller animated:YES completion:NULL];
}

- (void)callClientWillStart:(id <BCXCallClient>)client 
{  
    [self.webViewEngine evaluateJavaScript:@"window.cordova.plugins.BandyerPlugin.callClientListener('ios_callClientWillStart')" completionHandler:^(id obj, NSError *error) {
        // NOP
    }];
}

- (void)callClientDidStart:(id <BCXCallClient>)client 
{
    [self.webViewEngine evaluateJavaScript:@"window.cordova.plugins.BandyerPlugin.callClientListener('ios_callClientDidStart')" completionHandler:^(id obj, NSError *error) {
        // NOP
    }];
}

- (void)callClientDidStartReconnecting:(id <BCXCallClient>)client 
{
    [self.webViewEngine evaluateJavaScript:@"window.cordova.plugins.BandyerPlugin.callClientListener('ios_callClientDidStartReconnecting')" completionHandler:^(id obj, NSError *error) {
        // NOP
    }];
}

- (void)callClientWillPause:(id <BCXCallClient>)client {
    [self.webViewEngine evaluateJavaScript:@"window.cordova.plugins.BandyerPlugin.callClientListener('ios_callClientWillPause')" completionHandler:^(id obj, NSError *error) {
        // NOP
    }];
}

- (void)callClientDidPause:(id<BCXCallClient>)client 
{
    [self.webViewEngine evaluateJavaScript:@"window.cordova.plugins.BandyerPlugin.callClientListener('ios_callClientDidPause')" completionHandler:^(id obj, NSError *error) {
        // NOP
    }];
}

- (void)callClientWillStop:(id <BCXCallClient>)client 
{
    [self.webViewEngine evaluateJavaScript:@"window.cordova.plugins.BandyerPlugin.callClientListener('ios_callClientWillStop')" completionHandler:^(id obj, NSError *error) {
        // NOP
    }];
}

- (void)callClientDidStop:(id <BCXCallClient>)client 
{
    [self.webViewEngine evaluateJavaScript:@"window.cordova.plugins.BandyerPlugin.callClientListener('ios_callClientDidStop')" completionHandler:^(id obj, NSError *error) {
        // NOP
    }];
}

- (void)callClientWillResume:(id <BCXCallClient>)client 
{
    [self.webViewEngine evaluateJavaScript:@"window.cordova.plugins.BandyerPlugin.callClientListener('ios_callClientWillResume')" completionHandler:^(id obj, NSError *error) {
        // NOP
    }];
}

- (void)callClientDidResume:(id <BCXCallClient>)client 
{
    [self.webViewEngine evaluateJavaScript:@"window.cordova.plugins.BandyerPlugin.callClientListener('ios_callClientDidResume')" completionHandler:^(id obj, NSError *error) {
        // NOP
    }];
}

- (void)callClient:(id <BCXCallClient>)client didFailWithError:(NSError *)error 
{
    [self.webViewEngine evaluateJavaScript:@"window.cordova.plugins.BandyerPlugin.callClientListener('ios_callClientFailed')" completionHandler:^(id obj, NSError *error) {
        // NOP
    }];
}

#pragma mark - BDKCallViewControllerDelegate

- (void)callViewControllerDidFinish:(BDKCallViewController *)controller 
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

@end
