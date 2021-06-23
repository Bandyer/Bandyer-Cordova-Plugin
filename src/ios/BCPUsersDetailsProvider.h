// Copyright © 2019 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information

#import <Foundation/Foundation.h>
#import <Bandyer/BDKUserDetailsProvider.h>

@class BCPUsersDetailsCache;

NS_ASSUME_NONNULL_BEGIN

@interface BCPUsersDetailsProvider : NSObject <BDKUserDetailsProvider>

- (instancetype)initWithCache:(BCPUsersDetailsCache *)cache;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
