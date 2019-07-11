//
// Copyright © 2019 Bandyer S.r.l. All Rights Reserved.
// See LICENSE for licensing information
//

#import <BandyerSDK/BandyerSDK.h>

#import "BCPBandyerManager.h"
#import "BCPConstants.h"
#import "BCPUsersDetailsCache.h"
#import "NSString+BandyerPlugin.h"
#import "BCPCallClientEventEmitter.h"

@interface BCPBandyerManager () <BCXCallClientObserver, BDKCallViewControllerDelegate>

@property (nonatomic, strong) BandyerSDK *bandyer;
@property (nonatomic, strong) BCPUsersDetailsCache *userDetailsCache;
@property (nonatomic, strong, nullable) NSDictionary *payload;

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

- (id <BCXCallClient>)callClient
{
    @try
    {
        return [self.bandyer callClient];
    } @catch (NSException *exception)
    {
        return nil;
    }
}

- (BOOL)configureBandyerWithParams:(NSDictionary *)params
{
    NSAssert(params, @"Params dictionary must be provided, got nil");

    BDKConfig *config = [BDKConfig new];
    BDKEnvironment *environment = [[params valueForKey:kBCPEnvironmentKey] toBDKEnvironment];

    if (environment == nil)
        return NO;

    [config setEnvironment:environment];
    [config setCallKitEnabled:[params valueForKey:kBCPCallKitEnabledKey] ? YES : NO];

    NSString *appID = [params valueForKey:kBCPApplicationIDKey];

    if (appID == nil || [appID length] == 0)
        return NO;

    if ([[params valueForKey:kBCPLogEnabledKey] boolValue] == YES)
    {
        [BCXConfig setLogLevel:BDFDDLogLevelAll];
        [BDKConfig setLogLevel:BDFDDLogLevelAll];
    }

    [self.bandyer initializeWithApplicationId:appID config:config];

    return YES;
}

- (BOOL)startCallClientWithParams:(NSDictionary *)params
{
    NSAssert(params, @"Params dictionary must be provided, got nil");

    NSString *user = [params valueForKey:kBCPUserAliasKey];

    if (user != nil && [user length] > 0)
    {
        [[self callClient] addObserver:self queue:dispatch_get_main_queue()];
        [self.notifier start];
        [[self callClient] start:user];
        return YES;
    }

    return NO;
}

- (void)pauseCallClient
{
    [[self callClient] pause];
    self.payload = nil;
}

- (void)resumeCallClient
{
    [[self callClient] resume];
}

- (void)stopCallClient
{
    [[self callClient] removeObserver:self];
    [self.notifier stop];
    [[self callClient] stop];
    self.payload = nil;
}

- (nullable NSString *)callClientState
{
    @try
    {
        BCXCallClientState state = [[self.bandyer callClient] state];
        return [NSStringFromBCXCallClientState(state) lowercaseString];
    } @catch (NSException *exception)
    {
        return nil;
    }
}

- (BOOL)handleNotificationPayloadWithParams:(NSDictionary *)params
{
    NSDictionary *payload = [params valueForKey:kBCPPushPayloadKey];

    if (![payload isKindOfClass:NSDictionary.class])
        return NO;

    if (payload == nil || [payload count] == 0)
        return NO;

    if (self.callClient.state == BCXCallClientStateRunning)
    {
        [self.callClient handleNotification:payload];
    }
    else
    {
        self.payload = payload;

        if (self.callClient.state == BCXCallClientStatePaused)
            [self.callClient resume];
    }

    return YES;
}

- (BOOL)startCallWithParams:(NSDictionary *)params
{
    NSAssert(params, @"Params dictionary must be provided, got nil");

    NSArray *callee = [params valueForKey:kBCPCalleeKey];
    NSString *joinUrl = [params valueForKey:kBCPJoinUrlKey];
    BDKCallType typeCall = [[params valueForKey:kBCPCallTypeKey] toBDKCallType];
    BOOL recording = [[params valueForKey:kBCPRecordingKey] boolValue];
    BOOL isCallee = NO;

    if ([callee count] == 0 && [joinUrl length] == 0)
        return NO;

    if ([callee count] > 0)
        isCallee = YES;

    BDKCallViewController *controller = [self _createCallViewController];

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
    NSAssert(params, @"Params dictionary must be provided, got nil");

    NSArray *details = [params valueForKey:kBCPUserDetailsKey];
    [self.userDetailsCache addUsersDetails:details];
}

- (void)removeUsersDetails
{
    [self.userDetailsCache removeUsersDetails];
}

#pragma mark - BCXCallClientObserver

- (void)callClient:(id <BCXCallClient>)client didReceiveIncomingCall:(id <BCXCall>)call
{
    BDKCallViewController *controller = [self _createCallViewController];

    BDKIncomingCallHandlingIntent *intent = [BDKIncomingCallHandlingIntent new];

    [controller handleIntent:intent];

    [self.viewController presentViewController:controller animated:YES completion:NULL];
}

- (void)callClientDidStart:(id <BCXCallClient>)client
{
    if (client.state == BCXCallClientStateRunning && self.payload)
    {
        [[self callClient] handleNotification:self.payload];
        self.payload = nil;
    }
}

- (void)callClientDidResume:(id <BCXCallClient>)client
{
    if (client.state == BCXCallClientStateRunning && self.payload)
    {
        [[self callClient] handleNotification:self.payload];
        self.payload = nil;
    }
}

- (void)callClient:(id <BCXCallClient>)client didFailWithError:(NSError *)error
{
    self.payload = nil;
}

- (BDKCallViewController *)_createCallViewController
{
    BDKCallViewControllerConfiguration *config = [BDKCallViewControllerConfiguration new];
    [config setUserInfoFetcher:self.userDetailsCache];

    NSURL *sampleURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sample" ofType:@"mp4"]];
    if (sampleURL)
        [config setFakeCapturerFileURL:sampleURL];

    BDKCallViewController *controller = [BDKCallViewController new];

    [controller setDelegate:self];
    [controller setConfiguration:config];
    return controller;
}

#pragma mark - BDKCallViewControllerDelegate

- (void)callViewControllerDidFinish:(BDKCallViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

@end
