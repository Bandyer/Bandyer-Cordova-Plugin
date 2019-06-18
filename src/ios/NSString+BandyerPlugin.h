//
//  Created by WhiteTiger "sgama la rete" on 22/05/2019.
//

#import <Foundation/Foundation.h>
#import "BandyerHeader.h"

@interface NSString (BandyerPlugin)

- (BDKEnvironment *)convertIntoBandyerEnvironment;
- (BDKCallType)convertIntoBallType;

@end
