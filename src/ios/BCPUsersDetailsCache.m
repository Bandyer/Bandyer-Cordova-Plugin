//
// Copyright © 2019 Bandyer S.r.l. All Rights Reserved.
// See LICENSE for licensing information
//

#import "BCPUsersDetailsCache.h"

@interface BCPUsersDetailsCache ()

@property (nonatomic, strong) NSMutableDictionary <NSString*, BDKUserInfoDisplayItem *> *cache;

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

- (void)setItem:(BDKUserInfoDisplayItem *)item forKey:(NSString *)key
{
    self.cache[key] = item;
}

- (BDKUserInfoDisplayItem *)itemForKey:(NSString *)key
{
    return self.cache[key];
}

- (void)purge
{
    [self.cache removeAllObjects];
}

@end
