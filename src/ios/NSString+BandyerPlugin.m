//
//  Created by WhiteTiger "sgama la rete" on 22/05/2019.
//

#import "NSString+BandyerPlugin.h"

@implementation NSString (BandyerPlugin)

- (BDKEnvironment *)convertIntoBandyerEnvironment {
    NSString *environment = [self lowercaseString];
    
    if ([environment isEqualToString:@"sandbox"]) {
        return BDKEnvironment.sandbox;
    
    } else if ([environment isEqualToString:@"production"]) {
        return BDKEnvironment.production;
    }
    
    return nil;
}

- (BDKCallType)convertIntoBallType {
    if ([[self lowercaseString] isEqualToString:@"a"]) {
        return BDKCallTypeAudioOnly;
        
    } else if ([[self lowercaseString] isEqualToString:@"au"]) {
        return BDKCallTypeAudioUpgradable;
        
    } else {
        return BDKCallTypeAudioVideo;
    }
}

@end
