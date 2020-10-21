// Copyright © 2019 Bandyer S.r.l. All Rights Reserved.
// See LICENSE for licensing information

#import <Cordova/CDV.h>

NS_ASSUME_NONNULL_BEGIN

@class BCPUsersDetailsCache;
@class BCPUserInterfaceCoordinator;
@class BandyerSDK;

@interface BCPBandyerPlugin: CDVPlugin

@property (nonatomic, strong, readonly, nullable) BCPUsersDetailsCache *usersCache;
@property (nonatomic, strong, readonly, nullable) BCPUserInterfaceCoordinator *coordinator;

- (instancetype)init;
- (instancetype)initWithBandyerSDK:(BandyerSDK *)bandyerSDK NS_DESIGNATED_INITIALIZER;

- (void)initializeBandyer:(CDVInvokedUrlCommand *)command;
- (void)start:(CDVInvokedUrlCommand *)command;
- (void)stop:(CDVInvokedUrlCommand *)command;
- (void)pause:(CDVInvokedUrlCommand *)command;
- (void)resume:(CDVInvokedUrlCommand *)command;
- (void)state:(CDVInvokedUrlCommand *)command;
- (void)startCall:(CDVInvokedUrlCommand *)command;
- (void)startChat:(CDVInvokedUrlCommand *)command;
- (void)handlePushNotificationPayload:(CDVInvokedUrlCommand *)command;
- (void)addUsersDetails:(CDVInvokedUrlCommand *)command;
- (void)removeUsersDetails:(CDVInvokedUrlCommand *)command;
- (void)setUserDetailsFormat:(CDVInvokedUrlCommand *)command;

@end

NS_ASSUME_NONNULL_END
