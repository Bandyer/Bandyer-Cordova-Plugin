// Copyright © 2021 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information

#import <XCTest/XCTest.h>
#import <OCHamcrest/OCHamcrest.h>
#import <Bandyer/BDKBroadcastScreensharingToolConfiguration.h>

#import "BCPiOS12AndAboveTestCase.h"
#import "BCPBroadcastConfigurationPlistReader.h"
#import "BCPError.h"

API_AVAILABLE(ios(12.0))
@interface BCPBroadcastConfigurationPlistReaderTests : BCPiOS12AndAboveTestCase

@end

@implementation BCPBroadcastConfigurationPlistReaderTests

- (void)testReadShouldReturnAnErrorInOutParameterWhenURLIsNil
{
    BCPBroadcastConfigurationPlistReader *sut = [self makeSUT];

    NSURL *fileURL = nil;
    NSError *error = nil;
    BDKBroadcastScreensharingToolConfiguration *config = [sut read:fileURL error:&error];

    assertThat(config, nilValue());
    assertThat(error, equalTo([NSError errorWithDomain:kBCPErrorDomain code:BCPBroadcastConfigurationReaderFileNotFoundError userInfo:nil]));
}

- (void)testReadShouldReturnAnErrorWhenTheURLProvidedIsNotAPlistFile
{
    BCPBroadcastConfigurationPlistReader *sut = [self makeSUT];

    NSURL *fileURL = [[NSBundle bundleForClass:self.class] URLForResource:@"text" withExtension:@"txt"];
    NSError *error = nil;
    BDKBroadcastScreensharingToolConfiguration *config = [sut read:fileURL error:&error];

    assertThat(config, nilValue());
    assertThat(error, equalTo([NSError errorWithDomain:kBCPErrorDomain code:BCPBroadcastConfigurationReaderNotAPlistFileError userInfo:nil]));
}

- (void)testReadShouldReturnAnErrorWhenTheURLProvidedIsNotAFileURL
{
    BCPBroadcastConfigurationPlistReader *sut = [self makeSUT];

    NSURL *url = [NSURL URLWithString:@"https://www.bandyer.com"];
    NSError *error = nil;
    BDKBroadcastScreensharingToolConfiguration *config = [sut read:url error:&error];

    assertThat(config, nilValue());
    assertThat(error, equalTo([NSError errorWithDomain:kBCPErrorDomain code:BCPBroadcastConfigurationReaderNotAFileError userInfo:nil]));
}

- (void)testReadShouldReturnAnEnabledBroadcastConfigurationObjectSetupWithTheValuesFoundInThePlistFileWhenAValidConfigurationPlistFileURLIsProvided
{
    BCPBroadcastConfigurationPlistReader *sut = [self makeSUT];

    NSURL *fileURL = [[NSBundle bundleForClass:self.class] URLForResource:@"valid_config" withExtension:@"plist"];
    NSError *error = nil;
    BDKBroadcastScreensharingToolConfiguration *config = [sut read:fileURL error:&error];

    assertThat(error, nilValue());
    assertThat(config, notNilValue());
    assertThatBool(config.isEnabled, isTrue());
    assertThat(config.appGroupIdentifier, equalTo(@"group.com.bandyer.AppName"));
    assertThat(config.broadcastExtensionBundleIdentifier, equalTo(@"com.bandyer.AppName.Extension"));
}

- (void)testReadShouldReturnAnErrorWhenThePlistFileDoesNotContainAnAppGroupIdentifier
{
    BCPBroadcastConfigurationPlistReader *sut = [self makeSUT];

    NSURL *fileURL = [[NSBundle bundleForClass:self.class] URLForResource:@"missing_group" withExtension:@"plist"];
    NSError *error = nil;
    BDKBroadcastScreensharingToolConfiguration *config = [sut read:fileURL error:&error];

    assertThat(config, nilValue());
    assertThat(error, equalTo([NSError errorWithDomain:kBCPErrorDomain code:BCPBroadcastConfigurationReaderAppGroupMissingError userInfo:nil]));
}

- (void)testReadShouldReturnAnErrorWhenThePlistFileDoesNotContainTheExtensionBundleIdentifier
{
    BCPBroadcastConfigurationPlistReader *sut = [self makeSUT];

    NSURL *fileURL = [[NSBundle bundleForClass:self.class] URLForResource:@"missing_extension_identifier" withExtension:@"plist"];
    NSError *error = nil;
    BDKBroadcastScreensharingToolConfiguration *config = [sut read:fileURL error:&error];

    assertThat(config, nilValue());
    assertThat(error, equalTo([NSError errorWithDomain:kBCPErrorDomain code:BCPBroadcastConfigurationReaderExtensionBundleIdMissingError userInfo:nil]));
}

- (void)testReadShouldReturnAnErrorWhenThePlistFileDoesNotContainBroadcastKey
{
    BCPBroadcastConfigurationPlistReader *sut = [self makeSUT];

    NSURL *fileURL = [[NSBundle bundleForClass:self.class] URLForResource:@"missing_broadcast" withExtension:@"plist"];
    NSError *error = nil;
    BDKBroadcastScreensharingToolConfiguration *config = [sut read:fileURL error:&error];

    assertThat(config, nilValue());
    assertThat(error, equalTo([NSError errorWithDomain:kBCPErrorDomain code:BCPBroadcastConfigurationReaderAppGroupMissingError userInfo:nil]));
}

- (void)testReadShouldReturnAnErrorWhenThePlistContainsANonStringValueAsTheAppGroupIdentifier
{
    BCPBroadcastConfigurationPlistReader *sut = [self makeSUT];

    NSURL *fileURL = [[NSBundle bundleForClass:self.class] URLForResource:@"mismatched_group" withExtension:@"plist"];
    NSError *error = nil;
    BDKBroadcastScreensharingToolConfiguration *config = [sut read:fileURL error:&error];

    assertThat(config, nilValue());
    assertThat(error, equalTo([NSError errorWithDomain:kBCPErrorDomain code:BCPBroadcastConfigurationReaderAppGroupMissingError userInfo:nil]));
}

- (void)testReadShouldReturnAnErrorWhenThePlistContainsANonStringValueAsTheExtensionBundleId
{
    BCPBroadcastConfigurationPlistReader *sut = [self makeSUT];

    NSURL *fileURL = [[NSBundle bundleForClass:self.class] URLForResource:@"mismatched_extension_identifier" withExtension:@"plist"];
    NSError *error = nil;
    BDKBroadcastScreensharingToolConfiguration *config = [sut read:fileURL error:&error];

    assertThat(config, nilValue());
    assertThat(error, equalTo([NSError errorWithDomain:kBCPErrorDomain code:BCPBroadcastConfigurationReaderExtensionBundleIdMissingError userInfo:nil]));
}

- (void)testReadShouldReturnAnErrorWhenThePlistContainsAnEmptyStringValueAsTheAppGroupIdentifier
{
    BCPBroadcastConfigurationPlistReader *sut = [self makeSUT];

    NSURL *fileURL = [[NSBundle bundleForClass:self.class] URLForResource:@"empty_group" withExtension:@"plist"];
    NSError *error = nil;
    BDKBroadcastScreensharingToolConfiguration *config = [sut read:fileURL error:&error];

    assertThat(config, nilValue());
    assertThat(error, equalTo([NSError errorWithDomain:kBCPErrorDomain code:BCPBroadcastConfigurationReaderAppGroupMissingError userInfo:nil]));
}

- (void)testReadShouldReturnAnErrorWhenThePlistContainsAnEmptyStringValueAsTheExtensionBundleId
{
    BCPBroadcastConfigurationPlistReader *sut = [self makeSUT];

    NSURL *fileURL = [[NSBundle bundleForClass:self.class] URLForResource:@"empty_extension_identifier" withExtension:@"plist"];
    NSError *error = nil;
    BDKBroadcastScreensharingToolConfiguration *config = [sut read:fileURL error:&error];

    assertThat(config, nilValue());
    assertThat(error, equalTo([NSError errorWithDomain:kBCPErrorDomain code:BCPBroadcastConfigurationReaderExtensionBundleIdMissingError userInfo:nil]));
}

- (void)testReadShouldReturnAnErrorWhenThePlistContainsNOT_AVAILABLEStringValueAsTheAppGroupIdentifier
{
    BCPBroadcastConfigurationPlistReader *sut = [self makeSUT];

    NSURL *fileURL = [[NSBundle bundleForClass:self.class] URLForResource:@"not_available_group_identifier" withExtension:@"plist"];
    NSError *error = nil;
    BDKBroadcastScreensharingToolConfiguration *config = [sut read:fileURL error:&error];

    assertThat(config, nilValue());
    assertThat(error, equalTo([NSError errorWithDomain:kBCPErrorDomain code:BCPBroadcastConfigurationReaderAppGroupMissingError userInfo:nil]));
}

- (void)testReadShouldReturnAnErrorWhenThePlistContainsNOT_AVAILABLEStringValueAsExtensionIdentifier
{
    BCPBroadcastConfigurationPlistReader *sut = [self makeSUT];

    NSURL *fileURL = [[NSBundle bundleForClass:self.class] URLForResource:@"not_available_extension_identifier" withExtension:@"plist"];
    NSError *error = nil;
    BDKBroadcastScreensharingToolConfiguration *config = [sut read:fileURL error:&error];

    assertThat(config, nilValue());
    assertThat(error, equalTo([NSError errorWithDomain:kBCPErrorDomain code:BCPBroadcastConfigurationReaderExtensionBundleIdMissingError userInfo:nil]));
}

#pragma mark - Helpers

- (BCPBroadcastConfigurationPlistReader *)makeSUT
{
    return [[BCPBroadcastConfigurationPlistReader alloc] init];
}

@end
