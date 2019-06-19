//
// Copyright © 2019 Bandyer S.r.l. All Rights Reserved.
// See LICENSE for licensing information
//

#import "BandyerUserInfoFetch.h"

@interface BandyerUserInfoFetch ()

@property (nonatomic, strong) NSDictionary<NSString *, BandyerContact *> *aliasMap;

@end

@implementation BandyerUserInfoFetch

- (instancetype)initWithAddress:(NSArray *)address {
    if (self = [super init]) {
        [self setAliasMap:[self createAliasMap:address]];
    }
    
    return self;
}

- (NSDictionary<NSString *, BandyerContact *> *)createAliasMap:(NSArray *)addressBook {
    NSMutableDictionary *map = [NSMutableDictionary new];
    
    for (NSDictionary *dict in addressBook) {
        BandyerContact *contact = [BandyerContact new];
        
        contact.alias = [dict valueForKey:@"alias"];
        contact.nickName = [dict valueForKey:@"nickName"];
        contact.firstName = [dict valueForKey:@"firstName"];
        contact.lastName = [dict valueForKey:@"lastName"];
        contact.email = [dict valueForKey:@"email"];
        contact.age = [dict valueForKey:@"age"];
        
        NSString *gender = [dict valueForKey:@"gender"];
        
        contact.gender = [self convertIntoGender:gender];
        
        NSString *url = [dict valueForKey:@"profileImageUrl"];
        
        if (url) {
            contact.profileImageURL = [NSURL URLWithString:url];
        }
        
        map[contact.alias] = contact;
    }
    
    return map;
}

- (Gender)convertIntoGender:(NSString *)gender {
    if ([[gender lowercaseString] isEqualToString:@"m"]) {
        return GenderMale;
        
    } else if ([[gender lowercaseString] isEqualToString:@"f"]) {
        return GenderFemale;
        
    } else {
        return GenderUnknown;
    }
}

- (id)copyWithZone:(NSZone *)zone {
    BandyerUserInfoFetch *copy = (BandyerUserInfoFetch *)[[[self class] allocWithZone:zone] init];
    
    if (copy != nil) {
        copy->_aliasMap = [_aliasMap copyWithZone:zone];
    }
    
    return copy;
}

#pragma mark - BDKUserInfoFetcher

- (void)fetchUsers:(NSArray<NSString *> *)aliases completion:(void (^)(NSArray<BDKUserInfoDisplayItem *> * _Nullable))completion {
    NSMutableArray<BDKUserInfoDisplayItem *> *items = [NSMutableArray arrayWithCapacity:aliases.count];
    
    for (NSString *alias in aliases) {
        BandyerContact *contact = self.aliasMap[alias];
        
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
