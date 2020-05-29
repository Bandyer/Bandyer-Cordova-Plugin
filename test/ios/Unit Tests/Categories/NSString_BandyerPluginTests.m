// Copyright © 2020 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information

#import <XCTest/XCTest.h>
#import <OCHamcrest/OCHamcrest.h>

#import "BCPTestCase.h"

#import "NSString+BandyerPlugin.h"

@interface NSString_BandyerPluginTests : BCPTestCase

@end

@implementation NSString_BandyerPluginTests

- (void)testReturnsSandboxEnvironment
{
    assertThat([[@"sandbox" toBDKEnvironment] description], equalTo([BDKEnvironment.sandbox description]));
}

- (void)testReturnsProductionEnvironment
{
    assertThat([[@"production" toBDKEnvironment] description], equalTo([BDKEnvironment.production description]));
}

- (void)testReturnsNilForUnknownEnvironment
{
    assertThat([@"unknown" toBDKEnvironment], nilValue());
}

- (void)testReturnsAudioOnlyCallType
{
    assertThatInteger([@"audio" toBDKCallType], equalToInteger(BDKCallTypeAudioOnly));
}

- (void)testReturnsAudioUpgradableCallType
{
    assertThatInteger([@"audioUpgradable" toBDKCallType], equalToInteger(BDKCallTypeAudioUpgradable));
}

- (void)testReturnsAudioVideoCallTypeForAnyString
{
    assertThatInteger([@"foobar" toBDKCallType], equalToInteger(BDKCallTypeAudioVideo));
}

@end
