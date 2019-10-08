//
// Copyright © 2019 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information
//

#import <Foundation/Foundation.h>
#import <Cordova/CDV.h>

NS_ASSUME_NONNULL_BEGIN

@interface BCPEventEmitter : NSObject

- (instancetype)initWithCallbackId:(NSString *)callbackId commandDelegate:(id <CDVCommandDelegate>)commandDelegate;

- (void)sendEvent:(NSString *)event withArgs:(NSArray *)args;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
