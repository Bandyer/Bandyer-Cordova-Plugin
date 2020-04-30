//
// Copyright © 2019 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information
//

#import "BCPUsersDetailsProvider.h"
#import "BCPUsersDetailsCache.h"
#import "BCPMacros.h"

@interface BCPUsersDetailsProvider ()

@property (nonatomic, strong, readonly) BCPUsersDetailsCache *cache;

@end

@implementation BCPUsersDetailsProvider

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

- (void)fetchUsers:(NSArray<NSString *> *)aliases completion:(void (^)(NSArray<BDKUserInfoDisplayItem *> *_Nullable items))completion
{
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:aliases.count];

    for (NSString *alias in aliases)
    {
        BDKUserInfoDisplayItem *item = [self.cache itemForKey:alias];

        if (item)
            [items addObject:item];
        else
            [items addObject:[[BDKUserInfoDisplayItem alloc] initWithAlias:alias]];
    }

    completion(items);
}

- (id)copyWithZone:(nullable NSZone *)zone
{
    BCPUsersDetailsProvider *copy = (BCPUsersDetailsProvider *) [[[self class] allocWithZone:zone] init];

    if (copy != nil)
    {
        copy->_cache = _cache;
    }

    return copy;
}


@end
