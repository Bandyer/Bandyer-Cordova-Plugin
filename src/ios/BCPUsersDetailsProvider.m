// Copyright © 2019 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information

#import "BCPUsersDetailsProvider.h"
#import "BCPUsersDetailsCache.h"
#import "BCPMacros.h"

#import <CallKit/CallKit.h>

@interface BCPUsersDetailsProvider ()

@property (nonatomic, strong, readonly) BCPUsersDetailsCache *cache;
@property (nonatomic, strong, readonly) NSFormatter *formatter;

@end

@implementation BCPUsersDetailsProvider

- (instancetype)initWithCache:(BCPUsersDetailsCache *)cache formatter:(NSFormatter *)formatter
{
    BCPAssertOrThrowInvalidArgument(cache, @"A cache must be provided, got nil");
    BCPAssertOrThrowInvalidArgument(formatter, @"A formatter must be provided, got nil");

    self = [super init];

    if (self)
    {
        _cache = cache;
        _formatter = formatter;
    }

    return self;
}

- (void)provideDetails:(nonnull NSArray<NSString *> *)aliases completion:(nonnull void (^)(NSArray<BDKUserDetails *> * _Nonnull))completion
{
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:aliases.count];

    for (NSString *alias in aliases)
    {
        BDKUserDetails *item = [self.cache itemForKey:alias];

        if (item)
            [items addObject:item];
        else
            [items addObject:[[BDKUserDetails alloc] initWithAlias:alias]];
    }

    completion(items);
}

- (void)provideHandle:(nonnull NSArray<NSString *> *)aliases completion:(nonnull void (^)(CXHandle * _Nonnull))completion
{
    NSString *value = [self handleValueForAliases:aliases];

    CXHandle *handle = [[CXHandle alloc] initWithType:CXHandleTypeGeneric value:value];

    completion(handle);
}

- (NSString *)handleValueForAliases:(NSArray<NSString *> *)aliases
{
    if (aliases.count == 0)
        return @"Unknown";

    NSArray<BDKUserDetails *>* items = [self itemsForAliases:aliases];
    return [self.formatter stringForObjectValue:items];
}

- (NSArray<BDKUserDetails *> *)itemsForAliases:(NSArray<NSString *> *)aliases
{
    NSMutableArray *items = [NSMutableArray array];

    for (NSString *alias in aliases)
    {
        BDKUserDetails *item = [self.cache itemForKey:alias] ?: [[BDKUserDetails alloc] initWithAlias:alias];
        [items addObject:item];
    }

    return items;
}


@end
