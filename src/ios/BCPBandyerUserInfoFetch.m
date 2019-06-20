//
// Copyright © 2019 Bandyer S.r.l. All Rights Reserved.
// See LICENSE for licensing information
//

#import "BCPBandyerUserInfoFetch.h"
#import "BCPBandyerContact.h"

@interface BCPBandyerUserInfoFetch ()

@property (nonatomic, strong) NSDictionary<NSString *, BCPBandyerContact *> *aliasMap;

@end

@implementation BCPBandyerUserInfoFetch

- (instancetype)initWithAddress:(NSArray *)address {
    if (self = [super init]) {
        [self setAliasMap:[self createAliasMap:address]];
    }
    
    return self;
}

- (NSDictionary<NSString *, BCPBandyerContact *> *)createAliasMap:(NSArray *)addressBook {
    NSMutableDictionary *map = [NSMutableDictionary new];
    
    for (NSDictionary *dict in addressBook) {
        BCPBandyerContact *contact = [BCPBandyerContact new];
        
        contact.alias = [dict valueForKey:@"alias"];
        contact.nickName = [dict valueForKey:@"nickName"];
        contact.firstName = [dict valueForKey:@"firstName"];
        contact.lastName = [dict valueForKey:@"lastName"];
        contact.email = [dict valueForKey:@"email"];
        
        NSString *url = [dict valueForKey:@"profileImageUrl"];
        
        if (url) {
            contact.profileImageURL = [NSURL URLWithString:url];
        }
        
        map[contact.alias] = contact;
    }
    
    return map;
}

- (id)copyWithZone:(NSZone *)zone {
    BCPBandyerUserInfoFetch *copy = (BCPBandyerUserInfoFetch *)[[[self class] allocWithZone:zone] init];
    
    if (copy != nil) {
        copy->_aliasMap = [_aliasMap copyWithZone:zone];
    }
    
    return copy;
}

#pragma mark - BDKUserInfoFetcher

- (void)fetchUsers:(NSArray<NSString *> *)aliases completion:(void (^)(NSArray<BDKUserInfoDisplayItem *> * _Nullable))completion {
    NSMutableArray<BDKUserInfoDisplayItem *> *items = [NSMutableArray arrayWithCapacity:aliases.count];
    
    for (NSString *alias in aliases) {
        BCPBandyerContact *contact = self.aliasMap[alias];
        
        BDKUserInfoDisplayItem *item = [[BDKUserInfoDisplayItem alloc] initWithAlias:alias];
        
        item.nickname = contact.nickName;
        item.firstName = contact.firstName;
        item.lastName = contact.lastName;
        item.email = contact.email;
        item.imageURL = contact.profileImageURL;
        
        [items addObject:item];
    }
    
    completion(items);
}

@end
