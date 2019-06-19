//
// Copyright © 2019 Bandyer S.r.l. All Rights Reserved.
// See LICENSE for licensing information
//

#import <Cordova/CDV.h>
#import "BandyerHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface BCPBandyerPlugin: CDVPlugin

- (void)initializeBandyer:(CDVInvokedUrlCommand *)command;
- (void)addCallClient:(CDVInvokedUrlCommand *)command;
- (void)removeCallClient:(CDVInvokedUrlCommand *)command;
- (void)start:(CDVInvokedUrlCommand *)command;
- (void)stop:(CDVInvokedUrlCommand *)command;
- (void)pause:(CDVInvokedUrlCommand *)command;
- (void)resume:(CDVInvokedUrlCommand *)command;
- (void)state:(CDVInvokedUrlCommand *)command;
- (void)makeCall:(CDVInvokedUrlCommand *)command;
- (void)handlePushNotificationPayload:(CDVInvokedUrlCommand *)command;
- (void)createUserInfoFetch:(CDVInvokedUrlCommand *)command;
- (void)clearCache:(CDVInvokedUrlCommand *)command;

@end

NS_ASSUME_NONNULL_END