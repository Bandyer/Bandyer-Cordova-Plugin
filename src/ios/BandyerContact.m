//
//  Created by WhiteTiger "sgama la rete" on 13/06/2019.
//

#import "BandyerContact.h"

@implementation BandyerContact

- (NSString *)fullName {
    if (self.firstName && self.lastName)
        return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
    
    return nil;
}

- (instancetype)init {
    if (self = [super init]) {
        _gender = GenderUnknown;
    }
    
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    BandyerContact *copy = (BandyerContact *)[[[self class] allocWithZone:zone] init];
    
    if (copy != nil) {
        copy.alias = [self.alias copyWithZone:zone];
        copy.nickName = [self.nickName copyWithZone:zone];
        copy.firstName = [self.firstName copyWithZone:zone];
        copy.lastName = [self.lastName copyWithZone:zone];
        copy.email = [self.email copyWithZone:zone];
        copy.age = [self.age copyWithZone:zone];
        copy.gender = self.gender;
        copy.profileImageURL = [self.profileImageURL copyWithZone:zone];
    }
    
    return copy;
}

@end
