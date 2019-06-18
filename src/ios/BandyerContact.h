//
//  Created by WhiteTiger "sgama la rete" on 13/06/2019.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(char, Gender) {
    GenderUnknown = -1,
    GenderMale = 0,
    GenderFemale = 1
};

@interface BandyerContact : NSObject <NSCopying>

@property (nonatomic, strong, nullable) NSString *alias;
@property (nonatomic, strong, nullable, readonly) NSString *fullName;
@property (nonatomic, strong, nullable) NSString *nickName;
@property (nonatomic, strong, nullable) NSString *firstName;
@property (nonatomic, strong, nullable) NSString *lastName;
@property (nonatomic, strong, nullable) NSString *email;
@property (nonatomic, strong, nullable) NSNumber *age;
@property (nonatomic, assign) Gender gender;
@property (nonatomic, strong, nullable) NSURL *profileImageURL;

@end
