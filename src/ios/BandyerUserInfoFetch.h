//
// Copyright © 2019 Bandyer S.r.l. All Rights Reserved.
// See LICENSE for licensing information
//

#import <Foundation/Foundation.h>
#import "BandyerHeader.h"

@interface BandyerUserInfoFetch : NSObject <BDKUserInfoFetcher>

- (instancetype)initWithAddress:(NSArray *)address;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end
