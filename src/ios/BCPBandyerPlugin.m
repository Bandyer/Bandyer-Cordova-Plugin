// Copyright © 2019 Bandyer S.r.l. All Rights Reserved.
// See LICENSE for licensing information

#import "BCPBandyerPlugin.h"
#import "BCPUsersDetailsCache.h"
#import "BCPUsersDetailsCommandsHandler.h"
#import "BCPUserInterfaceCoordinator.h"
#import "BCPConstants.h"
#import "BCPEventEmitter.h"
#import "BCPCallClientEventsReporter.h"
#import "BCPPushTokenEventsReporter.h"
#import "BCPChatClientEventsReporter.h"
#import "BCPUsersDetailsProvider.h"
#import "BCPFormatterProxy.h"
#import "BCPUserDetailsFormatter.h"
#import "CDVPluginResult+BCPFactoryMethods.h"
#import "NSString+BandyerPlugin.h"

#import <Bandyer/Bandyer.h>

@interface BCPBandyerPlugin () <BDKCallClientObserver>

@property (nonatomic, strong) BCPFormatterProxy *formatterProxy;
@property (nonatomic, strong, readwrite, nullable) BCPUsersDetailsCache *usersCache;
@property (nonatomic, strong, readwrite, nullable) BCPUserInterfaceCoordinator *coordinator;
@property (nonatomic, strong, nullable) BCPEventEmitter *eventEmitter;
@property (nonatomic, strong, nullable) BCPCallClientEventsReporter *callClientEventsReporter;
@property (nonatomic, strong, nullable) BCPChatClientEventsReporter *chatClientEventsReporter;
@property (nonatomic, strong, readwrite) BandyerSDK *sdk;

@end

@implementation BCPBandyerPlugin

- (instancetype)init
{
    self = [self initWithBandyerSDK:BandyerSDK.instance];
    return self;
}

- (instancetype)initWithBandyerSDK:(BandyerSDK *)sdk
{
    NSParameterAssert(sdk);

    self = [super init];
    if (self)
    {
        _sdk = sdk;
    }
    return self;
}

- (void)pluginInitialize
{
    [super pluginInitialize];

    [self setupSDKIfNeeded];
    self.formatterProxy = [BCPFormatterProxy new];
    self.usersCache = [BCPUsersDetailsCache new];
    self.coordinator = [self makeUserInterfaceCoordinator];
}

- (BCPUserInterfaceCoordinator *)makeUserInterfaceCoordinator
{
    return [[BCPUserInterfaceCoordinator alloc] initWithRootViewController:self.viewController];
}

- (void)setupSDKIfNeeded
{
    if (_sdk == nil)
        _sdk = BandyerSDK.instance;
}

- (void)initializeBandyer:(CDVInvokedUrlCommand *)command 
{
    self.eventEmitter = [[BCPEventEmitter alloc] initWithCallbackId:command.callbackId commandDelegate:self.commandDelegate];

    NSDictionary *args = command.arguments.firstObject;
    BDKConfig *config = [BDKConfig new];
    BDKEnvironment *environment = [args[kBCPEnvironmentKey] toBDKEnvironment];

    if (environment == nil)
    {
        [self reportCommandFailed:command];
        return;
    }

    config.environment = environment;
    if (@available(iOS 10.0, *))
    {
        NSNumber * callkitEnabled = args[kBCPCallKitConfigKey][kBCPCallKitConfigEnabledKey];
        config.callKitEnabled = [callkitEnabled boolValue];

        if (config.isCallKitEnabled)
        {
            config.nativeUIRingToneSound = args[kBCPCallKitConfigKey][kBCPCallKitConfigRingtoneKey];
            NSString *appIconResourceName = args[kBCPCallKitConfigKey][kBCPCallKitConfigIconKey];

            if (appIconResourceName)
            {
                NSString *path = [[NSBundle mainBundle] pathForResource:appIconResourceName ofType:@"png"];
                if (path)
                {
                    UIImage *appIcon = [UIImage imageWithContentsOfFile:path];
                    if (appIcon)
                    {
                        config.nativeUITemplateIconImageData = UIImagePNGRepresentation(appIcon);
                    }
                }
            }

            config.pushRegistryDelegate = [[BCPPushTokenEventsReporter alloc] initWithEventEmitter:self.eventEmitter];
            config.notificationPayloadKeyPath = args[kBCPVoipPushPayloadKey];
        }
    }

    self.coordinator.fakeCapturerFilename = args[kBCPFakeCapturerFilenameKey];

    NSString *appID = args[kBCPApplicationIDKey];

    if (appID.length == 0)
    {
        [self reportCommandFailed:command];
        return;
    }

    if ([args[kBCPLogEnabledKey] boolValue] == YES)
    {
        BandyerSDK.logLevel = BDKLogLevelAll;
    }

    [self.sdk initializeWithApplicationId:appID config:config];
    self.sdk.userDetailsProvider = [[BCPUsersDetailsProvider alloc] initWithCache:self.usersCache formatter:self.formatterProxy];
    self.coordinator.sdk = self.sdk;
    self.callClientEventsReporter = [[BCPCallClientEventsReporter alloc] initWithCallClient:self.sdk.callClient eventEmitter:self.eventEmitter];
    [self.callClientEventsReporter start];
    self.chatClientEventsReporter = [[BCPChatClientEventsReporter alloc] initWithChatClient:self.sdk.chatClient eventEmitter:self.eventEmitter];
    [self.chatClientEventsReporter start];
    [self reportCommandSucceeded:command];
}

- (void)start:(CDVInvokedUrlCommand *)command 
{
    NSDictionary *args = command.arguments.firstObject;
    NSString *user = args[kBCPUserAliasKey];

    if (user.length == 0)
    {
        [self reportCommandFailed:command];
        return;
    }

    [self.sdk openSessionWithUserId:user];
    [self.sdk.callClient addObserver:self queue:dispatch_get_main_queue()];
    [self.sdk.callClient start];
    [self.sdk.chatClient start];

    [self reportCommandSucceeded:command];
}

- (void)stop:(CDVInvokedUrlCommand *)command 
{
    [self.sdk.callClient removeObserver:self];
    [self.sdk.callClient stop];
    [self.sdk.chatClient stop];
    [self.sdk closeSession];

    [self reportCommandSucceeded:command];
}

- (void)pause:(CDVInvokedUrlCommand *)command 
{
    [self.sdk.callClient pause];
    [self.sdk.chatClient pause];

    [self reportCommandSucceeded:command];
}

- (void)resume:(CDVInvokedUrlCommand *)command 
{
    [self.sdk.callClient resume];
    [self.sdk.chatClient resume];

    [self reportCommandSucceeded:command];
}

- (void)state:(CDVInvokedUrlCommand *)command 
{
    NSString *stateAsString = [self stringFromCallClientState:self.sdk.callClient];

    [self reportCommandSucceeded:command withMessageAsString:stateAsString];
}

- (void)handlePushNotificationPayload:(CDVInvokedUrlCommand *)command 
{
    [self reportCommandFailed:command];
}

- (void)startCall:(CDVInvokedUrlCommand *)command
{
    NSDictionary *args = command.arguments.firstObject;
    NSArray *callee = args[kBCPCalleeKey];
    NSString *joinUrl = args[kBCPJoinUrlKey];
    BDKCallType typeCall = [args[kBCPCallTypeKey] toBDKCallType];
    BOOL recording = [args[kBCPRecordingKey] boolValue];

    if (callee.count == 0 && joinUrl.length == 0)
    {
        [self reportCommandFailed:command];
        return;
    }

    id <BDKIntent> intent;

    if (joinUrl.length > 0)
    {
        intent = [BDKJoinURLIntent intentWithURL:[NSURL URLWithString:joinUrl]];
    } else
    {
        BDKCallOptions *callOptions = [BDKCallOptions optionsWithCallType:typeCall recorded:recording];
        intent = [[BDKStartOutgoingCallIntent alloc] initWithCallees:callee options:callOptions];
    }

    [self.coordinator handleIntent:intent];

    [self reportCommandSucceeded:command];
}

- (void)startChat:(CDVInvokedUrlCommand *)command
{
    NSDictionary *args = command.arguments.firstObject;
    NSString *user = args[kBCPUserAliasKey];
    NSNumber *audioOnly = args[kBCPAudioOnlyTypeKey];
    NSNumber *audioUpgradable = args[kBCPAudioUpgradableTypeKey];
    NSNumber *audioVideo = args[kBCPAudioVideoTypeKey];

    if (user.length == 0)
    {
        [self reportCommandFailed:command];
        return;
    }

    //TODO: HANDLE CALL OPTIONS
    BDKOpenChatIntent *intent = [BDKOpenChatIntent openChatWith:user];
    [self.coordinator handleIntent:intent];

    [self reportCommandSucceeded:command];
}

- (void)addUsersDetails:(CDVInvokedUrlCommand *)command 
{
    BCPUsersDetailsCommandsHandler *handler = [[BCPUsersDetailsCommandsHandler alloc] initWithCommandDelegate:self.commandDelegate cache:self.usersCache];
    [handler addUsersDetails:command];
}

- (void)removeUsersDetails:(CDVInvokedUrlCommand *)command 
{
    BCPUsersDetailsCommandsHandler *handler = [[BCPUsersDetailsCommandsHandler alloc] initWithCommandDelegate:self.commandDelegate cache:self.usersCache];
    [handler purge:command];
}

- (void)setUserDetailsFormat:(CDVInvokedUrlCommand *)command
{
    NSDictionary *args = command.arguments.firstObject;

    NSString *format = args[kBCPDetailsFormatterFormatKey];
    if (format != nil && [format isKindOfClass:NSString.class])
    {
        self.coordinator.userDetailsFormat = format;
        self.formatterProxy.formatter = [[BCPUserDetailsFormatter alloc] initWithFormat:format];
        [self.commandDelegate sendPluginResult:[CDVPluginResult bcp_success] callbackId:command.callbackId];
    } else
    {
        [self.commandDelegate sendPluginResult:[CDVPluginResult bcp_error] callbackId:command.callbackId];
    }
}

// MARK: Command result reporting

- (void)reportCommandSucceeded:(CDVInvokedUrlCommand *)command
{
    [self.commandDelegate sendPluginResult:[CDVPluginResult bcp_success] callbackId:command.callbackId];
}

- (void)reportCommandSucceeded:(CDVInvokedUrlCommand *)command withMessageAsString:(NSString *)message
{
    [self.commandDelegate sendPluginResult:[CDVPluginResult bcp_successWithMessageAsString:message] callbackId:command.callbackId];
}

- (void)reportCommandFailed:(CDVInvokedUrlCommand *)command
{
    [self.commandDelegate sendPluginResult:[CDVPluginResult bcp_error] callbackId:command.callbackId];
}

// MARK: BDKCallClientObserver

- (void)callClient:(id <BDKCallClient>)client didReceiveIncomingCall:(id <BDKCall>)call
{
    [self.coordinator handleIntent:[[BDKHandleIncomingCallIntent alloc] initWithCall:call]];
}

- (NSString *)stringFromCallClientState:(id<BDKCallClient>)client
{
    switch (client.state) {
        case BDKCallClientStateStopped:
            return @"stopped";
        case BDKCallClientStateStarting:
            return @"starting";
        case BDKCallClientStateRunning:
            return @"running";
        case BDKCallClientStateResuming:
            return @"resuming";
        case BDKCallClientStatePaused:
            return @"paused";
        case BDKCallClientStateReconnecting:
            return @"reconnecting";
        case BDKCallClientStateFailed:
            return @"failed";
    }
}

@end
