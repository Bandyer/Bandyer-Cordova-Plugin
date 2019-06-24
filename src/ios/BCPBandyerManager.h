//
// Copyright © 2019 Bandyer S.r.l. All Rights Reserved.
// See LICENSE for licensing information
//

#import <Foundation/Foundation.h>
#import <PushKit/PushKit.h>
#import <Cordova/CDV.h>

NS_ASSUME_NONNULL_BEGIN

@interface BCPBandyerManager : NSObject

@property (nonatomic, weak) UIViewController * _Nullable viewController;
@property (nonatomic, weak) id <CDVWebViewEngineProtocol> _Nullable webViewEngine;
@property (nonatomic, strong) PKPushPayload * _Nullable payload;

- (BOOL)configureBandyerWithParams:(NSDictionary * _Nonnull)params;
- (void)addCallClient;
- (void)removeCallClient;
- (BOOL)startCallClientWithParams:(NSDictionary * _Nonnull)params;
- (void)pauseCallClient;
- (void)resumeCallClient;
- (void)stopCallClient;
- (NSString * _Nullable)callClientState;
- (BOOL)handleNotificationPayloadWithParams:(NSDictionary * _Nonnull)params;
- (BOOL)makeCallWithParams:(NSDictionary * _Nonnull)params;
- (void)addUsersDetails:(NSDictionary *)params;
- (void)removeUsersDetails;

+ (instancetype)shared;

@end

NS_ASSUME_NONNULL_END