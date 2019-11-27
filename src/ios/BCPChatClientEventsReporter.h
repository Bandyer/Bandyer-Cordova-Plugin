//
// Copyright © 2019 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information
//

#import <Foundation/Foundation.h>
#import <Bandyer/BCHChatClientObserver.h>
#import <Bandyer/BCHChatClient.h>

@class BCPEventEmitter;

NS_ASSUME_NONNULL_BEGIN

@interface BCPChatClientEventsReporter : NSObject <BCHChatClientObserver>

@property (nonatomic, assign, readonly, getter=isRunning) BOOL running;

- (instancetype)initWithChatClient:(id <BCHChatClient>)chatClient eventEmitter:(BCPEventEmitter *)eventEmitter;

- (void)start;
- (void)stop;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
