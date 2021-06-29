//
// Copyright © 2019 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information
//

#import <Foundation/Foundation.h>
#import <Bandyer/BDKCallClientObserver.h>
#import <Bandyer/BDKCallClient.h>

@class BCPEventEmitter;

NS_ASSUME_NONNULL_BEGIN

@interface BCPCallClientEventsReporter : NSObject <BDKCallClientObserver>

@property (nonatomic, assign, readonly, getter=isRunning) BOOL running;

- (instancetype)initWithCallClient:(id <BDKCallClient>)callClient eventEmitter:(BCPEventEmitter *)emitter;

- (void)start;
- (void)stop;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;


@end

NS_ASSUME_NONNULL_END
