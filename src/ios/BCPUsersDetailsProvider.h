//
// Copyright © 2019 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information
//

#import <Foundation/Foundation.h>
#import <Bandyer/BDKUserInfoFetcher.h>

@class BCPUsersDetailsCache;

NS_ASSUME_NONNULL_BEGIN

@interface BCPUsersDetailsProvider : NSObject <BDKUserInfoFetcher>

- (instancetype)initWithCache:(BCPUsersDetailsCache *)cache;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
