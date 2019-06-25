//
// Copyright © 2019 Bandyer S.r.l. All Rights Reserved.
// See LICENSE for licensing information
//

#import <Foundation/Foundation.h>
#import <Cordova/CDV.h>

@class BCPCallClientEventEmitter;

NS_ASSUME_NONNULL_BEGIN

@interface BCPBandyerManager : NSObject

@property (nonatomic, weak, nullable) UIViewController *viewController;
@property (nonatomic, weak, nullable) id <CDVWebViewEngineProtocol> webViewEngine;
@property (nonatomic, strong, nullable) BCPCallClientEventEmitter *notifier;

- (BOOL)configureBandyerWithParams:(NSDictionary *)params;
- (BOOL)startCallClientWithParams:(NSDictionary *)params;
- (void)pauseCallClient;
- (void)resumeCallClient;
- (void)stopCallClient;
- (nullable NSString *)callClientState;
- (BOOL)handleNotificationPayloadWithParams:(NSDictionary *)params;
- (BOOL)makeCallWithParams:(NSDictionary *)params;
- (void)addUsersDetails:(NSDictionary *)params;
- (void)removeUsersDetails;

+ (instancetype)shared;

@end

NS_ASSUME_NONNULL_END
