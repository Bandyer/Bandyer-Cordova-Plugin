//
// Copyright © 2019 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information
//

#import "BCPPushTokenEventsReporter.h"
#import "BCPEventEmitter.h"
#import "BCPMacros.h"
#import "BCPBandyerEvents.h"

#import <Bandyer/PKPushCredentials+BCXAdditions.h>

@interface BCPPushTokenEventsReporter ()

@property (nonatomic, strong, readonly) BCPEventEmitter *emitter;

@end

@implementation BCPPushTokenEventsReporter

- (instancetype)initWithEventEmitter:(BCPEventEmitter *)emitter
{
    BCPAssertOrThrowInvalidArgument(emitter, @"An event emitter must be provided, got nil");

    self = [super init];

    if (self)
    {
        _emitter = emitter;
    }

    return self;
}

- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)pushCredentials forType:(PKPushType)type
{
    NSString *token = [pushCredentials bcx_tokenAsString];

    if (token.length == 0)
        return;

    [self.emitter sendEvent:[[BCPBandyerEvents iOSVoipPushTokenUpdated] value] withArgs:@[token]];
}

- (void)pushRegistry:(PKPushRegistry *)registry didInvalidatePushTokenForType:(PKPushType)type
{
    [self.emitter sendEvent:[[BCPBandyerEvents iOSVoipPushTokenInvalidated] value] withArgs:@[]];
}


@end
