// Copyright © 2020 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information

#import <XCTest/XCTest.h>
#import <Cordova/CDV.h>
#import <OCMockito/OCMockito.h>
#import <OCHamcrest/OCHamcrest.h>
#import <Bandyer/Bandyer.h>

#import "BCPTestCase.h"
#import "BCPBandyerPlugin.h"
#import "BCPUserInterfaceCoordinator.h"
#import "BCPPluginResultMatcher.h"
#import "BCPUsersDetailsCache.h"
#import "BCPUsersDetailsProvider.h"
#import "CDVPluginResult+BCPFactoryMethods.h"

@interface BCPBandyerPluginExposed : BCPBandyerPlugin

- (BCPUserInterfaceCoordinator *)makeUserInterfaceCoordinator;

@end

@implementation BCPBandyerPluginExposed

- (BCPUserInterfaceCoordinator *)makeUserInterfaceCoordinator
{
    return mock(BCPUserInterfaceCoordinator.class);
}

@end

@interface BCPBandyerPluginTests : BCPTestCase

@end

@implementation BCPBandyerPluginTests
{
    UIViewController *viewController;
    id<CDVCommandDelegate> delegate;
}

- (void)setUp
{
    [super setUp];

    viewController = [UIViewController new];
    delegate = mockProtocol(@protocol(CDVCommandDelegate));
}

// MARK: Initialize

- (void)testInitializeBandyerReportsErrorWhenConfigIsMissingEnvironment
{
    BCPBandyerPlugin *sut = [self makeSUT];

    CDVInvokedUrlCommand *command = [self makeCommand:@"callbackId" payload:@{}];
    [sut initializeBandyer:command];

    [verify(delegate) sendPluginResult:equalToResult([CDVPluginResult bcp_error]) callbackId:@"callbackId"];
}

- (void)testInitializeBandyerReportsErrorWhenAppIdIsMissing
{
    BCPBandyerPlugin *sut = [self makeSUT];

    CDVInvokedUrlCommand *command = [self makeCommand:@"callbackId" payload:@{
        @"environment" : @"sandbox"
    }];
    [sut initializeBandyer:command];

    [verify(delegate) sendPluginResult:equalToResult([CDVPluginResult bcp_error]) callbackId:@"callbackId"];
}

- (void)testInitializeBandyerReportsErrorWhenAppIdIsBlank
{
    BCPBandyerPlugin *sut = [self makeSUT];

    CDVInvokedUrlCommand *command = [self makeCommand:@"callbackId" payload:@{
        @"environment" : @"sandbox",
        @"appId" : [NSString string]
    }];
    [sut initializeBandyer:command];

    [verify(delegate) sendPluginResult:equalToResult([CDVPluginResult bcp_error]) callbackId:@"callbackId"];
}

- (void)testInitializeBandyerInitializesTheNativeSDK
{
    BandyerSDK *sdkMock = [self makeSDKMock];
    BCPBandyerPlugin *sut = [self makeExposedSUTWithSDK:sdkMock initializePlugin:YES];

    CDVInvokedUrlCommand *command = [self makeCommandWithPayload:@{
        @"environment" : @"sandbox",
        @"appId" : @"appId"
    }];
    [sut initializeBandyer:command];

    HCArgumentCaptor *configCaptor = [HCArgumentCaptor new];
    [verify(sdkMock) initializeWithApplicationId:@"appId" config:(id)configCaptor];
    BDKConfig *config = configCaptor.value;
    assertThat(config.environment.name, equalTo(BDKEnvironment.sandbox.name));
}

- (void)testInitializeBandyerAddUserDetailsProviderToNativeSDK
{
    BandyerSDK *sdkMock = [self makeSDKMock];
    BCPBandyerPlugin *sut = [self makeExposedSUTWithSDK:sdkMock initializePlugin:YES];

    CDVInvokedUrlCommand *command = [self makeCommandWithPayload:@{
        @"environment" : @"sandbox",
        @"appId" : @"appId"
    }];
    [sut initializeBandyer:command];

    [verify(sdkMock) setUserDetailsProvider:instanceOf(BCPUsersDetailsProvider.class)];
}

- (void)testInitializeBandyerNotifiesSuccess
{
    BandyerSDK *sdkMock = [self makeSDKMock];
    BCPBandyerPlugin *sut = [self makeExposedSUTWithSDK:sdkMock initializePlugin:YES];

    CDVInvokedUrlCommand *command = [self makeCommand:@"callbackId" payload:@{
        @"environment" : @"sandbox",
        @"appId" : @"appId"
    }];
    [sut initializeBandyer:command];

    [verify(delegate) sendPluginResult:equalToResult([CDVPluginResult bcp_success]) callbackId:@"callbackId"];
}

- (void)testInitializeBandyerEnablesLoggingWhenEnableLogFlagIsProvidedInConfig
{
    BandyerSDK *sdkMock = [self makeSDKMock];
    BCPBandyerPlugin *sut = [self makeExposedSUTWithSDK:sdkMock initializePlugin:YES];

    CDVInvokedUrlCommand *command = [self makeCommandWithPayload:@{
        @"environment" : @"sandbox",
        @"appId" : @"appId",
        @"logEnabled" : @YES
    }];
    [self addTeardownBlock:^{
        BandyerSDK.logLevel = BDKLogLevelOff;
    }];
    [sut initializeBandyer:command];

    assertThatInteger(BandyerSDK.logLevel, equalToInteger(BDKLogLevelAll));
}

- (void)testInitializeBandyerTellsUICoordinatorTheSDKHasBeenInitialized
{
    BandyerSDK *sdkMock = [self makeSDKMock];
    BCPBandyerPlugin *sut = [self makeExposedSUTWithSDK:sdkMock initializePlugin:YES];

    CDVInvokedUrlCommand *command = [self makeCommandWithPayload:@{
        @"environment" : @"sandbox",
        @"appId" : @"appId",
    }];
    [sut initializeBandyer:command];

    [verify(sut.coordinator) setSdk:sdkMock];
}

- (void)testInitializeShouldReadTheBroadcastConfigurationFromTheConfigFileAndSetupTheBroadcastToolWithTheValuesFoundInTheConfigFile API_AVAILABLE(ios(12.0))
{
    if (@available(iOS 12.0, *))
    {
        BandyerSDK *sdkMock = [self makeSDKMock];
        BCPBandyerPlugin *sut = [self makeExposedSUTWithSDK:sdkMock initializePlugin:YES];
        NSURL *validConfigFileURL = [[NSBundle bundleForClass:self.class] URLForResource:@"valid_config" withExtension:@"plist"];
        __strong Class bundleClassMock = mockClass([NSBundle class]);
        NSBundle* bundleMock = mock([NSBundle class]);

        stubSingleton(bundleClassMock, mainBundle);
        [given([NSBundle mainBundle]) willReturn:bundleMock];
        [given([bundleMock URLForResource:@"BandyerConfig" withExtension:@"plist"]) willReturn:validConfigFileURL];

        CDVInvokedUrlCommand *command = [self makeCommandWithPayload:@{
            @"environment" : @"sandbox",
            @"appId" : @"appId"
        }];
        [sut initializeBandyer:command];

        HCArgumentCaptor *configCaptor = [HCArgumentCaptor new];
        [verify(sdkMock) initializeWithApplicationId:@"appId" config:(id)configCaptor];
        BDKConfig *config = configCaptor.value;
        assertThat(config.broadcastScreensharingConfiguration, notNilValue());
        assertThatBool(config.broadcastScreensharingConfiguration.isEnabled, isTrue());
        assertThat(config.broadcastScreensharingConfiguration.appGroupIdentifier, equalTo(@"group.com.bandyer.AppName"));
        assertThat(config.broadcastScreensharingConfiguration.broadcastExtensionBundleIdentifier, equalTo(@"com.bandyer.AppName.Extension"));
    } else
    {
        XCTSkip("This test cannot be run on iOS < 12");
    }
}

- (void)testInitializeShouldNotEnableBroadcastToolWhenTheConfigFileIsNotFound API_AVAILABLE(ios(12.0))
{
    if (@available(iOS 12.0, *))
    {
        BandyerSDK *sdkMock = [self makeSDKMock];
        BCPBandyerPlugin *sut = [self makeExposedSUTWithSDK:sdkMock initializePlugin:YES];
        NSURL *invalidURL = [NSURL URLWithString:@"https://www.bandyer.com"];
        __strong Class bundleClassMock = mockClass([NSBundle class]);
        NSBundle* bundleMock = mock([NSBundle class]);

        stubSingleton(bundleClassMock, mainBundle);
        [given([NSBundle mainBundle]) willReturn:bundleMock];
        [given([bundleMock URLForResource:@"BandyerConfig" withExtension:@"plist"]) willReturn:invalidURL];

        CDVInvokedUrlCommand *command = [self makeCommandWithPayload:@{
            @"environment" : @"sandbox",
            @"appId" : @"appId"
        }];
        [sut initializeBandyer:command];

        HCArgumentCaptor *configCaptor = [HCArgumentCaptor new];
        [verify(sdkMock) initializeWithApplicationId:@"appId" config:(id)configCaptor];
        BDKConfig *config = configCaptor.value;
        assertThat(config.broadcastScreensharingConfiguration, notNilValue());
        assertThatBool(config.broadcastScreensharingConfiguration.isEnabled, isFalse());
    } else
    {
        XCTSkip("This test cannot be run on iOS < 12");
    }
}

// MARK: Start

- (void)testStartReportsErrorWhenUserAliasIsMissingFromArguments
{
    BandyerSDK *sdkMock = [self makeSDKMock];
    BCPBandyerPlugin *sut = [self makeSUTWithSDK:sdkMock];

    CDVInvokedUrlCommand *command = [self makeCommand:@"callbackId" payload:@{
    }];
    [sut start:command];

    [verify(delegate) sendPluginResult:equalToResult([CDVPluginResult bcp_error]) callbackId:@"callbackId"];
}

- (void)testStartReportsErrorWhenUserAliasIsBlank
{
    BandyerSDK *sdkMock = [self makeSDKMock];
    BCPBandyerPlugin *sut = [self makeSUTWithSDK:sdkMock];

    CDVInvokedUrlCommand *command = [self makeCommand:@"callbackId" payload:@{
        @"userAlias" : [NSString string]
    }];
    [sut start:command];

    [verify(delegate) sendPluginResult:equalToResult([CDVPluginResult bcp_error]) callbackId:@"callbackId"];
}

- (void)testStartOpenUserSession
{
    id callClient = [self makeCallClientMock];
    id chatClient = [self makeChatClientMock];
    BandyerSDK *sdkMock = [self makeSDKWithCallClient:callClient chatClient:chatClient];
    BCPBandyerPlugin *sut = [self makeSUTWithSDK:sdkMock];

    CDVInvokedUrlCommand *command = [self makeCommandWithPayload:@{
        @"userAlias" : @"foobar"
    }];
    [sut start:command];

    [verify(sdkMock) openSessionWithUserId:@"foobar"];
}

- (void)testStartStartsCallAndChatClients
{
    id callClient = [self makeCallClientMock];
    id chatClient = [self makeChatClientMock];
    BandyerSDK *sdkMock = [self makeSDKWithCallClient:callClient chatClient:chatClient];
    BCPBandyerPlugin *sut = [self makeSUTWithSDK:sdkMock];

    CDVInvokedUrlCommand *command = [self makeCommandWithPayload:@{
        @"userAlias" : @"foobar"
    }];
    [sut start:command];

    [[verify(callClient) withMatcher:notNilValue() forArgument:1] addObserver:sut queue:anything()];
    [(id<BDKCallClient>)verify(callClient) start];
    [(id<BDKChatClient>)verify(chatClient) start];
}

- (void)testStartReportsSuccessOnSuccess
{
    BandyerSDK *sdkMock = [self makeSDKMock];
    BCPBandyerPlugin *sut = [self makeSUTWithSDK:sdkMock];

    CDVInvokedUrlCommand *command = [self makeCommand:@"commandId" payload:@{
        @"userAlias" : @"foobar"
    }];
    [sut start:command];

    [verify(delegate) sendPluginResult:equalToResult([CDVPluginResult bcp_success]) callbackId:@"commandId"];
}

// MARK: Stop

- (void)testStopStopsCallAndChatClients
{
    id callClient = [self makeCallClientMock];
    id chatClient = [self makeChatClientMock];
    BandyerSDK *sdkMock = [self makeSDKWithCallClient:callClient chatClient:chatClient];
    BCPBandyerPlugin *sut = [self makeSUTWithSDK:sdkMock];

    CDVInvokedUrlCommand *command = [self makeCommandWithPayload:@{}];
    [sut stop:command];

    [verify(callClient) removeObserver:sut];
    [verify(callClient) stop];
    [verify(chatClient) stop];
}

- (void)testStopReportsSuccessOnSuccess
{
    BandyerSDK *sdkMock = [self makeSDKMock];
    BCPBandyerPlugin *sut = [self makeSUTWithSDK:sdkMock];

    CDVInvokedUrlCommand *command = [self makeCommand:@"commandId" payload:@{}];
    [sut stop:command];

    [verify(delegate) sendPluginResult:equalToResult([CDVPluginResult bcp_success]) callbackId:@"commandId"];
}

- (void)testStopClosesUserSession
{
    id callClient = [self makeCallClientMock];
    id chatClient = [self makeChatClientMock];
    BandyerSDK *sdkMock = [self makeSDKWithCallClient:callClient chatClient:chatClient];
    BCPBandyerPlugin *sut = [self makeSUTWithSDK:sdkMock];

    CDVInvokedUrlCommand *command = [self makeCommandWithPayload:@{}];
    [sut stop:command];

    [verify(sdkMock) closeSession];
}

// MARK: Pause

- (void)testPausePausesCallAndChatClients
{
    id callClient = [self makeCallClientMock];
    id chatClient = [self makeChatClientMock];
    BandyerSDK *sdkMock = [self makeSDKWithCallClient:callClient chatClient:chatClient];
    BCPBandyerPlugin *sut = [self makeSUTWithSDK:sdkMock];

    CDVInvokedUrlCommand *command = [self makeCommandWithPayload:@{}];
    [sut pause:command];

    [verify(callClient) pause];
    [verify(chatClient) pause];
}

- (void)testPauseReportsSuccessOnSuccess
{
    BandyerSDK *sdkMock = [self makeSDKMock];
    BCPBandyerPlugin *sut = [self makeSUTWithSDK:sdkMock];

    CDVInvokedUrlCommand *command = [self makeCommand:@"commandId" payload:@{}];
    [sut pause:command];

    [verify(delegate) sendPluginResult:equalToResult([CDVPluginResult bcp_success]) callbackId:@"commandId"];
}

// MARK: Resume

- (void)testResumeResumesCallAndChatClients
{
    id callClient = [self makeCallClientMock];
    id chatClient = [self makeChatClientMock];
    BandyerSDK *sdkMock = [self makeSDKWithCallClient:callClient chatClient:chatClient];
    BCPBandyerPlugin *sut = [self makeSUTWithSDK:sdkMock];

    CDVInvokedUrlCommand *command = [self makeCommandWithPayload:@{}];
    [sut resume:command];

    [verify(callClient) resume];
    [verify(chatClient) resume];
}

- (void)testResumeReportsSuccessOnSuccess
{
    BandyerSDK *sdkMock = [self makeSDKMock];
    BCPBandyerPlugin *sut = [self makeSUTWithSDK:sdkMock];

    CDVInvokedUrlCommand *command = [self makeCommand:@"commandId" payload:@{}];
    [sut resume:command];

    [verify(delegate) sendPluginResult:equalToResult([CDVPluginResult bcp_success]) callbackId:@"commandId"];
}

// MARK: State

- (void)testStateReportsCallClientStateAsCommandResult
{
    id callClient = [self makeCallClientMock];
    id chatClient = [self makeChatClientMock];
    BandyerSDK *sdkMock = [self makeSDKWithCallClient:callClient chatClient:chatClient];
    BCPBandyerPlugin *sut = [self makeSUTWithSDK:sdkMock];

    [given([callClient state]) willReturnInteger:BDKCallClientStateRunning];
    CDVInvokedUrlCommand *command = [self makeCommand:@"commandId" payload:@{}];
    [sut state:command];

    [verify(delegate) sendPluginResult:equalToResult([CDVPluginResult bcp_successWithMessageAsString:@"running"]) callbackId:@"commandId"];
}

// MARK: Start call

- (void)testStartCallReportsErrorWhenArgumentsArrayDoesNotContainEitherCalleeArrayOrJoinURL
{
    BandyerSDK *sdkMock = [self makeSDKMock];
    BCPBandyerPlugin *sut = [self makeSUTWithSDK:sdkMock];

    CDVInvokedUrlCommand *command = [self makeCommand:@"commandId" payload:@{}];
    [sut startCall:command];

    [verify(delegate) sendPluginResult:equalToResult([CDVPluginResult bcp_error]) callbackId:@"commandId"];
}

- (void)testStartCallReportsSuccessOnSuccess
{
    BandyerSDK *sdkMock = [self makeSDKMock];
    BCPBandyerPlugin *sut = [self makeExposedSUTWithSDK:sdkMock initializePlugin:YES];

    CDVInvokedUrlCommand *command = [self makeCommand:@"commandId"
                                              payload:@{
                                                  @"callee" : @[@"foobar"],
                                                  @"callType" : @"audio",
                                                  @"recording" : @YES
                                              }];
    [sut startCall:command];

    [verify(delegate) sendPluginResult:equalToResult([CDVPluginResult bcp_success]) callbackId:@"commandId"];
}

- (void)testStartCallTellsUICoordinatorToHandleMakeCallIntentWhenArgumentsProvideOutgoingCallInformation
{
    BandyerSDK *sdkMock = [self makeSDKMock];
    BCPBandyerPlugin *sut = [self makeExposedSUTWithSDK:sdkMock initializePlugin:YES];

    CDVInvokedUrlCommand *command = [self makeCommand:@"commandId"
                                              payload:@{
                                                  @"callee" : @[@"foobar"],
                                                  @"callType" : @"audio",
                                                  @"recording" : @YES
                                              }];
    [sut startCall:command];

    HCArgumentCaptor *intentCaptor = [HCArgumentCaptor new];
    [verify(sut.coordinator) handleIntent:(id)intentCaptor];
    BDKStartOutgoingCallIntent *intent = intentCaptor.value;
    assertThat(intent.callees, equalTo(@[@"foobar"]));
    assertThatInteger(intent.options.callType, equalToInteger(BDKCallTypeAudioOnly));
    assertThatBool(intent.options.isRecorded, isTrue());
    assertThatUnsignedInteger(intent.options.maximumDuration, equalToUnsignedInteger(0));
}

- (void)testStartCallTellsUICoordinatorToHandleJoinURLIntentWhenArgumentsProvideJoinURL
{
    BandyerSDK *sdkMock = [self makeSDKMock];
    BCPBandyerPlugin *sut = [self makeExposedSUTWithSDK:sdkMock initializePlugin:YES];

    CDVInvokedUrlCommand *command = [self makeCommand:@"commandId"
                                              payload:@{
                                                  @"joinUrl" : @"https://www.bandyer.com/"
                                              }];
    [sut startCall:command];

    HCArgumentCaptor *intentCaptor = [HCArgumentCaptor new];
    [verify(sut.coordinator) handleIntent:(id)intentCaptor];
    BDKJoinURLIntent *intent = intentCaptor.value;
    assertThat([intent.url absoluteString], equalTo(@"https://www.bandyer.com/"));
}

// MARK: Start chat

- (void)testStartChatReportsErrorWhenArgumentsArrayDoesNotContainUserAlias
{
    BandyerSDK *sdkMock = [self makeSDKMock];
    BCPBandyerPlugin *sut = [self makeSUTWithSDK:sdkMock initializePlugin:YES];

    CDVInvokedUrlCommand *command = [self makeCommand:@"commandId"
                                              payload:@{}];
    [sut startChat:command];

    [verify(delegate) sendPluginResult:equalToResult([CDVPluginResult bcp_error]) callbackId:@"commandId"];
}

- (void)testStartChatTellsUICoordinatorToHandleOpenChatIntent
{
    BandyerSDK *sdkMock = [self makeSDKMock];
    BCPBandyerPlugin *sut = [self makeExposedSUTWithSDK:sdkMock initializePlugin:YES];

    CDVInvokedUrlCommand *command = [self makeCommand:@"commandId"
                                              payload:@{
                                                  @"userAlias" : @"foobar"
                                              }];
    [sut startChat:command];

    [verify(sut.coordinator) handleIntent:instanceOf(BDKOpenChatIntent.class)];
}

- (void)testStartChatReportsSuccessOnSuccess
{
    BandyerSDK *sdkMock = [self makeSDKMock];
    BCPBandyerPlugin *sut = [self makeExposedSUTWithSDK:sdkMock initializePlugin:YES];

    CDVInvokedUrlCommand *command = [self makeCommand:@"commandId"
                                              payload:@{
                                                  @"userAlias" : @"foobar"
                                              }];
    [sut startChat:command];

    [verify(delegate) sendPluginResult:equalToResult([CDVPluginResult bcp_success]) callbackId:@"commandId"];
}

// MARK: Handle push

- (void)testHandlePushNotificationPayloadReportsError
{
    BandyerSDK *sdkMock = [self makeSDKMock];
    BCPBandyerPlugin *sut = [self makeSUTWithSDK:sdkMock];

    CDVInvokedUrlCommand *command = [self makeCommand:@"commandId" payload:@{}];
    [sut handlePushNotificationPayload:command];

    [verify(delegate) sendPluginResult:equalToResult([CDVPluginResult bcp_error]) callbackId:@"commandId"];
}

// MARK: Add user details

- (void)testAddUserDetailsAddsUserDetailsToCache
{
    BandyerSDK *sdkMock = [self makeSDKMock];
    BCPBandyerPlugin *sut = [self makeSUTWithSDK:sdkMock initializePlugin:YES];

    CDVInvokedUrlCommand *command = [self makeCommand:@"commandId" payload:@{
        @"details" : @[@{@"userAlias" : @"foobar"}]
    }];
    [sut addUsersDetails:command];

    assertThat([sut.usersCache itemForKey:@"foobar"], notNilValue());
}

- (void)testAddUserDetailsReportsSuccessOnSuccess
{
    BandyerSDK *sdkMock = [self makeSDKMock];
    BCPBandyerPlugin *sut = [self makeSUTWithSDK:sdkMock initializePlugin:YES];

    CDVInvokedUrlCommand *command = [self makeCommand:@"commandId" payload:@{
        @"details" : @[@{@"userAlias" : @"foobar"}]
    }];
    [sut addUsersDetails:command];

    [verify(delegate) sendPluginResult:equalToResult([CDVPluginResult bcp_success]) callbackId:@"commandId"];
}

- (void)testAddUserDetailsReportsErrorWhenDetailsArrayIsMissingFromArgumentsArray
{
    BandyerSDK *sdkMock = [self makeSDKMock];
    BCPBandyerPlugin *sut = [self makeSUTWithSDK:sdkMock initializePlugin:YES];

    CDVInvokedUrlCommand *command = [self makeCommand:@"commandId" payload:@{
    }];
    [sut addUsersDetails:command];

    [verify(delegate) sendPluginResult:equalToResult([CDVPluginResult bcp_error]) callbackId:@"commandId"];
}

// MARK: Remove user details

- (void)testRemoveUsersDetailsReportsSuccessOnSuccess
{
    BandyerSDK *sdkMock = [self makeSDKMock];
    BCPBandyerPlugin *sut = [self makeSUTWithSDK:sdkMock initializePlugin:YES];

    CDVInvokedUrlCommand *addCommand = [self makeCommand:@"commandId" payload:@{
        @"details" : @[@{@"userAlias" : @"foobar"}]
    }];
    [sut addUsersDetails:addCommand];
    CDVInvokedUrlCommand *removeCommand = [self makeCommand:@"commandId" payload:@{}];
    [sut removeUsersDetails:removeCommand];

    [verifyCount(delegate, times(2)) sendPluginResult:equalToResult([CDVPluginResult bcp_success]) callbackId:@"commandId"];
}

// MARK: Set User Details Format

- (void)testReportsSuccessWhenSettingUserDetailsFormatIfCommandArgumentContainsTheExpectedData
{
    BCPBandyerPlugin *sut = [self makeSUTInitializePlugin:YES];
    NSDictionary *payload = [self makeSetUserDetailsFormatCommandPayload:@"${firstName} ${lastName}"];

    CDVInvokedUrlCommand * command = [self makeCommand:@"callbackId" payload:payload];
    [sut setUserDetailsFormat:command];

    [verify(delegate) sendPluginResult:equalToResult([CDVPluginResult bcp_success]) callbackId:@"callbackId"];
}

- (void)testSetsUserDetailsFormatOnUserInterfaceCoordinator
{
    BCPBandyerPlugin *sut = [self makeSUTInitializePlugin:YES];
    NSDictionary *payload = [self makeSetUserDetailsFormatCommandPayload:@"${firstName} ${lastName}"];

    CDVInvokedUrlCommand * command = [self makeCommand:@"callbackId" payload:payload];
    [sut setUserDetailsFormat:command];

    assertThat(sut.coordinator.userDetailsFormat, equalTo(@"${firstName} ${lastName}"));
}

- (void)testReportsFailureWhenSettingUserDetailsFormatIfFormatStringIsMissing
{
    BCPBandyerPlugin *sut = [self makeSUTInitializePlugin:YES];

    CDVInvokedUrlCommand * command = [self makeCommand:@"callbackId" payload:@{}];
    [sut setUserDetailsFormat:command];

    [verify(delegate) sendPluginResult:equalToResult([CDVPluginResult bcp_error]) callbackId:@"callbackId"];
}

- (void)testReportsFailureWhenSettingUserDetailsFormatIfFormatIsNotAString
{
    BCPBandyerPlugin *sut = [self makeSUTInitializePlugin:YES];

    NSDictionary *payload = [self makeSetUserDetailsFormatCommandPayload:@1];
    CDVInvokedUrlCommand * command = [self makeCommand:@"callbackId" payload:payload];
    [sut setUserDetailsFormat:command];

    [verify(delegate) sendPluginResult:equalToResult([CDVPluginResult bcp_error]) callbackId:@"callbackId"];
}

// MARK: Helpers

- (CDVInvokedUrlCommand *)makeCommand:(NSString *)callbackId payload:(NSDictionary *)payload
{
    NSMutableArray *args = [NSMutableArray arrayWithObject:payload];
    return [CDVInvokedUrlCommand commandFromJson:@[callbackId, @"class", @"method", args]];
}

- (CDVInvokedUrlCommand *)makeCommandWithPayload:(NSDictionary *)payload
{
    return [self makeCommand:@"callbackId" payload:payload];
}

- (id<BDKCallClient>)makeCallClientMock
{
    return mockProtocol(@protocol(BDKCallClient));
}

- (id<BDKChatClient>)makeChatClientMock
{
    return mockProtocol(@protocol(BDKChatClient));
}

- (BandyerSDK *)makeSDKMock
{
    return [self makeSDKWithCallClient:[self makeCallClientMock] chatClient:[self makeChatClientMock]];
}

- (BandyerSDK *)makeSDKWithCallClient:(id<BDKCallClient>)callClient chatClient:(id<BDKChatClient>)chatClient
{
    BandyerSDK *m = mock(BandyerSDK.class);
    [given([m callClient]) willReturn:callClient];
    [given([m chatClient]) willReturn:chatClient];
    return m;
}

- (BCPBandyerPlugin *)makeSUT
{
    return [self makeSUTInitializePlugin:NO];
}

- (BCPBandyerPlugin *)makeSUTInitializePlugin:(BOOL)initializePlugin
{
    return [self makeSUTWithSDK:mock(BandyerSDK.class) initializePlugin:initializePlugin];
}

- (BCPBandyerPlugin *)makeSUTWithSDK:(BandyerSDK *)sdk
{
    return [self makeSUTWithSDK:sdk initializePlugin:NO];
}

- (BCPBandyerPlugin *)makeSUTWithSDK:(BandyerSDK *)sdk initializePlugin:(BOOL)initializePlugin
{
    return [self makeSUTWithSDK:sdk class:BCPBandyerPlugin.class initializePlugin:initializePlugin];
}

- (BCPBandyerPlugin *)makeExposedSUTWithSDK:(BandyerSDK *)sdk
{
    return [self makeExposedSUTWithSDK:sdk initializePlugin:NO];
}

- (BCPBandyerPlugin *)makeExposedSUTWithSDK:(BandyerSDK *)sdk initializePlugin:(BOOL)initializePlugin
{
    return [self makeSUTWithSDK:sdk class:BCPBandyerPluginExposed.class initializePlugin:initializePlugin];
}

- (BCPBandyerPlugin *)makeSUTWithSDK:(BandyerSDK *)sdk class:(Class)class initializePlugin:(BOOL)initializePlugin
{
    BCPBandyerPlugin *sut = [[class alloc] initWithBandyerSDK:sdk];
    sut.commandDelegate = delegate;
    sut.viewController = viewController;

    if (initializePlugin)
        [sut pluginInitialize];

    return sut;
}

- (NSDictionary *)makeSetUserDetailsFormatCommandPayload:(id)format
{
    return @{
        @"format" : format
    };
}

@end
