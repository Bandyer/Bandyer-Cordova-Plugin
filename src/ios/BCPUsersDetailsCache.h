//
// Copyright © 2019 Bandyer S.r.l. All Rights Reserved.
// See LICENSE for licensing information
//

#import <Foundation/Foundation.h>
#import <Bandyer/Bandyer.h>

NS_ASSUME_NONNULL_BEGIN

@interface BCPUsersDetailsCache : NSObject

- (void)setItem:(BDKUserInfoDisplayItem *)item forKey:(NSString *)key;
- (BDKUserInfoDisplayItem *)itemForKey:(NSString *)key;
- (void)purge;

@end

NS_ASSUME_NONNULL_END
