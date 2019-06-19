//
// Copyright © 2019 Bandyer S.r.l. All Rights Reserved.
// See LICENSE for licensing information
//

#import <Foundation/Foundation.h>
#import "BandyerHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSString (BandyerPlugin)

- (nullable BDKEnvironment *)toBDKEnvironment;
- (BDKCallType)toBDKCallType;

@end

NS_ASSUME_NONNULL_END