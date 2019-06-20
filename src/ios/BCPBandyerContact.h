//
// Copyright © 2019 Bandyer S.r.l. All Rights Reserved.
// See LICENSE for licensing information
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BCPBandyerContact : NSObject <NSCopying>

@property (nonatomic, strong, nullable) NSString *alias;
@property (nonatomic, strong, nullable, readonly) NSString *fullName;
@property (nonatomic, strong, nullable) NSString *nickName;
@property (nonatomic, strong, nullable) NSString *firstName;
@property (nonatomic, strong, nullable) NSString *lastName;
@property (nonatomic, strong, nullable) NSString *email;
@property (nonatomic, strong, nullable) NSURL *profileImageURL;

@end

NS_ASSUME_NONNULL_END