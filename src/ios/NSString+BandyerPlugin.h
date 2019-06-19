//
// Copyright © 2019 Bandyer S.r.l. All Rights Reserved.
// See LICENSE for licensing information
//

#import <Foundation/Foundation.h>
#import "BandyerHeader.h"

@interface NSString (BandyerPlugin)

- (BDKEnvironment *)convertIntoBandyerEnvironment;
- (BDKCallType)convertIntoBallType;

@end
