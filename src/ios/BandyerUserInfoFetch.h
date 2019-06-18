//
//  Created by WhiteTiger "sgama la rete" on 13/06/2019.
//

#import <Foundation/Foundation.h>
#import "BandyerHeader.h"

@interface BandyerUserInfoFetch : NSObject <BDKUserInfoFetcher>

- (instancetype)initWithAddress:(NSArray *)address;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end
