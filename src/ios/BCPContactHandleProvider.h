//
// Copyright © 2019 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information
//

#import <Foundation/Foundation.h>
#import <Bandyer/BCXHandleProvider.h>

@class BCPUsersDetailsCache;

NS_ASSUME_NONNULL_BEGIN

API_AVAILABLE(ios(10.0))
@interface BCPContactHandleProvider : NSObject <BCXHandleProvider>

- (instancetype)initWithCache:(BCPUsersDetailsCache *)cache formatter:(NSFormatter *)formatter;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
