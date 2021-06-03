//
// Copyright © 2019 Bandyer S.r.l. All Rights Reserved.
// See LICENSE for licensing information
//

#import "BCPUsersDetailsCache.h"

@interface BCPUsersDetailsCache ()

@property (nonatomic, strong) NSMutableDictionary <id<NSCopying>, BDKUserInfoDisplayItem *> *cache;

@end

@implementation BCPUsersDetailsCache

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        _cache = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)setItem:(nullable BDKUserInfoDisplayItem *)item forKey:(id<NSCopying>)key
{
    @synchronized (self)
    {
        self.cache[key] = item;
    }
}

- (nullable BDKUserInfoDisplayItem *)itemForKey:(id<NSCopying>)key
{
    @synchronized (self)
    {
        return self.cache[key];
    }
}

- (void)purge
{
    @synchronized (self)
    {
        [self.cache removeAllObjects];
    }
}

@end
