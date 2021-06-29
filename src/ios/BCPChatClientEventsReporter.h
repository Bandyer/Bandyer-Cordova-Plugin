//
// Copyright © 2019 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information
//

#import <Foundation/Foundation.h>
#import <Bandyer/BDKChatClientObserver.h>
#import <Bandyer/BDKChatClient.h>

@class BCPEventEmitter;

NS_ASSUME_NONNULL_BEGIN

@interface BCPChatClientEventsReporter : NSObject <BDKChatClientObserver>

@property (nonatomic, assign, readonly, getter=isRunning) BOOL running;

- (instancetype)initWithChatClient:(id <BDKChatClient>)chatClient eventEmitter:(BCPEventEmitter *)eventEmitter;

- (void)start;
- (void)stop;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
