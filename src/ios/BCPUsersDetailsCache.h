//
// Copyright © 2019 Bandyer S.r.l. All Rights Reserved.
// See LICENSE for licensing information
//

#import <Foundation/Foundation.h>
#import <BandyerSDK/BandyerSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface BCPUsersDetailsCache : NSObject <BDKUserInfoFetcher, NSCopying>

- (void)addUsersDetails:(NSArray<NSDictionary *> *)details;
- (void)removeUsersDetails;

@end

NS_ASSUME_NONNULL_END