//
// Copyright © 2019 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information
//

#import <Foundation/Foundation.h>
#import <PushKit/PushKit.h>

@class BCPEventEmitter;

NS_ASSUME_NONNULL_BEGIN

@interface BCPPushTokenEventsReporter : NSObject <PKPushRegistryDelegate>

- (instancetype)initWithEventEmitter:(BCPEventEmitter *)emitter;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
