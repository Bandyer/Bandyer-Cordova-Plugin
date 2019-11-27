//
// Copyright © 2019 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information
//

#import <Foundation/Foundation.h>
#import <Bandyer/BCXCallClientObserver.h>
#import <Bandyer/BCXCallClient.h>

@class BCPEventEmitter;

NS_ASSUME_NONNULL_BEGIN

@interface BCPCallClientEventsReporter : NSObject <BCXCallClientObserver>

@property (nonatomic, assign, readonly, getter=isRunning) BOOL running;

- (instancetype)initWithCallClient:(id <BCXCallClient>)callClient eventEmitter:(BCPEventEmitter *)emitter;

- (void)start;
- (void)stop;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;


@end

NS_ASSUME_NONNULL_END
