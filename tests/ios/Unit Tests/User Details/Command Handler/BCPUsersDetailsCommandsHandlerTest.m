//
// Copyright © 2019 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information
//

#import <OCHamcrest/OCHamcrest.h>
#import <OCMockito/OCMockito.h>
#import <Cordova/CDVPluginResult.h>

#import "BCPTestCase.h"
#import "BCPTestingMacros.h"
#import "BCPExceptionsMatcher.h"
#import "BCPPluginResultMatcher.h"

#import "BCPUsersDetailsCommandsHandler.h"
#import "BCPUsersDetailsCache.h"
#import "BCPConstants.h"
#import "CDVPluginResult+BCPFactoryMethods.h"

@interface BCPUsersDetailsCommandsHandlerTest : BCPTestCase

@end

@implementation BCPUsersDetailsCommandsHandlerTest
{
    BCPUsersDetailsCache *cache;
    id <CDVCommandDelegate> delegate;
    BCPUsersDetailsCommandsHandler *sut;
}

- (void)setUp
{
    [super setUp];

    cache = [BCPUsersDetailsCache new];
    delegate = mockProtocol(@protocol(CDVCommandDelegate));
    sut = [[BCPUsersDetailsCommandsHandler alloc] initWithCommandDelegate:delegate cache:cache];
}

__SUPPRESS_WARNINGS_FOR_TEST_BEGIN

- (void)testThrowsInvalidArgumentExceptionWhenMandatoryArgumentIsMissingDuringInitialization
{
    assertThat(^{[[BCPUsersDetailsCommandsHandler alloc] initWithCommandDelegate:nil cache:cache];}, throwsInvalidArgumentException());
    assertThat(^{[[BCPUsersDetailsCommandsHandler alloc] initWithCommandDelegate:delegate cache:nil];}, throwsInvalidArgumentException());
}

- (void)testAddsUsersDetailsToCache
{
    NSArray *args = @[
        @{
            kBCPUserDetailsKey: @[
            @{
                @"userAlias": @"alias1", @"firstName": @"name", @"lastName": @"last", @"email": @"email@bandyer.com",
            }
        ]
        }
    ];

    CDVInvokedUrlCommand *command = [self makeCommandWithArgs:args];
    [sut addUsersDetails:command];

    BDKUserInfoDisplayItem *item = [cache itemForKey:@"alias1"];
    assertThat(item, notNilValue());
    assertThat(item.firstName, equalTo(@"name"));
    assertThat(item.lastName, equalTo(@"last"));
    assertThat(item.email, equalTo(@"email@bandyer.com"));
}

- (void)testReportsSuccessWhenUserDetailsAreAddedToCache
{
    NSArray *args = @[
        @{
            kBCPUserDetailsKey: @[
            @{
                @"userAlias": @"alias1", @"firstName": @"name", @"lastName": @"last", @"email": @"email@bandyer.com",
            }
        ]
        }
    ];

    CDVInvokedUrlCommand *command = [self makeCommandWithArgs:args];
    [sut addUsersDetails:command];

    [verify(delegate) sendPluginResult:equalToResult([CDVPluginResult bcp_success]) callbackId:command.callbackId];
}

- (void)testReportsErrorWhenUnexpectedArgumentListIsReceived
{
    NSArray *args = @[@{}];

    CDVInvokedUrlCommand *command = [self makeCommandWithArgs:args];
    [sut addUsersDetails:command];

    [verify(delegate) sendPluginResult:equalToResult([CDVPluginResult bcp_error]) callbackId:command.callbackId];
}

- (void)testReportsErrorWhenUserDetailsDictionaryDoesNotContainAnArray
{
    NSArray *args = @[
        @{
            kBCPUserDetailsKey: @{
            @"foo": @"bar"
        }
        }
    ];

    CDVInvokedUrlCommand *command = [self makeCommandWithArgs:args];
    [sut addUsersDetails:command];

    [verify(delegate) sendPluginResult:equalToResult([CDVPluginResult bcp_error]) callbackId:command.callbackId];
}

- (void)testPurgesCache
{
    NSArray *args = @[
        @{
            kBCPUserDetailsKey: @[
            @{
                @"userAlias": @"alias1", @"firstName": @"name", @"lastName": @"last", @"email": @"email@bandyer.com",
            }
        ]
        }
    ];

    CDVInvokedUrlCommand *addCommand = [self makeCommandWithArgs:args];
    [sut addUsersDetails:addCommand];
    assertThat([cache itemForKey:@"alias1"], notNilValue());

    CDVInvokedUrlCommand *removeCommand = [self makeCommandWithArgs:nil];
    [sut purge:removeCommand];
    assertThat([cache itemForKey:@"alias1"], nilValue());
}

- (void)testReportsSuccessAfterPurgingCache
{
    NSArray *args = @[
        @{
            kBCPUserDetailsKey: @[
            @{
                @"userAlias": @"alias1", @"firstName": @"name", @"lastName": @"last", @"email": @"email@bandyer.com",
            }
        ]
        }
    ];
    CDVInvokedUrlCommand *addCommand = [self makeCommandWithArgs:args];
    [sut addUsersDetails:addCommand];

    CDVInvokedUrlCommand *removeCommand = [self makeCommandWithArgs:nil];
    [sut purge:removeCommand];

    [verify(delegate) sendPluginResult:equalToResult([CDVPluginResult bcp_success]) callbackId:removeCommand.callbackId];
}

// MARK: Helpers

- (CDVInvokedUrlCommand *)makeCommandWithArgs:(nullable NSArray *)args
{
    NSString *callbackId = [NSString stringWithFormat:@"callback_id#%d", arc4random()];
    return [[CDVInvokedUrlCommand alloc] initWithArguments:args callbackId:callbackId className:@"class_name" methodName:@"method_name"];
}

__SUPPRESS_WARNINGS_FOR_TEST_END

@end
