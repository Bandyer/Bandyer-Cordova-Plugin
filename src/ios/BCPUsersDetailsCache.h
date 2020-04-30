//
// Copyright © 2019 Bandyer S.r.l. All Rights Reserved.
// See LICENSE for licensing information
//

#import <Foundation/Foundation.h>
#import <Bandyer/Bandyer.h>

NS_ASSUME_NONNULL_BEGIN

@interface BCPUsersDetailsCache <__covariant KeyType, __covariant ValueType : BDKUserInfoDisplayItem *> : NSObject

- (void)setItem:(nullable ValueType)item forKey:(KeyType <NSCopying> )key;
- (nullable ValueType)itemForKey:(KeyType <NSCopying>)key;
- (void)purge;

@end

NS_ASSUME_NONNULL_END
