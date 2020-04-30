//
// Copyright © 2019 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information
//

#import "BCPUsersDetailsCommandsHandler.h"
#import "BCPMacros.h"
#import "BCPUsersDetailsCache.h"
#import "BCPConstants.h"
#import "CDVPluginResult+BCPFactoryMethods.h"

@interface BCPUsersDetailsCommandsHandler ()

@property (nonatomic, strong, readonly) BCPUsersDetailsCache *cache;
@property (nonatomic, weak, readonly) id <CDVCommandDelegate> commandDelegate;

@end

@implementation BCPUsersDetailsCommandsHandler


- (instancetype)initWithCommandDelegate:(id <CDVCommandDelegate>)commandDelegate cache:(BCPUsersDetailsCache *)cache
{
    BCPAssertOrThrowInvalidArgument(commandDelegate, @"A command delegate must be provided, got nil");
    BCPAssertOrThrowInvalidArgument(cache, @"A users details cache must be provided, got nil");

    self = [super init];

    if (self)
    {
        _commandDelegate = commandDelegate;
        _cache = cache;
    }

    return self;
}

- (void)addUsersDetails:(CDVInvokedUrlCommand *)command
{
    NSDictionary *arg = command.arguments.firstObject;

    if (arg.count == 0)
    {
        [self reportCommandFailed:command];
        return;
    }

    NSArray *details = arg[kBCPUserDetailsKey];

    if (![details isKindOfClass:NSArray.class])
    {
        [self reportCommandFailed:command];
        return;
    }

    [self updateCacheWithItems:details];
    [self reportCommandSucceeded:command];
}

- (void)updateCacheWithItems:(NSArray *)items
{
    for (NSDictionary *item in items)
    {
        [self updateCacheWithItemFromDictionary:item];
    }
}

- (void)updateCacheWithItemFromDictionary:(NSDictionary *)dictionary
{
    BDKUserInfoDisplayItem *item = [self itemFromDictionary:dictionary];

    if (item)
        [self.cache setItem:item forKey:item.alias];
}

- (nullable BDKUserInfoDisplayItem *)itemFromDictionary:(NSDictionary *)dictionary
{
    if (![dictionary isKindOfClass:NSDictionary.class])
        return nil;

    NSString *alias = dictionary[@"userAlias"];

    if (![alias isKindOfClass:NSString.class])
        return nil;

    if (alias.length == 0)
        return nil;

    BDKUserInfoDisplayItem *item = [[BDKUserInfoDisplayItem alloc] initWithAlias:alias];
    item.firstName = dictionary[@"firstName"];
    item.lastName = dictionary[@"lastName"];
    item.email = dictionary[@"email"];

    NSString *urlAsString = dictionary[@"profileImageUrl"];
    if (urlAsString)
        item.imageURL = [NSURL URLWithString:urlAsString];

    return item;
}

- (void)purge:(CDVInvokedUrlCommand *)command
{
    [self.cache purge];
    [self reportCommandSucceeded:command];
}

- (void)reportCommandSucceeded:(CDVInvokedUrlCommand *)command
{
    [self.commandDelegate sendPluginResult:[CDVPluginResult bcp_success] callbackId:command.callbackId];
}

- (void)reportCommandFailed:(CDVInvokedUrlCommand *)command
{
    [self.commandDelegate sendPluginResult:[CDVPluginResult bcp_error] callbackId:command.callbackId];
}

@end
