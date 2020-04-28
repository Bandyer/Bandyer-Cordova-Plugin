// Copyright © 2020 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information

#import <XCTest/XCTest.h>
#import <Cordova/CDV.h>
#import <OCMockito/OCMockito.h>
#import <OCHamcrest/OCHamcrest.h>

#import "BCPTestCase.h"
#import "BCPBandyerPlugin.h"

#import "CDVPluginResult+BCPFactoryMethods.h"

static inline id equalToResult(CDVPluginResult *result)
{
    return HC_allOf(
             HC_hasProperty(@"status", HC_equalTo(result.status)),
             HC_hasProperty(@"message", HC_equalTo(result.message)),
             HC_hasProperty(@"keepCallback", HC_equalTo(result.keepCallback)),
             nil);
}

@interface BCPBandyerPluginTests : BCPTestCase

@end

@implementation BCPBandyerPluginTests
{
    BCPBandyerPlugin *sut;
    id<CDVCommandDelegate> delegate;
}

- (void)setUp
{
    [super setUp];

    delegate = mockProtocol(@protocol(CDVCommandDelegate));
    sut = [[BCPBandyerPlugin alloc] init];
    sut.commandDelegate = delegate;
}

- (void)testReportsSuccessWhenSettingUserDetailsFormatIfCommandArgumentContainsTheExpectedData
{
    NSDictionary *payload = @{
        @"default" : @"${firstName} ${lastName}"
    };
    CDVInvokedUrlCommand * command = [self makeCommand:@"callbackId" payload:payload];

    [sut setUserDetailsFormat:command];

    [verify(delegate) sendPluginResult:equalToResult([CDVPluginResult bcp_success]) callbackId:@"callbackId"];
}

- (void)testStoresFormatForLaterUseWhenSettingUserDetailsFormat
{
    NSDictionary *payload = @{
        @"default" : @"${firstName} ${lastName}"
    };
    CDVInvokedUrlCommand * command = [self makeCommand:@"callbackId" payload:payload];

    [sut setUserDetailsFormat:command];

    assertThat(sut.detailsFormat, equalTo(@"${firstName} ${lastName}"));
}

- (void)testReportsFailureWhenSettingUserDetailsFormatIfFormatStringIsMissing {
    CDVInvokedUrlCommand * command = [self makeCommand:@"callbackId" payload:@{}];

    [sut setUserDetailsFormat:command];

    [verify(delegate) sendPluginResult:equalToResult([CDVPluginResult bcp_error]) callbackId:@"callbackId"];
}

- (void)testReportsFailureWhenSettingUserDetailsFormatIfFormatIsNotAString
{
    NSDictionary *payload = @{
        @"default" : @1
    };
    CDVInvokedUrlCommand * command = [self makeCommand:@"callbackId" payload:payload];

    [sut setUserDetailsFormat:command];

    [verify(delegate) sendPluginResult:equalToResult([CDVPluginResult bcp_error]) callbackId:@"callbackId"];
}

// MARK: Helpers

- (CDVInvokedUrlCommand *)makeCommand:(NSString *)callbackId payload:(NSDictionary *)payload
{
    NSMutableArray *args = [NSMutableArray arrayWithObject:payload];
    return [CDVInvokedUrlCommand commandFromJson:@[@"callbackId", @"class", @"method", args]];
}

@end
