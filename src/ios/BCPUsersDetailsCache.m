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

- (void)addUsersDetails:(NSArray<NSDictionary *> *)details
{
    for (NSDictionary *dict in details) 
    {
        if (![dict isKindOfClass:NSDictionary.class])
            continue;
        
        NSString *alias = dict[@"userAlias"];

        if (![alias isKindOfClass:NSString.class])
            continue;

        if (alias.length == 0)
            continue;

        BDKUserInfoDisplayItem *item = [[BDKUserInfoDisplayItem alloc] initWithAlias:alias];
        item.firstName = [dict valueForKey:@"firstName"];
        item.lastName = [dict valueForKey:@"lastName"];
        item.email = [dict valueForKey:@"email"];    
        
        NSString *urlAsString = [dict valueForKey:@"profileImageUrl"];
        if (urlAsString)
            item.imageURL = [NSURL URLWithString:urlAsString]; 
                    
        self.cache[alias] = item;
    }
}

- (void)removeUsersDetails
{
    [self.cache removeAllObjects];
}

#pragma mark - BDKUserInfoFetcher

- (void)fetchUsers:(NSArray<NSString *> *)aliases completion:(void (^)(NSArray<BDKUserInfoDisplayItem *> * _Nullable))completion
{
    NSMutableArray<BDKUserInfoDisplayItem *> *items = [NSMutableArray arrayWithCapacity:aliases.count];
    
    for (NSString *alias in aliases) 
    {
        BDKUserInfoDisplayItem *item = self.cache[alias];

        if (!item)
            item = [[BDKUserInfoDisplayItem alloc] initWithAlias:alias];
            
        [items addObject:item];
    }
    
    completion(items);
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    BCPUsersDetailsCache *copy = (BCPUsersDetailsCache *)[[[self class] allocWithZone:zone] init];
    
    if (copy != nil)
    {
        copy->_cache = [_cache copyWithZone:zone];
    }
    
    return copy;
}


@end
