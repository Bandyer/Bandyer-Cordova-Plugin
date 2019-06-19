//
// Copyright © 2019 Bandyer S.r.l. All Rights Reserved.
// See LICENSE for licensing information
//

#import <Foundation/Foundation.h>
#import "BandyerHeader.h"

@interface BandyerManager : NSObject

@property (nonatomic, weak) UIViewController * _Nullable viewController;
@property (nonatomic, readwrite, weak) id <CDVWebViewEngineProtocol> _Nullable webViewEngine;
@property (nonatomic, strong) PKPushPayload * _Nullable payload;

+ (instancetype _Nullable)shared;
- (instancetype _Nullable)init;

- (bool)configureBandyerWithParams:(NSDictionary * _Nonnull)params;
- (void)addCallClient;
- (void)removeCallClient;
- (bool)startCallClientWithParams:(NSDictionary * _Nonnull)params;
- (void)pauseCallClient;
- (void)resumeCallClient;
- (void)stopCallClient;
- (NSString * _Nullable)stateCallClient;
- (bool)handlerPayloadWithParams:(NSDictionary * _Nonnull)params;
- (bool)makeCallWithParams:(NSDictionary * _Nonnull)params;
- (void)createUserInfoFetchWithParams:(NSDictionary * _Nonnull)params;
- (void)clearCache;

@end
