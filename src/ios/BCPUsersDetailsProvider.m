// Copyright © 2019 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information

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

}

@end
