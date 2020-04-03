//
// Copyright © 2019 Bandyer S.r.l. All Rights Reserved.
// See LICENSE for licensing information
//

#import <Bandyer/Bandyer.h>
#import <Bandyer/Bandyer-Swift.h>

#import "BCPBandyerPlugin.h"
#import "BCPUsersDetailsCache.h"
#import "BCPUsersDetailsCommandsHandler.h"
#import "BCPUserInterfaceCoordinator.h"
#import "BCPConstants.h"
#import "BCPEventEmitter.h"
#import "BCPCallClientEventsReporter.h"
#import "BCPContactHandleProvider.h"
#import "BCPPushTokenEventsReporter.h"
#import "BCPChatClientEventsReporter.h"

#import "CDVPluginResult+BCPFactoryMethods.h"
#import "NSString+BandyerPlugin.h"

@interface BCPBandyerPlugin () <BCXCallClientObserver>

@property (nonatomic, strong, nullable) BCPUsersDetailsCache *usersCache;
@property (nonatomic, strong, nullable) BCPUserInterfaceCoordinator *coordinator;
@property (nonatomic, strong, nullable) BCPEventEmitter *eventEmitter;
@property (nonatomic, strong, nullable) BCPCallClientEventsReporter *callClientEventsReporter;
@property (nonatomic, strong, nullable) BCPChatClientEventsReporter *chatClientEventsReporter;

@end

@implementation BCPBandyerPlugin

- (void)pluginInitialize 
{
    [super pluginInitialize];

    self.usersCache = [BCPUsersDetailsCache new];
    self.coordinator = [[BCPUserInterfaceCoordinator alloc] initWithRootViewController:self.viewController usersCache:self.usersCache];
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
            config.handleProvider = [[BCPContactHandleProvider alloc] initWithCache:self.usersCache];
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
        [BDKConfig setLogLevel:BDFDDLogLevelAll];
    }

    [BandyerSDK.instance initializeWithApplicationId:appID config:config];

    [self.coordinator sdkInitialized];
    self.callClientEventsReporter = [[BCPCallClientEventsReporter alloc] initWithCallClient:BandyerSDK.instance.callClient eventEmitter:self.eventEmitter];
    [self.callClientEventsReporter start];
    self.chatClientEventsReporter = [[BCPChatClientEventsReporter alloc] initWithChatClient:BandyerSDK.instance.chatClient eventEmitter:self.eventEmitter];
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

    [BandyerSDK.instance.callClient addObserver:self queue:dispatch_get_main_queue()];
    [BandyerSDK.instance.callClient start:user];
    [BandyerSDK.instance.chatClient start:user];

    [self reportCommandSucceeded:command];
}

- (void)stop:(CDVInvokedUrlCommand *)command 
{
    [BandyerSDK.instance.callClient removeObserver:self];
    [BandyerSDK.instance.callClient stop];
    [BandyerSDK.instance.chatClient stop];

    [self reportCommandSucceeded:command];
}

- (void)pause:(CDVInvokedUrlCommand *)command 
{
    [BandyerSDK.instance.callClient pause];
    [BandyerSDK.instance.chatClient pause];

    [self reportCommandSucceeded:command];
}

- (void)resume:(CDVInvokedUrlCommand *)command 
{
    [BandyerSDK.instance.callClient resume];
    [BandyerSDK.instance.chatClient resume];

    [self reportCommandSucceeded:command];
}

- (void)state:(CDVInvokedUrlCommand *)command 
{
    BCXCallClientState state = [BandyerSDK.instance.callClient state];
    NSString *stateAsString = [NSStringFromBCXCallClientState(state) lowercaseString];

    if (stateAsString)
        [self reportCommandSucceeded:command withMessageAsString:stateAsString];
    else
        [self reportCommandFailed:command];
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
        intent = [BDKMakeCallIntent intentWithCallee:callee type:typeCall record:recording maximumDuration:0];
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
    BCHOpenChatIntent *intent = [BCHOpenChatIntent openChatWith:user];
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
    [handler removeUsersDetails:command];
}

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

- (void)callClient:(id <BCXCallClient>)client didReceiveIncomingCall:(id <BCXCall>)call
{
    [self.coordinator handleIntent:[BDKIncomingCallHandlingIntent new]];
}

@end
