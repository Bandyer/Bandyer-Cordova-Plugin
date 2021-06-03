//
// Copyright © 2019 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information
//

#import <CallKit/CallKit.h>
#import <Bandyer/BDKUserInfoDisplayItem.h>

#import "BCPContactHandleProvider.h"
#import "BCPUsersDetailsCache.h"
#import "BCPMacros.h"
#import "BCPUserDetailsFormatter.h"

@interface BCPContactHandleProvider ()

@property (nonatomic, strong, readonly) BCPUsersDetailsCache *cache;
@property (nonatomic, strong, readwrite) BCPUserDetailsFormatter *formatter;

@end

@implementation BCPContactHandleProvider

- (void)setFormat:(NSString *)format
{
    _formatter = [[BCPUserDetailsFormatter alloc] initWithFormat:format];
}

- (instancetype)initWithCache:(BCPUsersDetailsCache *)cache
{
    BCPAssertOrThrowInvalidArgument(cache, @"A cache must be provided, got nil");

    self = [super init];

    if (self)
    {
        _cache = cache;
        _formatter = [[BCPUserDetailsFormatter alloc] initWithFormat:@"${useralias}"];
    }

    return self;
}

- (void)handleForAliases:(nullable NSArray<NSString *> *)aliases completion:(void (^)(CXHandle *handle))completion
{
    NSString *value = [self handleValueForAliases:aliases];

    CXHandle *handle = [[CXHandle alloc] initWithType:CXHandleTypeGeneric value:value];

    completion(handle);
}

- (NSString *)handleValueForAliases:(NSArray<NSString *> *)aliases
{
    if (aliases.count == 0)
        return @"Unknown";

    NSArray<BDKUserInfoDisplayItem *>* items = [self itemsForAliases:aliases];
    return [self.formatter stringForObjectValue:items];
}

- (NSArray<BDKUserInfoDisplayItem *> *)itemsForAliases:(NSArray<NSString *> *)aliases
{
    NSMutableArray *items = [NSMutableArray array];

    for (NSString *alias in aliases)
    {
        BDKUserInfoDisplayItem *item = [self.cache itemForKey:alias] ?: [[BDKUserInfoDisplayItem alloc] initWithAlias:alias];
        [items addObject:item];
    }

    return items;
}

- (id)copyWithZone:(nullable NSZone *)zone
{
    BCPContactHandleProvider *copy = (BCPContactHandleProvider *) [[[self class] allocWithZone:zone] init];

    if (copy != nil)
    {
        copy->_cache = _cache;
        copy->_formatter = [_formatter copyWithZone:zone];
    }

    return copy;
}

@end
