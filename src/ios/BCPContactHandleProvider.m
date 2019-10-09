//
// Copyright © 2019 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information
//

#import <CallKit/CallKit.h>
#import <BandyerSDK/BDKUserInfoDisplayItem.h>

#import "BCPContactHandleProvider.h"
#import "BCPUsersDetailsCache.h"
#import "BCPMacros.h"

@interface BCPContactHandleProvider ()

@property (nonatomic, strong, readonly) BCPUsersDetailsCache *cache;

@end

@implementation BCPContactHandleProvider

- (instancetype)initWithCache:(BCPUsersDetailsCache *)cache
{
    BCPAssertOrThrowInvalidArgument(cache, @"A cache must be provided, got nil");

    self = [super init];

    if (self)
    {
        _cache = cache;
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

    NSMutableArray *handles = [NSMutableArray arrayWithCapacity:aliases.count];

    for (NSString *alias in aliases)
    {
        BDKUserInfoDisplayItem *item = [self.cache itemForKey:alias] ?: [[BDKUserInfoDisplayItem alloc] initWithAlias:alias];

        NSString *value = [self handleValueForItem:item];

        [handles addObject:value];
    }

    return [handles componentsJoinedByString:@", "];
}

- (NSString *)handleValueForItem:(BDKUserInfoDisplayItem *)item
{
    if (item.firstName.length > 0 && item.lastName.length > 0)
        return [NSString stringWithFormat:@"%@ %@", item.firstName, item.lastName];
    else
        return item.alias;
}

- (id)copyWithZone:(nullable NSZone *)zone
{
    BCPContactHandleProvider *copy = (BCPContactHandleProvider *) [[[self class] allocWithZone:zone] init];

    if (copy != nil)
    {
        copy->_cache = _cache;
    }

    return copy;
}


@end
