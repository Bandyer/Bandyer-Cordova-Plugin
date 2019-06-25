//
// Copyright © 2019 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information
//

#import <Foundation/Foundation.h>
#import <Cordova/CDV.h>

NS_ASSUME_NONNULL_BEGIN

@interface BCPCallClientEventEmitter : NSObject

@property (nonatomic, weak, readonly) id <CDVWebViewEngineProtocol> webViewEngine;

- (instancetype)initWithWebViewEngine:(id <CDVWebViewEngineProtocol>)engine;

- (void)start;
- (void)stop;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
